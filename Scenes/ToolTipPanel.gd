class_name ToolTipPanel
extends Panel

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@export var swapOffset: Vector2
const offset: Vector2 = Vector2(20,20)


func _input(event: InputEvent) -> void:
	if not visible: return
	if not event is InputEventMouseMotion: return

	var eventMouse: InputEventMouseMotion = event
	var centerDirection: Vector2 = eventMouse.position.direction_to(get_viewport_rect().size - swapOffset)

	centerDirection.x = 1 if centerDirection.x >= 0 else -1
	centerDirection.y = 1 if centerDirection.y >= 0 else -1
	position = eventMouse.position + centerDirection * (self.size/2.0 + offset)
