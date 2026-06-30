extends Control
## Victory Screen - Level completed!

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var continue_button: Button = $VBoxContainer/ContinueButton


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)

	stats_label.text = """⚓ TREASURE SECURED! ⚓

Gold Collected: %d
Enemies Defeated: %d
Score: %d
Combo Best: x%d""" % [
		GameManager.gold,
		GameManager.enemies_defeated,
		GameManager.score,
		GameManager.combo_count,
	]

	# Victory animation
	title_label.modulate = Color.GOLD
	var tween := create_tween().set_loops()
	tween.tween_property(title_label, "modulate", Color.WHITE, 0.5)
	tween.tween_property(title_label, "modulate", Color.GOLD, 0.5)


func _on_continue_pressed() -> void:
	GameManager.current_level += 1
	get_tree().change_scene_to_file("res://scenes/game.tscn")
