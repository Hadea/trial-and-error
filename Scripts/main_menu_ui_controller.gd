extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and  event.keycode == KEY_ESCAPE:
		_on_exit_button()

func _on_cleaning_game_button() -> void:
	get_tree().change_scene_to_file("res://Scenes/CleaningGame.tscn")

func _on_load_game_button() -> void:
	pass # just showing how disabled buttons work, no code needed

func _on_options_button() -> void:
	get_tree().change_scene_to_file("res://Scenes/FontSizeUI.tscn")

func _on_exit_button() -> void:
	get_tree().quit()


func _on_navigation_game_button() -> void:
	get_tree().change_scene_to_file("res://Scenes/NavigationGame.tscn")
