class_name ToolTipPanel
extends Panel

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@export var swapOffset: Vector2
const offset: Vector2 = Vector2(50,50)


func _input(event: InputEvent) -> void:
	if not visible: return
	if not event is InputEventMouseMotion: return

	var eventMouse: InputEventMouseMotion = event

	var centerDirection: Vector2 = eventMouse.position.direction_to(get_viewport_rect().get_center() + swapOffset)
	centerDirection.x = ceilf(centerDirection.x) if centerDirection.x >= 0 else floor(centerDirection.x)
	centerDirection.y = ceilf(centerDirection.y) if centerDirection.y >= 0 else floor(centerDirection.y)
	position = eventMouse.position + centerDirection * offset
