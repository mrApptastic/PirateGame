extends Node2D
## Seagull Enemy - Flies overhead and dive-bombs the player

enum State { FLYING, DIVING, RETURNING, DEAD }

const FLY_SPEED := 60.0
const DIVE_SPEED := 150.0

var state: State = State.FLYING
var health := 1
var fly_direction := 1.0
var home_position := Vector2.ZERO
var dive_target := Vector2.ZERO
var fly_timer := 0.0

@onready var body: Area2D = $Body
@onready var visual: ColorRect = $Visual
@onready var detection: Area2D = $Detection


func _ready() -> void:
	home_position = global_position
	fly_timer = randf_range(2.0, 4.0)
	detection.body_entered.connect(_on_player_detected)
	body.body_entered.connect(_on_hit_player)


func _physics_process(delta: float) -> void:
	match state:
		State.FLYING:
			_fly(delta)
		State.DIVING:
			_dive(delta)
		State.RETURNING:
			_return_home(delta)
		State.DEAD:
			pass


func _fly(delta: float) -> void:
	global_position.x += fly_direction * FLY_SPEED * delta
	global_position.y = home_position.y + sin(Time.get_ticks_msec() * 0.003) * 5.0

	fly_timer -= delta
	if fly_timer <= 0:
		fly_direction *= -1
		fly_timer = randf_range(2.0, 4.0)

	visual.scale.x = -1 if fly_direction < 0 else 1


func _dive(delta: float) -> void:
	var dir := (dive_target - global_position).normalized()
	global_position += dir * DIVE_SPEED * delta

	if global_position.distance_to(dive_target) < 10:
		state = State.RETURNING


func _return_home(delta: float) -> void:
	var dir := (home_position - global_position).normalized()
	global_position += dir * FLY_SPEED * delta

	if global_position.distance_to(home_position) < 5:
		state = State.FLYING
		fly_timer = randf_range(3.0, 5.0)


func take_damage(amount: int, _knockback: Vector2 = Vector2.ZERO) -> void:
	health -= amount
	if health <= 0:
		state = State.DEAD
		GameManager.register_enemy_kill()
		visual.modulate = Color(1, 0.3, 0.3)
		var tween := create_tween()
		tween.tween_property(self, "global_position:y", global_position.y + 50, 0.5)
		tween.parallel().tween_property(visual, "modulate:a", 0.0, 0.5)
		await tween.finished
		queue_free()


func _on_player_detected(body_node: Node2D) -> void:
	if body_node.is_in_group("player") and state == State.FLYING:
		dive_target = body_node.global_position
		state = State.DIVING


func _on_hit_player(body_node: Node2D) -> void:
	if body_node.is_in_group("player"):
		if body_node.has_method("take_damage"):
			var knockback := (body_node.global_position - global_position).normalized()
			body_node.take_damage(1, knockback)
		state = State.RETURNING
