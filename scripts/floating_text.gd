extends Node2D
## Floating text that rises and fades - used for damage numbers, pickups, etc.

var text := ""
var color := Color.WHITE
var font_size := 10
var rise_speed := 30.0
var duration := 0.8

@onready var label: Label = $Label


func _ready() -> void:
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)

	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - rise_speed, duration)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration)
	tween.parallel().tween_property(self, "scale", Vector2(0.8, 0.8), duration)
	await tween.finished
	queue_free()


static func create_at(parent: Node, pos: Vector2, msg: String, col: Color = Color.WHITE) -> void:
	var popup_scene := preload("res://scenes/effects/floating_text.tscn")
	var popup := popup_scene.instantiate()
	popup.text = msg
	popup.color = col
	popup.global_position = pos
	parent.add_child(popup)
