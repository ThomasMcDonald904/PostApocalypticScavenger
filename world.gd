extends Node3D

func _ready() -> void:
	for child in get_children():
		if child.is_in_group("player_hunter"):
			child.player = $Character


func _on_child_entered_tree(node: Node) -> void:
	if node.is_in_group("player_hunter"):
		node.player = $Character
