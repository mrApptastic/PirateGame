extends CanvasLayer
## Pirate HUD - Shows health, gold, score, combo, and map pieces

@onready var health_bar: HBoxContainer = $MarginContainer/VBoxContainer/TopBar/HealthBar
@onready var gold_label: Label = $MarginContainer/VBoxContainer/TopBar/GoldContainer/GoldLabel
@onready var score_label: Label = $MarginContainer/VBoxContainer/TopBar/ScoreLabel
@onready var combo_label: Label = $MarginContainer/VBoxContainer/ComboLabel
@onready var map_pieces_label: Label = $MarginContainer/VBoxContainer/TopBar/MapLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/TopBar/LevelLabel

var heart_full_color := Color(0.9, 0.1, 0.1)
var heart_empty_color := Color(0.3, 0.1, 0.1)


func _ready() -> void:
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.treasure_map_piece_collected.connect(_on_map_collected)

	_update_health_display(GameManager.health)
	_on_gold_changed(GameManager.gold)
	_on_score_changed(GameManager.score)
	level_label.text = "Level " + str(GameManager.current_level)
	combo_label.visible = false


func _process(_delta: float) -> void:
	# Update combo display
	if GameManager.combo_count >= 2:
		combo_label.visible = true
		combo_label.text = "COMBO x" + str(GameManager.combo_count) + "!"
		combo_label.modulate = Color(1, 1, 0.3).lerp(Color(1, 0.3, 0.1), min(GameManager.combo_count / 10.0, 1.0))
		combo_label.scale = Vector2.ONE * (1.0 + GameManager.combo_count * 0.05)
	else:
		combo_label.visible = false


func _on_gold_changed(new_amount: int) -> void:
	gold_label.text = str(new_amount)
	# Gold pickup animation
	var tween := create_tween()
	tween.tween_property(gold_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(gold_label, "scale", Vector2.ONE, 0.1)


func _on_health_changed(new_health: int) -> void:
	_update_health_display(new_health)


func _update_health_display(current_health: int) -> void:
	for i in range(health_bar.get_child_count()):
		var heart: ColorRect = health_bar.get_child(i)
		if i < current_health:
			heart.color = heart_full_color
		else:
			heart.color = heart_empty_color


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)


func _on_map_collected(total: int) -> void:
	map_pieces_label.text = "Map: " + str(total) + "/" + str(GameManager.total_map_pieces)
	# Flash effect
	var tween := create_tween()
	tween.tween_property(map_pieces_label, "modulate", Color.GOLD, 0.2)
	tween.tween_property(map_pieces_label, "modulate", Color.WHITE, 0.3)
