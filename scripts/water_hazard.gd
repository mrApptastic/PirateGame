extends Area2D
## Water Hazard - Damages player and applies slow/drowning effect

@export var damage_interval := 1.0

var player_in_water := false
var damage_timer := 0.0
var water_time := 0.0

@onready var water_surface: AnimatedSprite2D = $WaterSurface
@onready var bubble_particles: GPUParticles2D = $BubbleParticles


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	water_time += delta
	# Animate water surface
	if water_surface:
		water_surface.position.y = sin(water_time * 2.0) * 1.0

	if player_in_water:
		damage_timer += delta
		if damage_timer >= damage_interval:
			damage_timer = 0.0
			var players := get_tree().get_nodes_in_group("player")
			for p in players:
				if p.has_method("take_damage"):
					p.take_damage(1)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_water = true
		damage_timer = 0.0
		bubble_particles.emitting = true
		# Splash effect
		_create_splash(body.global_position)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_water = false
		bubble_particles.emitting = false
		_create_splash(body.global_position)


func _create_splash(pos: Vector2) -> void:
	var splash := GPUParticles2D.new()
	splash.amount = 8
	splash.one_shot = true
	splash.emitting = true
	splash.lifetime = 0.5
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 40.0
	mat.initial_velocity_min = 40.0
	mat.initial_velocity_max = 80.0
	mat.gravity = Vector3(0, 200, 0)
	mat.color = Color(0.3, 0.6, 1.0, 0.8)
	splash.process_material = mat
	splash.global_position = pos
	get_parent().add_child(splash)
	await get_tree().create_timer(0.6).timeout
	splash.queue_free()
