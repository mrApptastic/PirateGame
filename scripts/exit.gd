extends Area2D

signal level_completed


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Dwarf":
		level_completed.emit()
		# Visual feedback
		modulate = Color(0.5, 1.0, 0.5)
		print("Level Complete!")
