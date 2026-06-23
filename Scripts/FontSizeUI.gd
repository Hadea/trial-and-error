extends Control

@export_category("Element for size selection")
@export var SizeSelectOptionButton: OptionButton

@export_category("Element for size change reception")
@export var SizeSelectLabel: Label

const UIFontSizeDefault: int = 16
@export var UIFontSizeCurrent: int = 16

@export var ProjectThemeFile: Resource = preload("res://ProjectTheme.tres")
@export var ProjectThemeBetaFile: Resource = preload("res://ProjectThemeBeta.tres")

@export var FontA: Font
@export var FontB: Font
@export var FontC: Font
@export var FontD: Font


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey: return # early exit if not for us
	var KeyEvent = event as InputEventKey
	if KeyEvent.keycode == Key.KEY_ESCAPE && KeyEvent.pressed:
		get_tree().change_scene_to_file("res://Scenes/MainMenuUI.tscn")
	

func _on_size_change(index: int) -> void:
	SizeSelectLabel.add_theme_font_size_override("font_size", index*4+12)


func _on_button_font_a_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Globals.SetTheme(Globals.Themes.ALPHA)
		theme = Globals.CurrentTheme


func _on_button_font_b_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Globals.SetTheme(Globals.Themes.BRAVO)
		theme = Globals.CurrentTheme
