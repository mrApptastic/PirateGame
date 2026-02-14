extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Dwarf" and body.has_method("collect_coin"):
		body.collect_coin()
		queue_free()
