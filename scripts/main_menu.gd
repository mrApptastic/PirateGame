extends Control
## Main Menu - Pirate themed with animated background

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $VBoxContainer/SubtitleLabel
@onready var play_button: Button = $VBoxContainer/ButtonContainer/PlayButton
@onready var quit_button: Button = $VBoxContainer/ButtonContainer/QuitButton
@onready var credits_label: Label = $CreditsLabel

var title_bob := 0.0


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	GameManager.reset_game()

	# Animate title entrance
	title_label.modulate.a = 0
	subtitle_label.modulate.a = 0
	var tween := create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.8)


func _process(delta: float) -> void:
	title_bob += delta
	title_label.position.y = sin(title_bob * 1.5) * 3.0


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
