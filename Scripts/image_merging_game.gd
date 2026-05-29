extends Node2D

@export var BackGroundSprite: Sprite2D
@export var BrushA: Sprite2D
@export var BrushB: Sprite2D
@export var ButtonA: Button
@export var ButtonB: Button
@export var BrushButtonGroup: ButtonGroup
@export var DebugLabel: Label

var backgroundImage: Image
var brushAImage: Image
var brushBImage: Image

enum LayerSeletion {BrushA, BrushB, None}
var currentLayer: LayerSeletion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# preparing scene
	ButtonA.button_pressed = false
	ButtonB.button_pressed = false
	BrushA.visible = false
	BrushB.visible = false
	currentLayer = LayerSeletion.None
#	BrushButtonGroup.connect("pressed", _on_group_button_pressed)
	
	#caching images for manipulation
	backgroundImage = BackGroundSprite.texture.get_image()
	brushAImage = BrushA.texture.get_image()
	brushBImage = BrushB.texture.get_image()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match currentLayer:
		LayerSeletion.BrushA:
			BrushA.position = get_viewport().get_mouse_position()
		LayerSeletion.BrushB:
			BrushB.position = get_viewport().get_mouse_position()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var curEvent: InputEventMouseButton = event as InputEventMouseButton
		DebugLabel.text = "mouse"
		if curEvent.button_index == MouseButton.MOUSE_BUTTON_LEFT and curEvent.pressed:
			# color this shit
			match currentLayer:
				LayerSeletion.BrushA:
					_apply_alpha_from_brush(backgroundImage, Vector2i(get_viewport().get_mouse_position()) - brushAImage.get_size()/2, brushAImage)
					DebugLabel.text = "painting A"
				LayerSeletion.BrushB:
					_apply_alpha_from_brush(backgroundImage, Vector2i(get_viewport().get_mouse_position()) - brushBImage.get_size()/2, brushBImage)
					DebugLabel.text = "painting B"
				_:
					DebugLabel.text = "no painting"
			BackGroundSprite.texture = ImageTexture.create_from_image(backgroundImage)
	if event is InputEventKey:
		var curEvent: InputEventKey = event as InputEventKey
		if curEvent.pressed and curEvent.keycode == Key.KEY_ESCAPE:
			get_tree().change_scene_to_file("res://Scenes/MainMenuUI.tscn")

func _on_group_button_pressed(pressedButton: BaseButton):
	pass


func _on_brush_a_button_toggled(toggled_on: bool) -> void:
	BrushA.visible = toggled_on
	BrushB.visible = false
	if toggled_on:
		currentLayer = LayerSeletion.BrushA
	else:
		currentLayer = LayerSeletion.None

func _on_brush_b_button_toggled(toggled_on: bool) -> void:
	BrushA.visible = false
	BrushB.visible = toggled_on
	if toggled_on:
		currentLayer = LayerSeletion.BrushB
	else:
		currentLayer = LayerSeletion.None


func _apply_alpha_from_brush(targetImage: Image, targetPosition: Vector2i,  brush: Image):

	var targetX: int
	var targetY: int
	var targetColor: Color

	for brushY in brush.get_height():
		for brushX in brush.get_width():
			targetX = brushX + targetPosition.x
			targetY = brushY + targetPosition.y
			if targetX < 0 or targetY < 0 or targetY >= targetImage.get_height() or targetX >= targetImage.get_width(): continue  # skip pixel outside of image
			# blending of two pixel
			targetColor = targetImage.get_pixel(targetX,targetY)
			targetColor.a = min(1.0 - brush.get_pixel(brushX,brushY).a, targetColor.a)
			targetImage.set_pixel(targetX, targetY, targetColor)
