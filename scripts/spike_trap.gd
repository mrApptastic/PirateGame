extends Node2D
## Spike Trap - Extends and retracts on a timer

@export var extend_time := 1.5
@export var retract_time := 2.0
@export var damage := 1

var is_extended := false
var timer := 0.0

@onready var spikes: Area2D = $Spikes
@onready var spike_visual: ColorRect = $SpikeVisual


func _ready() -> void:
	spikes.body_entered.connect(_on_body_entered)
	timer = retract_time * randf()  # Random start offset


func _physics_process(delta: float) -> void:
	timer -= delta

	if timer <= 0:
		is_extended = !is_extended
		timer = extend_time if is_extended else retract_time
		_update_visual()

	# Warning flash before extending
	if not is_extended and timer < 0.5:
		spike_visual.modulate.a = 0.5 + sin(timer * 20) * 0.3


func _update_visual() -> void:
	if is_extended:
		spike_visual.modulate.a = 1.0
		spike_visual.size.y = 8
		spikes.set_deferred("monitoring", true)
	else:
		spike_visual.modulate.a = 0.3
		spike_visual.size.y = 2
		spikes.set_deferred("monitoring", false)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_extended:
		if body.has_method("take_damage"):
			var knockback := (body.global_position - global_position).normalized()
			body.take_damage(damage, knockback)
