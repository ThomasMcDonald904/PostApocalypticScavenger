extends CharacterBody3D


const AIM_SPEED = 1.5
const WALK_SPEED = 5.0
const SPRINT_SPEED = 9.0
const JUMP_VELOCITY = 4.5

var is_aiming = false

@export var normal_crosshair:Texture2D
@export var aiming_crosshair:Texture2D

@onready var rifle_carried_position:Vector3 = $Rifle.position
@onready var rifle_carried_rotation:Vector3 = $Rifle.rotation
@onready var rifle_equiped_position = $RifleEquipedPosition.position
@onready var rifle_equiped_rotation = $RifleEquipedPosition.rotation

@onready var camera_normal_position = $CameraOrigin/Camera3D.position
@onready var camera_aiming_position = $CameraAimingPosition.position

@onready var camera_origin := $CameraOrigin
@onready var camera := $CameraOrigin/Camera3D

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * 0.01)
			camera_origin.rotate_x(-event.relative.y * 0.01)
			camera_origin.rotation.x = clamp(camera_origin.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("aim") and not Input.is_action_pressed("sprint") or Input.is_action_just_pressed("shoot") and not Input.is_action_pressed("sprint"):
		var tween1 = get_tree().create_tween()
		var tween2 = get_tree().create_tween()
		if Input.is_action_just_pressed("aim"):
			is_aiming = true
			var tween3 = get_tree().create_tween()
			tween3.tween_property($CameraOrigin/Camera3D, "position", camera_aiming_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
			$CanvasLayer/Control/Crosshair.texture = aiming_crosshair
		tween1.tween_property($Rifle, "position", rifle_equiped_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		tween2.tween_property($Rifle, "rotation", rifle_equiped_rotation, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	elif Input.is_action_just_pressed("sprint") or Input.is_action_just_released("aim"):
		is_aiming = false
		var tween1 = get_tree().create_tween()
		var tween2 = get_tree().create_tween()
		var tween3 = get_tree().create_tween()
		tween1.tween_property($Rifle, "position", rifle_carried_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		tween2.tween_property($Rifle, "rotation", rifle_carried_rotation, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		tween3.tween_property($CameraOrigin/Camera3D, "position", camera_normal_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		$CanvasLayer/Control/Crosshair.texture = normal_crosshair

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var speed = AIM_SPEED if is_aiming else WALK_SPEED
	speed = SPRINT_SPEED if Input.is_action_pressed("sprint") and is_on_floor() else speed
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
