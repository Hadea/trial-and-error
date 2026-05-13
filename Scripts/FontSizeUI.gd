extends Node

@export_category("Element for size selection")
@export var SizeSelectOptionButton: OptionButton

@export_category("Element for size change reception")
@export var SizeSelectLabel: Label

const UIFontSizeDefault: int = 16
@export var UIFontSizeCurrent: int = 16
	#set(value):
		## some object reference get the data
	#get:
		#return UIFontSizeCurrent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_size_change(index: int) -> void:
	SizeSelectLabel.add_theme_font_size_override("font_size", index*4+12)
	
