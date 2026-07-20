extends Panel

var book: ColorRect


func _ready() -> void:
	if get_child_count() == 1:
		book = get_child(0)



func _get_drag_data(_at_position: Vector2) -> Variant:
	if not book: return #empty slot has nothing to drag
	var preview = book.duplicate()
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
	book = data as ColorRect
