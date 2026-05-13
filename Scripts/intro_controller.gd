extends Node2D

@export var IntroLength: float = 5 # time until main menu is loaded
var IntroTimeElapsed: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	IntroTimeElapsed += delta
	if IntroTimeElapsed > IntroLength:
		get_tree().change_scene_to_file("res://Scenes/MainMenuUI.tscn")
	pass

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		IntroTimeElapsed = IntroLength # sets the elaped time to the maximum to switch scenes
