extends Camera3D

@export var decay = 0.8  # How quickly the shaking stops [0, 1].
@export var max_offset = Vector2(0.2, 0.2)  # Maximum horizontal/vertical shake in pixels.
@export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).

var shake_strength = 0.0  # Current shake strength.
var shake_power = 3  # Trauma exponent. Use [2, 3].

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

func _process(delta):
	if shake_strength:
		shake_strength = max(shake_strength - decay * delta, 0)
		shake()

func shake():
	var amount = pow(shake_strength, shake_power)
	rotation.z = max_roll * amount * randf_range(-1, 1)
	h_offset = max_offset.x * amount * randf_range(-1, 1)
	v_offset = max_offset.y * amount * randf_range(-1, 1)

func add_shake(amount): # Value between 0 and 1
	if shake_strength <= amount/2:
		shake_strength = min(shake_strength + amount, 1.0)
