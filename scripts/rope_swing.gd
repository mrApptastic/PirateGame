extends Area2D
## Rope Swing - Player can grab and swing from ropes

@export var rope_length := 60.0
@export var swing_force := 200.0

var player: CharacterBody2D = null
var is_swinging := false
var swing_angle := 0.0
var swing_velocity := 0.0
var anchor_point := Vector2.ZERO

@onready var rope_visual: Line2D = $RopeVisual


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	anchor_point = global_position


func _physics_process(delta: float) -> void:
	if is_swinging and player:
		# Pendulum physics
		var gravity_effect := 400.0 * sin(swing_angle)
		swing_velocity += gravity_effect * delta
		swing_velocity *= 0.99  # Damping
		swing_angle += swing_velocity * delta

		# Move player along arc
		var offset := Vector2(sin(swing_angle), cos(swing_angle)) * rope_length
		player.global_position = anchor_point + offset
		player.velocity = Vector2.ZERO

		# Update rope visual
		rope_visual.clear_points()
		rope_visual.add_point(Vector2.ZERO)
		rope_visual.add_point(player.global_position - global_position)

		# Release
		if Input.is_action_just_pressed("jump"):
			_release_player()
	else:
		# Draw rope hanging
		rope_visual.clear_points()
		rope_visual.add_point(Vector2.ZERO)
		rope_visual.add_point(Vector2(0, rope_length))


func _release_player() -> void:
	if player:
		# Launch player based on swing momentum
		var launch_dir := Vector2(cos(swing_angle), -sin(swing_angle))
		player.velocity = launch_dir * abs(swing_velocity) * swing_force
		is_swinging = false
		player = null


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_swinging:
		if Input.is_action_pressed("interact") or Input.is_action_pressed("jump"):
			player = body
			is_swinging = true
			swing_angle = 0.0
			swing_velocity = body.velocity.x * 0.01


func _on_body_exited(body: Node2D) -> void:
	if body == player and not is_swinging:
		player = null
