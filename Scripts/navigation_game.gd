extends Node2D

@export var NavigationTargetArray: Array[Vector2]
@export var CharacterSpawner: Array[Node2D]
@export var DebugLabel: Label


func _ready() -> void:
	for subNode in get_children():
		if "Shelf" in subNode.name:
			NavigationTargetArray.push_back(subNode.NavigationTarget)
		if "SpawnerNode2D" in subNode.name:
			CharacterSpawner.push_back(subNode)
	

func _process(delta: float) -> void:
	DebugLabel.text = "Current Player\n"
	for spawner in CharacterSpawner:
		for character in spawner.CharacterArray:
			DebugLabel.text += str(floor(character.transform.origin)) + " " + str(Constants.CharacterStatus.keys()[character.CurrentCharacterStatus]) + "\n"


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://Scenes/MainMenuUI.tscn")


func _on_timer_timeout() -> void: ## If Timer has reached end and spawns a character
	for spawner in CharacterSpawner:
		spawner.Spawn()
	
	
func _on_debug_kill_all_button() -> void:
	for spawner in CharacterSpawner:
		spawner.KillAll()
