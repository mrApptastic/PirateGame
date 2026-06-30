extends CharacterBody2D
## Skeleton Pirate Enemy - Patrols and charges at player

enum State { PATROL, CHASE, ATTACK, HURT, DEAD }

const PATROL_SPEED := 40.0
const CHASE_SPEED := 80.0
const GRAVITY := 600.0
const DETECTION_RANGE := 120.0
const ATTACK_RANGE := 25.0
const KNOCKBACK_FORCE := 150.0

var state: State = State.PATROL
var health := 3
var direction := 1.0
var player: CharacterBody2D = null
var attack_cooldown := 0.0
var hurt_timer := 0.0
var patrol_timer := 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var floor_ray: RayCast2D = $FloorRay
@onready var wall_ray: RayCast2D = $WallRay


func _ready() -> void:
	detection_area.body_entered.connect(_on_player_detected)
	detection_area.body_exited.connect(_on_player_lost)
	attack_area.body_entered.connect(_on_player_in_attack_range)
	patrol_timer = randf_range(2.0, 4.0)


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	match state:
		State.PATROL:
			_patrol(delta)
		State.CHASE:
			_chase(delta)
		State.ATTACK:
			_attack(delta)
		State.HURT:
			_hurt(delta)
		State.DEAD:
			return

	_update_animation()
	move_and_slide()


func _patrol(delta: float) -> void:
	velocity.x = direction * PATROL_SPEED

	patrol_timer -= delta
	if patrol_timer <= 0:
		direction *= -1
		patrol_timer = randf_range(2.0, 4.0)

	# Turn at walls or edges
	if wall_ray.is_colliding() or (is_on_floor() and not floor_ray.is_colliding()):
		direction *= -1
		patrol_timer = randf_range(2.0, 4.0)

	animated_sprite.flip_h = direction < 0
	wall_ray.target_position.x = 12 * direction
	floor_ray.position.x = 10 * direction


func _chase(delta: float) -> void:
	if player == null:
		state = State.PATROL
		return

	var dir_to_player := sign(player.global_position.x - global_position.x)
	velocity.x = dir_to_player * CHASE_SPEED
	direction = dir_to_player
	animated_sprite.flip_h = direction < 0

	var dist := global_position.distance_to(player.global_position)
	if dist > DETECTION_RANGE * 1.5:
		state = State.PATROL


func _attack(delta: float) -> void:
	velocity.x = 0
	attack_cooldown -= delta
	if attack_cooldown <= 0:
		if player and global_position.distance_to(player.global_position) <= ATTACK_RANGE * 2:
			# Deal damage to player
			var knockback_dir := (player.global_position - global_position).normalized()
			if player.has_method("take_damage"):
				player.take_damage(1, knockback_dir)
			attack_cooldown = 1.2
		else:
			state = State.CHASE


func _hurt(delta: float) -> void:
	hurt_timer -= delta
	velocity.x = move_toward(velocity.x, 0, 200 * delta)
	if hurt_timer <= 0:
		if health <= 0:
			_die()
		else:
			state = State.CHASE if player else State.PATROL


func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if state == State.DEAD:
		return
	health -= amount
	state = State.HURT
	hurt_timer = 0.3
	velocity = knockback * KNOCKBACK_FORCE
	velocity.y = -100
	_flash_white()

	if health <= 0:
		GameManager.register_enemy_kill()


func _die() -> void:
	state = State.DEAD
	animated_sprite.play("Death")
	velocity = Vector2.ZERO
	# Drop gold
	_drop_loot()
	await get_tree().create_timer(1.0).timeout
	queue_free()


func _drop_loot() -> void:
	var gold_drop := randf()
	if gold_drop > 0.3:
		# Spawn gold coin at position
		var coin_scene := preload("res://scenes/collectibles/gold_coin.tscn")
		var coin := coin_scene.instantiate()
		coin.global_position = global_position + Vector2(0, -10)
		get_parent().call_deferred("add_child", coin)


func _flash_white() -> void:
	animated_sprite.modulate = Color.WHITE * 3
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color.WHITE


func _update_animation() -> void:
	match state:
		State.PATROL:
			animated_sprite.play("Walk")
		State.CHASE:
			animated_sprite.play("Run")
		State.ATTACK:
			animated_sprite.play("Attack")
		State.HURT:
			animated_sprite.play("Hurt")


func _on_player_detected(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		state = State.CHASE


func _on_player_lost(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		state = State.PATROL


func _on_player_in_attack_range(body: Node2D) -> void:
	if body.is_in_group("player") and state != State.DEAD:
		state = State.ATTACK
		attack_cooldown = 0.5
