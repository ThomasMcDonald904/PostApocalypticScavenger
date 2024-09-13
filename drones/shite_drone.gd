extends CharacterBody3D


var player: CharacterBody3D

@export var detection_pulse_range = 30 # metres
@export var detection_pulse_speed = 3 # time it takes to travel d_p_r distance
var delay_before_pulse := 1.49 # sec

var is_hunting = false

func _ready() -> void:
	oscilate()

func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_key"):
		emit_detection_pulse()


func oscilate():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	var initial_pos =global_position.y
	tween.tween_property(self, "position:y", initial_pos - 0.4, 1.5)
	tween.tween_property(self, "position:y", initial_pos, 1.5)
	tween.tween_callback(oscilate)

func emit_detection_pulse():
	$DetectionPulse.scale = Vector3(1,1,1)
	$DetectionPulse.mesh.material.albedo_color = Color("9cffff58")
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	var scaling_ratio = detection_pulse_range/$DetectionPulse.mesh.radius
	$AudioStreamPlayer.play()
	tween.tween_interval(delay_before_pulse)
	tween.tween_property($DetectionPulse, "scale", Vector3(scaling_ratio, scaling_ratio, scaling_ratio), detection_pulse_speed).from_current()
	tween.set_parallel()
	tween.tween_property($DetectionPulse.mesh.material, "albedo_color", Color("9cffff00"), detection_pulse_speed)

func _physics_process(delta: float) -> void:
	if is_hunting:
		velocity = (player.global_position - global_position).normalized() * 8
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
