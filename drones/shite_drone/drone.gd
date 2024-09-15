extends CharacterBody3D


signal has_been_shot(collision_point, collision_normal)

var player: CharacterBody3D

var drone_ragdoll_PS: PackedScene = preload("res://drones/shite_drone/drone_ragdoll.tscn")

@export var detection_pulse_audio: AudioStreamPlayer3D
@export var bullet_hit_audio: AudioStreamPlayer3D
@export var bullet_hit_particles: GPUParticles3D
@export var smoke_particles: GPUParticles3D
@export var smoke_sound: AudioStreamPlayer3D


@export var detection_pulse_range = 30 # metres
@export var detection_pulse_speed = 3 # time it takes to travel d_p_r distance
var delay_before_pulse := 1.49 # sec

var health = 3

var is_hunting = false

var is_downed = false

func _ready() -> void:
	has_been_shot.connect(deal_damage)
	oscilate()

func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_key"):
		emit_detection_pulse()


func oscilate():
	if not is_downed:
		var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		var initial_pos =global_position.y
		tween.tween_property(self, "position:y", initial_pos - 0.4, 1.5)
		tween.tween_property(self, "position:y", initial_pos, 1.5)
		tween.tween_callback(oscilate)

func emit_detection_pulse():
	$DetectionPulse.scale = Vector3(3,3,3)
	$DetectionPulse.mesh.material.albedo_color = Color("9cffff58")
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	var scaling_ratio = detection_pulse_range/$DetectionPulse.mesh.radius
	detection_pulse_audio.play()
	tween.tween_interval(delay_before_pulse)
	
	tween.tween_callback(func(): $DetectionPulse.set_visible(true))
	tween.tween_property($DetectionPulse, "scale", Vector3(scaling_ratio, scaling_ratio, scaling_ratio), detection_pulse_speed).from_current()
	tween.set_parallel()
	tween.tween_property($DetectionPulse.mesh.material, "albedo_color", Color("9cffff00"), detection_pulse_speed)
	tween.set_parallel(false)
	tween.tween_callback(func(): $DetectionPulse.set_visible(false))

func _physics_process(_delta: float) -> void:
	if is_hunting:
		velocity = (player.global_position - global_position).normalized() * 5
		look_at(player.position)
		move_and_slide()

func start_hunting():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "basis", Basis.looking_at(global_position.direction_to(player.position)), 1)
	tween.tween_callback(func(): is_hunting = true)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Character":
		player = body
		start_hunting()

func deal_damage(collision_point, _collision_normal):
	bullet_hit_audio.play()
	var hit_vector:Vector3 = (player.global_position-collision_point).normalized() * 1.5
	bullet_hit_particles.global_position = collision_point
	bullet_hit_particles.process_material.direction = Vector3(hit_vector.x, 2, hit_vector.z)
	bullet_hit_particles.restart()
	health -= 1
	if health == 1:
		smoke_particles.emitting = true
		smoke_sound.play()
	elif health == 0:
		drone_terminated()

func drone_terminated():
	visible = false
	var drone_ragdoll_instance:RigidBody3D = drone_ragdoll_PS.instantiate()
	drone_ragdoll_instance.global_position = global_position
	drone_ragdoll_instance.rotation = rotation
	get_parent().add_child(drone_ragdoll_instance)
	drone_ragdoll_instance.apply_impulse((player.global_position - global_position).normalized() * 8)
	queue_free()
