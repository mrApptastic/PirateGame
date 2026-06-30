extends Area2D
## Treasure Chest - Contains gold, health, or map pieces

enum ChestType { GOLD, HEALTH, MAP_PIECE, RANDOM }

@export var chest_type: ChestType = ChestType.RANDOM
@export var gold_amount: int = 10
@export var is_locked: bool = false

var is_opened := false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sparkle_particles: GPUParticles2D = $SparkleParticles
@onready var interact_label: Label = $InteractLabel


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	interact_label.visible = false
	sparkle_particles.emitting = true

	if chest_type == ChestType.RANDOM:
		var roll := randf()
		if roll < 0.5:
			chest_type = ChestType.GOLD
		elif roll < 0.8:
			chest_type = ChestType.HEALTH
		else:
			chest_type = ChestType.MAP_PIECE


func _process(_delta: float) -> void:
	if not is_opened and interact_label.visible:
		if Input.is_action_just_pressed("interact"):
			open_chest()


func open_chest() -> void:
	if is_opened or is_locked:
		return

	is_opened = true
	animated_sprite.play("Open")
	interact_label.visible = false
	sparkle_particles.emitting = false

	await get_tree().create_timer(0.3).timeout

	match chest_type:
		ChestType.GOLD:
			_spawn_gold()
		ChestType.HEALTH:
			_give_health()
		ChestType.MAP_PIECE:
			_give_map_piece()

	# Big sparkle burst
	_burst_particles()


func _spawn_gold() -> void:
	var coin_count := 5
	var base_value := gold_amount / coin_count
	var remainder := gold_amount % coin_count
	for i in range(coin_count):
		var coin_scene := preload("res://scenes/collectibles/gold_coin.tscn")
		var coin := coin_scene.instantiate()
		coin.global_position = global_position + Vector2(0, -16)
		coin.gold_value = base_value + (1 if i < remainder else 0)
		coin.spawn_velocity = Vector2(randf_range(-60, 60), randf_range(-120, -60))
		get_parent().call_deferred("add_child", coin)
		await get_tree().create_timer(0.05).timeout


func _give_health() -> void:
	GameManager.heal(2)
	# Visual feedback
	var label := Label.new()
	label.text = "+2 HP"
	label.add_theme_color_override("font_color", Color.GREEN)
	label.position = Vector2(-16, -32)
	add_child(label)
	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 20, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	await tween.finished
	label.queue_free()


func _give_map_piece() -> void:
	GameManager.collect_treasure_map_piece()
	var label := Label.new()
	label.text = "MAP PIECE!"
	label.add_theme_color_override("font_color", Color.GOLD)
	label.position = Vector2(-24, -32)
	add_child(label)
	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 30, 1.2)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.2)
	await tween.finished
	label.queue_free()


func _burst_particles() -> void:
	var burst := GPUParticles2D.new()
	burst.amount = 20
	burst.one_shot = true
	burst.emitting = true
	burst.lifetime = 0.8
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 60.0
	mat.initial_velocity_min = 40.0
	mat.initial_velocity_max = 80.0
	mat.gravity = Vector3(0, 100, 0)
	mat.color = Color.GOLD
	burst.process_material = mat
	burst.global_position = global_position + Vector2(0, -8)
	get_parent().add_child(burst)
	await get_tree().create_timer(1.0).timeout
	burst.queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_opened:
		interact_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interact_label.visible = false
