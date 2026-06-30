extends CharacterBody2D
## Ghost Pirate Enemy - Floats, phases through walls, teleports

enum State { FLOAT, CHASE, TELEPORT, ATTACK, DEAD }

const FLOAT_SPEED := 30.0
const CHASE_SPEED := 60.0
const TELEPORT_DISTANCE := 80.0

var state: State = State.FLOAT
var health := 2
var player: CharacterBody2D = null
var float_offset := 0.0
var teleport_cooldown := 0.0
var attack_cooldown := 0.0
var alpha_target := 0.6

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea


func _ready() -> void:
	detection_area.body_entered.connect(_on_player_detected)
	detection_area.body_exited.connect(_on_player_lost)
	attack_area.body_entered.connect(_on_player_in_range)
	# Ghosts don't collide with world
	set_collision_mask_value(1, false)
	animated_sprite.modulate.a = 0.6


func _physics_process(delta: float) -> void:
	float_offset += delta * 2.0
	teleport_cooldown -= delta
	attack_cooldown -= delta

	match state:
		State.FLOAT:
			_float_around(delta)
		State.CHASE:
			_chase_player(delta)
		State.TELEPORT:
			pass
		State.ATTACK:
			_attack(delta)
		State.DEAD:
			return

	# Ghost bobbing effect
	position.y += sin(float_offset) * 0.3

	# Fade in/out effect
	animated_sprite.modulate.a = move_toward(animated_sprite.modulate.a, alpha_target, delta)

	move_and_slide()


func _float_around(delta: float) -> void:
	velocity = Vector2(cos(float_offset * 0.5) * FLOAT_SPEED, sin(float_offset) * 10.0)


func _chase_player(delta: float) -> void:
	if player == null:
		state = State.FLOAT
		return

	var dir := (player.global_position - global_position).normalized()
	velocity = dir * CHASE_SPEED
	animated_sprite.flip_h = dir.x < 0

	# Teleport behind player occasionally
	if teleport_cooldown <= 0 and global_position.distance_to(player.global_position) > 60:
		_teleport()
		teleport_cooldown = 3.0


func _teleport() -> void:
	state = State.TELEPORT
	alpha_target = 0.0
	await get_tree().create_timer(0.3).timeout

	if player:
		var offset := Vector2(randf_range(-40, 40), randf_range(-20, 20))
		global_position = player.global_position + offset

	alpha_target = 0.6
	await get_tree().create_timer(0.3).timeout
	state = State.CHASE


func _attack(delta: float) -> void:
	velocity = Vector2.ZERO
	if attack_cooldown <= 0 and player:
		var dir := (player.global_position - global_position).normalized()
		if player.has_method("take_damage"):
			player.take_damage(1, dir)
		attack_cooldown = 2.0
		state = State.CHASE


func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if state == State.DEAD:
		return
	health -= amount
	_flash_hurt()

	if health <= 0:
		GameManager.register_enemy_kill()
		_die()


func _flash_hurt() -> void:
	animated_sprite.modulate = Color(1, 0.3, 0.3, 0.8)
	await get_tree().create_timer(0.15).timeout
	animated_sprite.modulate = Color(1, 1, 1, 0.6)


func _die() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	animated_sprite.play("Death")
	# Dramatic ghost fade
	var tween := create_tween()
	tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.8)
	tween.tween_property(animated_sprite, "scale", Vector2(1.5, 1.5), 0.8)
	await tween.finished
	queue_free()


func _on_player_detected(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		state = State.CHASE
		alpha_target = 0.9


func _on_player_lost(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		state = State.FLOAT
		alpha_target = 0.4


func _on_player_in_range(body: Node2D) -> void:
	if body.is_in_group("player") and state != State.DEAD:
		state = State.ATTACK
