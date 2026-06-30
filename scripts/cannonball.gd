extends Area2D
## Cannonball projectile - damages player on contact

var direction := Vector2.RIGHT
var speed := 150.0
var lifetime := 5.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var trail_particles: GPUParticles2D = $TrailParticles


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	trail_particles.emitting = true
	# Auto destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	_explode()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	rotation += delta * 5.0  # Spin


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var knockback := direction
		if body.has_method("take_damage"):
			body.take_damage(1, knockback)
		_explode()
	elif body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(2, direction)
		_explode()
	elif not body.is_in_group("cannonball"):
		_explode()


func _explode() -> void:
	set_deferred("monitoring", false)
	animated_sprite.visible = false
	trail_particles.emitting = false

	# Explosion particles
	var explosion := GPUParticles2D.new()
	explosion.amount = 12
	explosion.one_shot = true
	explosion.emitting = true
	explosion.lifetime = 0.4
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 30.0
	mat.initial_velocity_max = 60.0
	mat.gravity = Vector3(0, 100, 0)
	mat.color = Color(0.9, 0.5, 0.1)
	explosion.process_material = mat
	add_child(explosion)

	await get_tree().create_timer(0.5).timeout
	queue_free()
