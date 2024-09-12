extends CharacterBody3D

@export var nav_agent: NavigationAgent3D

var player: CharacterBody3D

func _ready() -> void:
	$AnimationPlayer.play("oscilate")

func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	if player != null:
		nav_agent.set_target_position(player.global_position)
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_position).normalized()
