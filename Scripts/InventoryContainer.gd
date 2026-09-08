class_name InventoryContainer
extends Panel

var book: BookColorRect
@onready var inventory_game: InventoryGame = $"../../.."


func _ready() -> void:
	mouse_entered.connect(_on_panel_mouse_entered)
	#mouse_exited.connect(_on_panel_mouse_exited)

	if get_child_count() == 1:
		book = get_child(0) as BookColorRect



func _get_drag_data(_at_position: Vector2) -> Variant:
	if not book: return #empty slot has nothing to drag
	var preview: BookColorRect = book.duplicate()
	set_drag_preview(preview)
	return book


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return true if data is ColorRect else false


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var SourceSlot: Panel = data.get_parent()
	SourceSlot.remove_child(data) #detaching dragged book
	if book: # if book is already occupying slot move it to source.
		self.remove_child(book)
		SourceSlot.add_child(book)
		SourceSlot.book = book
	add_child(data)
	book = data as BookColorRect


func _on_panel_mouse_entered() -> void:
	if book:
		inventory_game.showToolTip(book)


func _on_panel_mouse_exited() -> void:
	inventory_game.hideToolTip()
