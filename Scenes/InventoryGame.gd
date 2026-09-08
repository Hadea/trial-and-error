class_name InventoryGame
extends Control

@export var tooltip: ToolTipPanel


func _ready() -> void:
	hideToolTip()


func showToolTip(bookToShow: BookColorRect) -> void:
	tooltip.rich_text_label.text = bookToShow.name + "\n" + bookToShow.Content
	tooltip.visible = true


func hideToolTip() -> void:
	tooltip.visible = false
	tooltip.rich_text_label.text = ""
