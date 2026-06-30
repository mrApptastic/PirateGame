extends Control
## Game Over Screen - Pirate themed with stats

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var retry_button: Button = $VBoxContainer/ButtonContainer/RetryButton
@onready var menu_button: Button = $VBoxContainer/ButtonContainer/MenuButton


func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	# Show stats
	stats_label.text = """☠ FINAL STATS ☠

Gold Collected: %d
Enemies Defeated: %d  
Final Score: %d
Map Pieces: %d/%d""" % [
		GameManager.gold,
		GameManager.enemies_defeated,
		GameManager.score,
		GameManager.treasure_map_pieces,
		GameManager.total_map_pieces,
	]

	# Dramatic entrance
	title_label.modulate.a = 0
	var tween := create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 0.5)
	tween.tween_property(title_label, "scale", Vector2(1.1, 1.1), 0.3)
	tween.tween_property(title_label, "scale", Vector2.ONE, 0.2)


func _on_retry_pressed() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_menu_pressed() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
