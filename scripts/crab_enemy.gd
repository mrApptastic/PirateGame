extends CharacterBody2D
## Crab Enemy - Scuttles sideways, hides in shell when hit

enum State { SCUTTLE, HIDE, CHARGE, HURT, DEAD }

const SCUTTLE_SPEED := 50.0
const CHARGE_SPEED := 120.0
const GRAVITY := 600.0

var state: State = State.SCUTTLE
var health := 2
var direction := 1.0
var hide_timer := 0.0
var charge_timer := 0.0
var scuttle_timer := 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var floor_ray: RayCast2D = $FloorRay
@onready var wall_ray: RayCast2D = $WallRay
@onready var player_detect: Area2D = $PlayerDetect


func _ready() -> void:
	scuttle_timer = randf_range(1.0, 3.0)
	player_detect.body_entered.connect(_on_player_near)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	match state:
		State.SCUTTLE:
			_scuttle(delta)
		State.HIDE:
			_hide(delta)
		State.CHARGE:
			_charge(delta)
		State.HURT:
			_hurt(delta)
		State.DEAD:
			velocity.x = 0

	_update_animation()
	move_and_slide()


func _scuttle(delta: float) -> void:
	velocity.x = direction * SCUTTLE_SPEED
	scuttle_timer -= delta

	if scuttle_timer <= 0:
		direction *= -1
		scuttle_timer = randf_range(1.0, 3.0)

	if wall_ray.is_colliding() or (is_on_floor() and not floor_ray.is_colliding()):
		direction *= -1
		scuttle_timer = randf_range(1.0, 3.0)

	animated_sprite.flip_h = direction < 0
	wall_ray.target_position.x = 8 * direction
	floor_ray.position.x = 8 * direction


func _hide(delta: float) -> void:
	velocity.x = 0
	hide_timer -= delta
	if hide_timer <= 0:
		state = State.CHARGE
		charge_timer = 1.5


func _charge(delta: float) -> void:
	velocity.x = direction * CHARGE_SPEED
	charge_timer -= delta
	if charge_timer <= 0 or wall_ray.is_colliding():
		state = State.SCUTTLE
		scuttle_timer = randf_range(1.0, 3.0)


func _hurt(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 300 * delta)
	hide_timer -= delta
	if hide_timer <= 0:
		if health <= 0:
			_die()
		else:
			state = State.HIDE
			hide_timer = 1.0


func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if state == State.DEAD:
		return
	if state == State.HIDE:
		amount = 0  # Shell protects!
		return
	health -= amount
	state = State.HURT
	hide_timer = 0.2
	velocity = knockback * 100
	velocity.y = -80

	if health <= 0:
		GameManager.register_enemy_kill()


func _die() -> void:
	state = State.DEAD
	animated_sprite.play("Death")
	_drop_loot()
	await get_tree().create_timer(0.8).timeout
	queue_free()


func _drop_loot() -> void:
	if randf() > 0.5:
		var coin_scene := preload("res://scenes/collectibles/gold_coin.tscn")
		var coin := coin_scene.instantiate()
		coin.global_position = global_position + Vector2(0, -8)
		get_parent().call_deferred("add_child", coin)


func _update_animation() -> void:
	match state:
		State.SCUTTLE:
			animated_sprite.play("Scuttle")
		State.HIDE:
			animated_sprite.play("Hide")
		State.CHARGE:
			animated_sprite.play("Charge")
		State.HURT:
			animated_sprite.play("Hurt")


func _on_player_near(body: Node2D) -> void:
	if body.is_in_group("player") and state == State.SCUTTLE:
		direction = sign(body.global_position.x - global_position.x)
		state = State.HIDE
		hide_timer = 0.8
