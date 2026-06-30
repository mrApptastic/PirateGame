extends Area2D
## Gold Coin Collectible - Floats, spins, and attracts to nearby player

const ATTRACT_SPEED := 200.0
const ATTRACT_RANGE := 50.0
const BOB_SPEED := 3.0
const BOB_AMOUNT := 2.0
const SPAWN_VELOCITY_DECAY := 120.0
const SPAWN_GRAVITY := 200.0

var gold_value := 1
var is_attracted := false
var player: Node2D = null
var initial_y := 0.0
var time := 0.0
var spawn_velocity := Vector2.ZERO

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collect_particles: GPUParticles2D = $CollectParticles


func _ready() -> void:
	initial_y = position.y
	time = randf() * TAU  # Random phase offset
	body_entered.connect(_on_body_entered)
	# Small bounce on spawn
	if spawn_velocity == Vector2.ZERO:
		spawn_velocity = Vector2(randf_range(-30, 30), randf_range(-80, -40))


func _physics_process(delta: float) -> void:
	time += delta

	if is_attracted and player:
		var dir := (player.global_position - global_position).normalized()
		global_position += dir * ATTRACT_SPEED * delta
	else:
		# Bob up and down
		position.y = initial_y + sin(time * BOB_SPEED) * BOB_AMOUNT
		# Apply spawn velocity with decay
		position += spawn_velocity * delta
		spawn_velocity = spawn_velocity.move_toward(Vector2.ZERO, SPAWN_VELOCITY_DECAY * delta)
		spawn_velocity.y += SPAWN_GRAVITY * delta

		# Check for nearby player to attract
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var nearest := players[0]
			if global_position.distance_to(nearest.global_position) < ATTRACT_RANGE:
				is_attracted = true
				player = nearest

	# Spin animation
	animated_sprite.rotation = sin(time * 5.0) * 0.1


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.add_gold(gold_value)
		_play_collect_effect()


func _play_collect_effect() -> void:
	animated_sprite.visible = false
	collect_particles.emitting = true
	set_deferred("monitoring", false)
	await get_tree().create_timer(0.5).timeout
	queue_free()
