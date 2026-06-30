extends Area2D
## Rum Bottle - Health pickup that restores 1 HP

var bob_time := 0.0
var initial_y := 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	initial_y = position.y
	bob_time = randf() * TAU
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	bob_time += delta * 2.5
	position.y = initial_y + sin(bob_time) * 1.5
	animated_sprite.rotation = sin(bob_time * 0.7) * 0.05


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.heal(1)
		_collect_effect()


func _collect_effect() -> void:
	set_deferred("monitoring", false)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.15)
	await tween.finished
	queue_free()
