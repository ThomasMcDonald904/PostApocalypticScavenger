extends Node3D

func _ready() -> void:
	for child in $NavigationRegion3D.get_children():
		if child.is_in_group("player_hunter"):
			child.player = $Character
