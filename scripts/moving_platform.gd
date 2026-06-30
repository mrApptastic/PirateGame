extends AnimatableBody2D
## Moving Platform - Pirate ship deck segment that moves between waypoints

@export var speed := 50.0
@export var wait_time := 1.0
@export var waypoints: Array[Vector2] = []
@export var platform_type: String = "wood"  # wood, ship, barrel

var current_waypoint := 0
var waiting := false
var wait_timer := 0.0
var start_position := Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	start_position = global_position
	if waypoints.is_empty():
		waypoints = [Vector2.ZERO, Vector2(80, 0)]  # Default horizontal movement


func _physics_process(delta: float) -> void:
	if waiting:
		wait_timer -= delta
		if wait_timer <= 0:
			waiting = false
			current_waypoint = (current_waypoint + 1) % waypoints.size()
		return

	var target := start_position + waypoints[current_waypoint]
	var direction := (target - global_position).normalized()
	var distance := global_position.distance_to(target)

	if distance < 2.0:
		global_position = target
		waiting = true
		wait_timer = wait_time
	else:
		var move_distance := min(speed * delta, distance)
		global_position += direction * move_distance

	# Gentle rocking motion for ship platforms
	if platform_type == "ship":
		sprite.rotation = sin(Time.get_ticks_msec() * 0.001) * 0.02
