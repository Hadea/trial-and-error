extends Node

enum Themes {ALPHA, BRAVO}
var ThemesArray: Array[Theme] = [preload("res://ProjectTheme.tres"), preload("res://ProjectThemeBeta.tres")]
var CurrentTheme: Theme


func SetTheme(newThemeID: Themes) -> void:
	CurrentTheme = ThemesArray[newThemeID]


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_scene_added)


func _on_scene_added(newNode: Node) -> void:
	if not CurrentTheme: SetTheme(Themes.ALPHA)

	if newNode == get_tree().current_scene or newNode.get_parent() == get_tree().root:
		if newNode is Control:
			newNode.theme = CurrentTheme
