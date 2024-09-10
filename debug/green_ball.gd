extends StaticBody3D

signal has_been_shot(collision_point)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	has_been_shot.connect(shot)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func shot(_collision_point):
	scale = Vector3(3,3,3)
