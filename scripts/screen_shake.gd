extends Node
## Screen Shake utility - call GameManager or directly to shake camera

static func shake(camera: Camera2D, intensity: float = 3.0, duration: float = 0.2) -> void:
	var original_offset := camera.offset
	var tween := camera.create_tween()
	var steps := int(duration / 0.03)
	for i in range(steps):
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(camera, "offset", original_offset + offset, 0.03)
	tween.tween_property(camera, "offset", original_offset, 0.03)
