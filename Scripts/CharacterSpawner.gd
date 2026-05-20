extends Node2D

@export var CharacterScene: Resource = preload("res://Scenes/character.tscn")
var CharacterArray: Array[Node2D]

func Spawn():
	var newCharacter: Node2D = preload("res://Scenes/character.tscn").instantiate() as Node2D
	newCharacter.transform.origin = transform.origin
	CharacterArray.push_back(newCharacter)
	get_parent().add_child(newCharacter)
	newCharacter.NavigationTargetArray = get_parent().NavigationTargetArray # forwarding the targets in the scene
	newCharacter.CharacterSpawner = self


func KillCharacter(character: Node2D):
	CharacterArray.erase(character)
	character.queue_free()
	
func KillAll():
	for charToKill in CharacterArray:
		charToKill.queue_free()
	CharacterArray.clear()
