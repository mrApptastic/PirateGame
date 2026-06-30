extends Node2D
## Level End Flag / Treasure - Triggers level completion

var player_nearby := false

@onready var area: Area2D = $Area2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_label: Label = $InteractLabel


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	interact_label.visible = false


func _process(_delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("interact"):
		_complete_level()

	# Flag waving animation
	animated_sprite.rotation = sin(Time.get_ticks_msec() * 0.003) * 0.1


func _complete_level() -> void:
	GameManager.complete_level()
	interact_label.visible = false
	# Celebration particles
	_spawn_fireworks()
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/victory_screen.tscn")


func _spawn_fireworks() -> void:
	for i in range(5):
		var firework := GPUParticles2D.new()
		firework.amount = 20
		firework.one_shot = true
		firework.emitting = true
		firework.lifetime = 0.8
		firework.position = Vector2(randf_range(-40, 40), randf_range(-60, -20))
		var mat := ParticleProcessMaterial.new()
		mat.direction = Vector3(0, 0, 0)
		mat.spread = 180.0
		mat.initial_velocity_min = 40.0
		mat.initial_velocity_max = 80.0
		mat.gravity = Vector3(0, 50, 0)
		mat.color = Color(randf(), randf(), randf())
		firework.process_material = mat
		add_child(firework)
		await get_tree().create_timer(0.3).timeout


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		interact_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		interact_label.visible = false
