extends RigidBody3D

@export var zap_damage_amount = 5

func _ready() -> void:
	$ElectricityAudio.play()
	$GPUParticles3D.set_emitting(true)

func _on_timer_timeout() -> void:
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_signal("damage_given"):
		body.emit_signal("damage_given", zap_damage_amount)
