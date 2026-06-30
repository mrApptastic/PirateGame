extends Node2D
## Cannon Hazard - Fires cannonballs at regular intervals

@export var fire_direction := Vector2.RIGHT
@export var fire_interval := 3.0
@export var cannonball_speed := 150.0
@export var fire_delay := 0.0  # Offset timing

var timer := 0.0
var warning_timer := 0.0
var is_warning := false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var smoke_particles: GPUParticles2D = $SmokeParticles


func _ready() -> void:
	timer = fire_delay
	animated_sprite.flip_h = fire_direction.x < 0


func _physics_process(delta: float) -> void:
	timer += delta

	# Warning flash before firing
	if timer >= fire_interval - 0.5 and not is_warning:
		is_warning = true
		animated_sprite.modulate = Color(1, 0.6, 0.3)

	if timer >= fire_interval:
		_fire()
		timer = 0.0
		is_warning = false
		animated_sprite.modulate = Color.WHITE


func _fire() -> void:
	animated_sprite.play("Fire")
	smoke_particles.emitting = true

	var cannonball := preload("res://scenes/environment/cannonball.tscn").instantiate()
	cannonball.global_position = muzzle.global_position
	cannonball.direction = fire_direction.normalized()
	cannonball.speed = cannonball_speed
	get_parent().add_child(cannonball)

	# Recoil effect
	var tween := create_tween()
	tween.tween_property(self, "position", position - fire_direction * 3, 0.05)
	tween.tween_property(self, "position", position, 0.2)
