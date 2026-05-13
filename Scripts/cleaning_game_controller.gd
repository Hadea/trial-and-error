extends Node2D

# external data
@export var EraserSprite: Sprite2D
@export var Book: Sprite2D
@export var DustSprite: Image
@export var StainSprite: Image
@export var RubberSprite: Image
@export var WaxSprite: Image
@export var WaxColor: Color
@export var debugLabel: Label
@export var BrushSizeVSlider: VSlider
@export var DustCompletionProgressBar: ProgressBar
@export var StainCompletionProgressBar: ProgressBar
@export var RubberCompletionProgressBar: ProgressBar
@export var WaxCompletionProgressBar: ProgressBar

# internal data
var isCleaning: bool = false
var cleanPixelSize: int
var eraserTransform: Transform2D
var pixelStatus: Array[Vector2i] = [Vector2i(0,0),Vector2i(0,0),Vector2i(0,0),Vector2i(0,0)] # tracks the amount of cleaned pixel , x current cleaned; y already clean at startup
var pixelAmount: int = 0


enum cleaningLayers {DUST, STAIN, RUBBER, WAX}
var currentCleaningLayer: cleaningLayers = cleaningLayers.DUST

func _enter_tree() -> void:
	currentCleaningLayer = cleaningLayers.DUST
	Book.material.get("BookTexture")
	
	var texImage: ImageTexture = ImageTexture.create_from_image(DustSprite)
	Book.material.set_shader_parameter("DustTexture", texImage)
	texImage = ImageTexture.create_from_image(StainSprite)
	Book.material.set_shader_parameter("StainTexture", texImage)
	texImage = ImageTexture.create_from_image(RubberSprite)
	Book.material.set_shader_parameter("RubberTexture", texImage)
	texImage = ImageTexture.create_from_image(WaxSprite)
	Book.material.set_shader_parameter("WaxTexture", texImage)
	
	
	pixelStatus[cleaningLayers.DUST].y = getCleanedPixelCount(cleaningLayers.DUST)
	pixelStatus[cleaningLayers.STAIN].y = getCleanedPixelCount(cleaningLayers.STAIN)
	pixelStatus[cleaningLayers.RUBBER].y = getCleanedPixelCount(cleaningLayers.RUBBER)
	pixelStatus[cleaningLayers.WAX].y = getCleanedPixelCount(cleaningLayers.WAX)
	
	pixelAmount = DustSprite.get_width() * DustSprite.get_height();	
	eraserTransform = EraserSprite.transform
	BrushSizeVSlider.value = 20

func _process(delta: float) -> void:
	EraserSprite.position = get_viewport().get_mouse_position() - Vector2(EraserSprite.get_rect().get_center())
			
	if isCleaning:
		debugLabel.text = "cleaning "+str(cleaningLayers.keys()[currentCleaningLayer])
		var cleanPosWorld = get_viewport().get_mouse_position()
		var cleanPosBook = cleanPosWorld - Book.position + (Book.get_rect().size/2)
		_cleanAtCoords(cleanPosBook)
	else:
		debugLabel.text="idle"


func _cleanAtCoords(coords: Vector2) -> void:
	# selecting correct texture to work on
	var imageToProcess: Image
	match currentCleaningLayer:
		cleaningLayers.DUST:
			imageToProcess = DustSprite
		cleaningLayers.STAIN:
			imageToProcess = StainSprite
		cleaningLayers.RUBBER:
			imageToProcess = RubberSprite
		cleaningLayers.WAX:
			imageToProcess = WaxSprite
		_:
			print("Broken cleaning Layer selection")
			pass


	# cleaning on current layer if allowed?
	for y in range(coords.y-cleanPixelSize, coords.y+cleanPixelSize):
		if y < 0 or y > imageToProcess.get_height()-1:
			continue
		for x in range(coords.x - cleanPixelSize, coords.x + cleanPixelSize):
			if x < 0 or x > imageToProcess.get_width()-1:
				continue
			imageToProcess.set_pixel(x, y, Color.TRANSPARENT)
			
	var sprite:  ImageTexture = ImageTexture.create_from_image(imageToProcess)
	
	getCleanedPixelCount(currentCleaningLayer)
	# sending modified image to shader
	match currentCleaningLayer:
		cleaningLayers.DUST:
			Book.material.set_shader_parameter("DustTexture", sprite)
		cleaningLayers.STAIN:
			Book.material.set_shader_parameter("StainTexture", sprite)
		cleaningLayers.RUBBER:
			Book.material.set_shader_parameter("RubberTexture", sprite)
		cleaningLayers.WAX:
			Book.material.set_shader_parameter("WaxTexture", sprite)

	_updateProgress()
	
func _updateProgress() -> void: # updates the progressbar to the current value of the cleaning progress of a specific cleaning layer
	DustCompletionProgressBar.value = 100.0 / (pixelAmount-pixelStatus[cleaningLayers.DUST].y) * (pixelStatus[cleaningLayers.DUST].x - pixelStatus[cleaningLayers.DUST].y)
	DustCompletionProgressBar.value = 100.0 / (pixelAmount-pixelStatus[cleaningLayers.STAIN].y) * (pixelStatus[cleaningLayers.STAIN].x - pixelStatus[cleaningLayers.STAIN].y)
	DustCompletionProgressBar.value = 100.0 / (pixelAmount-pixelStatus[cleaningLayers.RUBBER].y) * (pixelStatus[cleaningLayers.RUBBER].x - pixelStatus[cleaningLayers.RUBBER].y)
	DustCompletionProgressBar.value = 100.0 / (pixelAmount-pixelStatus[cleaningLayers.WAX].y) * (pixelStatus[cleaningLayers.WAX].x - pixelStatus[cleaningLayers.WAX].y) # needs inversion since we want WAX everywhere
	#CompletionProgressBar.value = 100.0 / (pixelAmount-pixelAlreadyClean) * (getCleanedPixelCount() - pixelAlreadyClean) # old calc


func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://Scenes/MainMenuUI.tscn")
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			isCleaning = true
		if event.is_released():
			isCleaning = false
		
func getCleanedPixelCount(layerToCount: cleaningLayers) -> int:

	# selecting the image to process
	var imageToCount: Image
	match layerToCount:
		cleaningLayers.DUST:
			imageToCount = DustSprite
		cleaningLayers.STAIN:
			imageToCount = StainSprite
		cleaningLayers.RUBBER:
			imageToCount = RubberSprite
		cleaningLayers.WAX:
			imageToCount = WaxSprite



	var cleanPixel : int = 0
	for y in imageToCount.get_height()-1:
		for x in imageToCount.get_width()-1:
			if imageToCount.get_pixel(x,y).a == 0 :
				cleanPixel+=1
	return cleanPixel

func _on_brush_size_v_slider_value_changed(value: float) -> void:
	cleanPixelSize = int(value)
	EraserSprite.transform = eraserTransform.scaled_local(Vector2(value / 50, value / 50))


func _on_cleaning_technique_selected(index: int) -> void:
	currentCleaningLayer = index
	isCleaning = false
	pass # Replace with function body.
