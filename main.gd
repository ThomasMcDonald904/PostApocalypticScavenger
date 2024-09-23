extends Node

@export var world:Node3D


func _ready() -> void:
	world.get_node("Character").connect("death", player_dead)
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("debug_key"):
		#player_dead()

func player_dead():
	$SceneFade.play("fade_scene")
	await $SceneFade.animation_finished 
	$GUI.mouse_filter = Control.MouseFilter.MOUSE_FILTER_STOP
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$GUI.visible = true
	world.get_node("Character").get_node("MeshInstance3D").mesh.material.albedo_color = Color.DARK_RED
	world.get_node("Character").get_node("DeathCamera").set_current(true)
	await get_tree().create_timer(1).timeout
	$SceneFade.play_backwards("fade_scene")


func _on_button_button_up() -> void:
	get_tree().reload_current_scene()
