extends Control

@export_category("Element for size selection")
@export var SizeSelectOptionButton: OptionButton

@export_category("Element for size change reception")
@export var SizeSelectLabel: Label

const UIFontSizeDefault: int = 16
@export var UIFontSizeCurrent: int = 16

@export var ProjectThemeFile: Resource = preload("res://ProjectTheme.tres")
@export var FontA: Font
@export var FontB: Font


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey: return # early exit if not for us
	var KeyEvent = event as InputEventKey
	if KeyEvent.keycode == Key.KEY_ESCAPE && KeyEvent.pressed:
		get_tree().change_scene_to_file("res://Scenes/MainMenuUI.tscn")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_size_change(index: int) -> void:
	SizeSelectLabel.add_theme_font_size_override("font_size", index*4+12)


func _on_button_font_a_toggled(toggled_on: bool) -> void:
	ProjectThemeFile.set_default_font(FontA)


func _on_button_font_b_toggled(toggled_on: bool) -> void:
	ProjectThemeFile.set_default_font(FontB)
