extends Node2D

@export var NavigationTarget: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NavigationTarget = $NavigationTargetNode2D.global_position
