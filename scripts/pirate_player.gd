extends CharacterBody2D
## The Pirate Captain - Player Character
## Features: Double jump, wall slide, dash, sword attack, coyote time

# Movement constants
const SPEED := 160.0
const ACCELERATION := 1200.0
const FRICTION := 1000.0
const JUMP_VELOCITY := -280.0
const DOUBLE_JUMP_VELOCITY := -240.0
const WALL_JUMP_VELOCITY := Vector2(200, -260)
const WALL_SLIDE_SPEED := 40.0
const DASH_SPEED := 350.0
const DASH_DURATION := 0.15
const COYOTE_TIME := 0.1
const JUMP_BUFFER_TIME := 0.1
const MAX_FALL_SPEED := 400.0

# State tracking
var can_double_jump := true
var is_wall_sliding := false
var is_dashing := false
var is_attacking := false
var is_dead := false
var facing_right := true
var dash_timer := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var attack_cooldown := 0.0
var invincibility_timer := 0.0
var dash_cooldown := 0.0
var was_on_floor := false

# Visual effects
var trail_timer := 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sword_area: Area2D = $SwordArea
@onready var sword_collision: CollisionShape2D = $SwordArea/CollisionShape2D
@onready var wall_ray_right: RayCast2D = $WallRayRight
@onready var wall_ray_left: RayCast2D = $WallRayLeft
@onready var dash_particles: GPUParticles2D = $DashParticles
@onready var attack_particles: GPUParticles2D = $AttackParticles
@onready var invincibility_flash_timer: Timer = $InvincibilityFlashTimer


func _ready() -> void:
	sword_collision.disabled = true
	dash_particles.emitting = false
	attack_particles.emitting = false
	sword_area.body_entered.connect(_on_sword_hit)
	invincibility_flash_timer.timeout.connect(_on_flash_timer)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_update_timers(delta)
	_handle_gravity(delta)
	_handle_wall_slide()
	_handle_jump()
	_handle_dash(delta)
	_handle_movement(delta)
	_handle_attack()
	_update_animation()
	_handle_invincibility()

	move_and_slide()

	was_on_floor = is_on_floor()


func _update_timers(delta: float) -> void:
	if was_on_floor and not is_on_floor():
		coyote_timer = COYOTE_TIME
	if coyote_timer > 0:
		coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	if attack_cooldown > 0:
		attack_cooldown -= delta
	if invincibility_timer > 0:
		invincibility_timer -= delta
	if dash_cooldown > 0:
		dash_cooldown -= delta

	if is_on_floor():
		can_double_jump = true


func _handle_gravity(delta: float) -> void:
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED


func _handle_wall_slide() -> void:
	is_wall_sliding = false
	if not is_on_floor() and not is_dashing:
		if (wall_ray_right.is_colliding() and Input.is_action_pressed("move_right")) or \
		   (wall_ray_left.is_colliding() and Input.is_action_pressed("move_left")):
			is_wall_sliding = true
			if velocity.y > WALL_SLIDE_SPEED:
				velocity.y = WALL_SLIDE_SPEED
			can_double_jump = true


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	if jump_buffer_timer > 0:
		if is_on_floor() or coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0
			coyote_timer = 0
			_spawn_jump_dust()
		elif is_wall_sliding:
			var wall_dir := -1.0 if wall_ray_right.is_colliding() else 1.0
			velocity = Vector2(WALL_JUMP_VELOCITY.x * wall_dir, WALL_JUMP_VELOCITY.y)
			jump_buffer_timer = 0
			can_double_jump = true
			_spawn_jump_dust()
		elif can_double_jump:
			velocity.y = DOUBLE_JUMP_VELOCITY
			can_double_jump = false
			jump_buffer_timer = 0
			_spawn_double_jump_effect()

	# Variable jump height
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5


func _handle_dash(delta: float) -> void:
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0 and not is_dashing:
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown = 0.8
		dash_particles.emitting = true
		invincibility_timer = DASH_DURATION
		var dash_dir := 1.0 if facing_right else -1.0
		velocity = Vector2(DASH_SPEED * dash_dir, 0)

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_particles.emitting = false


func _handle_movement(delta: float) -> void:
	if is_dashing:
		return

	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		facing_right = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)


func _handle_attack() -> void:
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0 and not is_attacking:
		is_attacking = true
		attack_cooldown = 0.4
		sword_collision.disabled = false
		attack_particles.emitting = true
		animated_sprite.play("Attack")
		await animated_sprite.animation_finished
		sword_collision.disabled = true
		is_attacking = false
		attack_particles.emitting = false


func _update_animation() -> void:
	animated_sprite.flip_h = not facing_right
	sword_area.scale.x = 1 if facing_right else -1

	if is_attacking:
		return

	if is_dashing:
		animated_sprite.play("Dash")
	elif is_wall_sliding:
		animated_sprite.play("WallSlide")
	elif not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("Jump")
		else:
			animated_sprite.play("Fall")
	elif abs(velocity.x) > 10:
		animated_sprite.play("Run")
	else:
		animated_sprite.play("Idle")


func _handle_invincibility() -> void:
	if invincibility_timer > 0:
		animated_sprite.modulate.a = 0.5 if fmod(invincibility_timer, 0.15) > 0.075 else 1.0
	else:
		animated_sprite.modulate.a = 1.0


func take_damage(amount: int = 1, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if invincibility_timer > 0 or is_dead:
		return

	GameManager.take_damage(amount)
	invincibility_timer = 1.5
	invincibility_flash_timer.start()

	# Knockback
	if knockback_dir != Vector2.ZERO:
		velocity = knockback_dir * 200
	else:
		velocity.y = -150

	if GameManager.health <= 0:
		_die()


func _die() -> void:
	is_dead = true
	animated_sprite.play("Death")
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	await get_tree().create_timer(1.5).timeout
	if GameManager.lives > 0:
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")


func _on_sword_hit(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var knockback := (body.global_position - global_position).normalized()
		body.take_damage(1, knockback)


func _spawn_jump_dust() -> void:
	# Create dust particles at feet
	var dust := GPUParticles2D.new()
	dust.amount = 6
	dust.one_shot = true
	dust.emitting = true
	dust.lifetime = 0.4
	var material := ParticleProcessMaterial.new()
	material.direction = Vector3(0, -1, 0)
	material.spread = 45.0
	material.initial_velocity_min = 20.0
	material.initial_velocity_max = 40.0
	material.gravity = Vector3(0, 50, 0)
	material.color = Color(0.82, 0.76, 0.6, 0.7)
	dust.process_material = material
	dust.global_position = global_position
	get_parent().add_child(dust)
	await get_tree().create_timer(0.5).timeout
	dust.queue_free()


func _spawn_double_jump_effect() -> void:
	var effect := GPUParticles2D.new()
	effect.amount = 12
	effect.one_shot = true
	effect.emitting = true
	effect.lifetime = 0.3
	var material := ParticleProcessMaterial.new()
	material.direction = Vector3(0, 1, 0)
	material.spread = 180.0
	material.initial_velocity_min = 30.0
	material.initial_velocity_max = 60.0
	material.gravity = Vector3(0, 0, 0)
	material.color = Color(0.3, 0.7, 1.0, 0.8)
	effect.process_material = material
	effect.global_position = global_position
	get_parent().add_child(effect)
	await get_tree().create_timer(0.5).timeout
	effect.queue_free()


func _on_flash_timer() -> void:
	if invincibility_timer <= 0:
		animated_sprite.modulate.a = 1.0
		invincibility_flash_timer.stop()
