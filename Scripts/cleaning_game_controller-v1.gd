extends Node2D

# external data
@export var EraserSprite: Sprite2D
@export var Book: Sprite2D
@export var BlendSprite: ImageTexture
@export var debugLabel: Label
@export var BrushSizeVSlider: VSlider
@export var CompletionProgressBar: ProgressBar

# internal data
var isCleaning: bool = false
var blendImage: Image
var cleanPixelSize: int
var eraserTransform: Transform2D
var pixelAlreadyClean: int
var pixelAmount: int

func _enter_tree() -> void:
	blendImage = Image.load_from_file("res://Ressources/BlendMap.bmp")
	BlendSprite = ImageTexture.create_from_image(blendImage)
	Book.material.set_shader_parameter("BlendTexture", BlendSprite)
	
	pixelAlreadyClean = getCleanedPixelCount()
	pixelAmount = blendImage.get_width() * blendImage.get_height();	
	eraserTransform = EraserSprite.transform
	BrushSizeVSlider.value = 20

func _process(delta: float) -> void:
	EraserSprite.position = get_viewport().get_mouse_position() - Vector2(EraserSprite.get_rect().get_center())
	if isCleaning:
		debugLabel.text = "cleaning"
		var cleanPosWorld = get_viewport().get_mouse_position()
		var cleanPosBook = cleanPosWorld - Book.position + (Book.get_rect().size/2)
		
		_cleanAtCoords(cleanPosBook)
		# sending modified image to shader
		BlendSprite = ImageTexture.create_from_image(blendImage)
		Book.material.set_shader_parameter("BlendTexture", BlendSprite)
	else:
		debugLabel.text="idle"


func _cleanAtCoords(coords: Vector2) -> void:
	for y in range(coords.y-cleanPixelSize, coords.y+cleanPixelSize):
		if y < 0 or y > blendImage.get_height()-1:
			continue
		for x in range(coords.x - cleanPixelSize, coords.x + cleanPixelSize):
			if x < 0 or x > blendImage.get_width()-1:
				continue
			blendImage.set_pixel(x, y, Color.WHITE)
	_updateProgress()
	
func _updateProgress() -> void:
	CompletionProgressBar.value = 100.0 / (pixelAmount-pixelAlreadyClean) * (getCleanedPixelCount() - pixelAlreadyClean)

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://Scenes/MainMenuUI.tscn")
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			isCleaning = true
		if event.is_released():
			isCleaning = false
		
func getCleanedPixelCount() -> int:
	var cleanPixel : int = 0
	for y in blendImage.get_height():
		for x in blendImage.get_width():
			if blendImage.get_pixel(x,y) == Color.WHITE:
				cleanPixel+=1
	return cleanPixel

func _on_brush_size_v_slider_value_changed(value: float) -> void:
	cleanPixelSize = int(value)
	EraserSprite.transform = eraserTransform.scaled_local(Vector2(value / 50, value / 50))
