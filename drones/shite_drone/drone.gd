extends CharacterBody3D


signal has_been_shot(collision_point, collision_normal)

var player: CharacterBody3D

var drone_ragdoll_PS: PackedScene = preload("res://drones/shite_drone/drone_ragdoll.tscn")
var zap_ball_PS: PackedScene = preload("res://drones/shite_drone/zap_ball.tscn")

@export var detection_pulse_audio: AudioStreamPlayer3D
@export var bullet_hit_audio: AudioStreamPlayer3D
@export var bullet_hit_particles: GPUParticles3D
@export var smoke_particles: GPUParticles3D
@export var smoke_sound: AudioStreamPlayer3D
@export var zap_ball_emitter_position: Marker3D


@export var detection_pulse_range = 30 # metres
@export var detection_pulse_speed = 3 # time it takes to travel d_p_r distance
@export var speed_multiplier = 5
@export var minimum_attack_distance = 20
var delay_before_pulse := 1.49 # sec

var health = 3

var can_emit_zap_balls = true
var current_nbr_launched_zap_ball = 0
var max_nbr_launched_zap_balls = 3

var is_hunting = false
var is_downed = false
var finished_wander_sequence = true

@export_category("Wander Parameters")
@export var drone_wander_interval_time := 10
@export var drone_wander_angle_time := 3
@export var drone_wander_distance := 10
@export var drone_wander_distance_time := 10

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
		velocity = (player.global_position - global_position).normalized() * speed_multiplier
		look_at(player.position)
		if position.distance_to(player.position) <= minimum_attack_distance and current_nbr_launched_zap_ball < max_nbr_launched_zap_balls and can_emit_zap_balls:
			can_emit_zap_balls = false
			$ZapBallEmissionCooldown.start()
			launch_zap_ball()
			max_nbr_launched_zap_balls += 1
		move_and_slide()
	elif finished_wander_sequence:
		wander()

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
	$CollisionShape3D.disabled = true
	var drone_ragdoll_instance:RigidBody3D = drone_ragdoll_PS.instantiate()
	get_parent().add_child(drone_ragdoll_instance)
	drone_ragdoll_instance.global_position = global_position
	drone_ragdoll_instance.rotation = rotation
	drone_ragdoll_instance.apply_impulse((player.global_position - global_position).normalized() * 8)
	await bullet_hit_audio.finished
	queue_free()

func launch_zap_ball():
	var zap_ball_instance: RigidBody3D = zap_ball_PS.instantiate()
	get_parent().add_child(zap_ball_instance)
	zap_ball_instance.global_position = zap_ball_emitter_position.global_position
	zap_ball_instance.apply_impulse((zap_ball_emitter_position.global_position - global_position)*7)


func _on_zap_ball_emission_cooldown_timeout() -> void:
	can_emit_zap_balls = true

func wander() -> void:
	# Pick random direction 
	var random_angle = randi_range(0, 2*PI)
	var random_pos := Vector3(cos(random_angle), 0, sin(random_angle))
	print(rad_to_deg(position.angle_to(random_pos)), position + random_pos*drone_wander_distance)
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	var before_rot = rotation
	look_at(position+random_pos)
	var after_rot = rotation
	rotation = before_rot
	tween.tween_property(self, "rotation", after_rot, drone_wander_angle_time)
	
	tween.tween_interval(randi_range(drone_wander_interval_time * 0.5, drone_wander_interval_time))
	
	# Go to random position
	tween.tween_property(self, "global_position", global_position + random_pos * drone_wander_distance, drone_wander_distance_time).from_current()

	tween.tween_callback(func(): finished_wander_sequence = true)
	finished_wander_sequence = false
