extends Node2D

# external data
@export_group("Dust Remover Properties")
@export var ToolDustSprite: Sprite2D
@export var ToolDustStrength: float ## alpha change per second on the dust layer
@export var ToolDustSize: int ## radius in pixel affected by cleaning
@export var ToolDustGradient: bool ## if set to true, a linear gradient will be used
@export var DustSprite: Image
@export var DustCompletionProgressBar: ProgressBar
@export_group("Stain Remover Properties")
@export var ToolStainSprite: Sprite2D
@export var ToolStainStrength: float ## alpha change per second on the stain layer
@export var ToolStainSize: int ## radius in pixel affected by cleaning
@export var ToolStainGradient: bool ## if set to true, a linear gradient will be used
@export var StainSprite: Image
@export var StainCompletionProgressBar: ProgressBar
@export_group("Rubber Remover Properties")
@export var ToolRubberSprite: Sprite2D
@export var ToolRubberStrength: float ## alpha change per second on the rubber layer
@export var ToolRubberSize: int ## radius in pixel affected by cleaning
@export var ToolRubberGradient: bool ## if set to true, a linear gradient will be used
@export var RubberSprite: Image
@export var RubberCompletionProgressBar: ProgressBar
@export_group("Wax Adder Properties")
@export var ToolWaxSprite: Sprite2D
@export var ToolWaxStrength: float ## alpha change per second on the wax layer
@export var ToolWaxSize: int ## radius in pixel affected by cleaning
@export var ToolWaxGradient: bool ## if set to true, a linear gradient will be used
@export var WaxSprite: Image ## can be removed soon
@export var WaxColor: Color ## color replaces image
@export var WaxCompletionProgressBar: ProgressBar

@export_group("")
@export var Book: Sprite2D
@export var debugLabel: Label

# internal data
var isCleaning: bool = false
var eraserTransform: Transform2D
var pixelStatus: Array[Vector2i] = [Vector2i(0,0),Vector2i(0,0),Vector2i(0,0),Vector2i(0,0)] # tracks the amount of cleaned pixel , x current cleaned; y already clean at startup
var pixelAmount: int = 0
var selectedToolSprite: Sprite2D


enum cleaningLayers {DUST, STAIN, RUBBER, WAX}
var currentCleaningLayer: cleaningLayers = cleaningLayers.DUST

func _enter_tree() -> void:
	var texImage: ImageTexture = ImageTexture.create_from_image(DustSprite)
	Book.material.set_shader_parameter("DustTexture", texImage)
	texImage = ImageTexture.create_from_image(StainSprite)
	Book.material.set_shader_parameter("StainTexture", texImage)
	texImage = ImageTexture.create_from_image(RubberSprite)
	Book.material.set_shader_parameter("RubberTexture", texImage)
	texImage = ImageTexture.create_from_image(WaxSprite)
	Book.material.set_shader_parameter("WaxTexture", texImage)
	
	pixelStatus[cleaningLayers.DUST].y = _getCleanedPixelCount(cleaningLayers.DUST)
	pixelStatus[cleaningLayers.STAIN].y = _getCleanedPixelCount(cleaningLayers.STAIN)
	pixelStatus[cleaningLayers.RUBBER].y = _getCleanedPixelCount(cleaningLayers.RUBBER)
	pixelStatus[cleaningLayers.WAX].y = _getCleanedPixelCount(cleaningLayers.WAX)
	
	pixelAmount = DustSprite.get_width() * DustSprite.get_height();	
	eraserTransform = ToolDustSprite.transform #backup of the original transform for scaling relative to original size
	_on_cleaning_technique_selected(cleaningLayers.DUST)

func _process(delta: float) -> void:
	selectedToolSprite.position = get_viewport().get_mouse_position() - Vector2(ToolDustSprite.get_rect().get_center())

	if isCleaning:
		debugLabel.text = "cleaning "+str(cleaningLayers.keys()[currentCleaningLayer])
		var cleanPosWorld = get_viewport().get_mouse_position()
		var cleanPosBook = cleanPosWorld - Book.position + (Book.get_rect().size/2)
		_cleanAtCoords(delta, cleanPosBook)
	else:
		debugLabel.text="idle"


func _cleanAtCoords(delta: float, coords: Vector2) -> void:
	# selecting correct texture to work on
	var imageToProcess: Image
	match currentCleaningLayer:
		cleaningLayers.DUST:
			imageToProcess = DustSprite

			_cleanCircular(imageToProcess, coords, ToolDustSize, ToolDustStrength * delta, ToolDustGradient)
			var sprite:  ImageTexture = ImageTexture.create_from_image(imageToProcess)
			Book.material.set_shader_parameter("DustTexture", sprite)
			
		cleaningLayers.STAIN:
			imageToProcess = StainSprite
			_cleanCircular(imageToProcess, coords, ToolStainSize, ToolStainStrength * delta, ToolStainGradient)
			var sprite:  ImageTexture = ImageTexture.create_from_image(imageToProcess)
			Book.material.set_shader_parameter("StainTexture", sprite)
			
		cleaningLayers.RUBBER:
			imageToProcess = RubberSprite
			_cleanCircular(imageToProcess, coords, ToolRubberSize, ToolRubberStrength * delta, ToolRubberGradient)
			var sprite:  ImageTexture = ImageTexture.create_from_image(imageToProcess)
			Book.material.set_shader_parameter("RubberTexture", sprite)

		cleaningLayers.WAX:
			imageToProcess = WaxSprite
			_cleanCircular(imageToProcess, coords, ToolWaxSize, ToolWaxStrength * delta, ToolWaxGradient)
			var sprite:  ImageTexture = ImageTexture.create_from_image(imageToProcess)
			Book.material.set_shader_parameter("WaxTexture", sprite)

		_:
			print("Broken cleaning Layer selection")
			pass # quit when unknown tool selected
	# updating UI	
	pixelStatus[currentCleaningLayer].x = _getCleanedPixelCount(currentCleaningLayer)
	_updateProgress()

	
func _updateProgress() -> void: ## updates all progress bars to the current value of the cleaning progress
	DustCompletionProgressBar.value = 100.0 / (pixelAmount-pixelStatus[cleaningLayers.DUST].y) * (pixelStatus[cleaningLayers.DUST].x - pixelStatus[cleaningLayers.DUST].y)
	StainCompletionProgressBar.value = 100.0 / (pixelAmount-pixelStatus[cleaningLayers.STAIN].y) * (pixelStatus[cleaningLayers.STAIN].x - pixelStatus[cleaningLayers.STAIN].y)
	RubberCompletionProgressBar.value = 100.0 / (pixelAmount-pixelStatus[cleaningLayers.RUBBER].y) * (pixelStatus[cleaningLayers.RUBBER].x - pixelStatus[cleaningLayers.RUBBER].y)
	WaxCompletionProgressBar.value = 100.0 / (pixelAmount-pixelStatus[cleaningLayers.WAX].y) * (pixelStatus[cleaningLayers.WAX].x - pixelStatus[cleaningLayers.WAX].y) # needs inversion since we want WAX everywhere


func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://Scenes/MainMenuUI.tscn")
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			isCleaning = true
		if event.is_released():
			isCleaning = false


func _getCleanedPixelCount(layerToCount: cleaningLayers) -> int:
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


func _cleanCircular(imageToClean: Image, coords: Vector2i, radius: int, strength: float, gradient: bool):
	var r2: int = radius * radius
	
	for y in range(coords.y-radius, coords.y+radius):
		if y < 0 or y > imageToClean.get_height()-1: # skip if out of image bounds
			continue
		for x in range(coords.x - radius, coords.x + radius):
			if x < 0 or x > imageToClean.get_width()-1: # skip if out of image bounds
				continue
				
			# check if within distance of center point
			
			var dotX: int = x - coords.x
			var dotY: int = y - coords.y
			var distance2: int = dotX * dotX + dotY * dotY 
			if distance2 <= r2:
				var currentPixel: Color = imageToClean.get_pixel(x,y)
				if gradient:
					currentPixel.a= max(0, currentPixel.a - strength * (r2 / max(distance2,0.01)))
				else:
					currentPixel.a= max(0, currentPixel.a - strength)
				
				imageToClean.set_pixel(x, y, currentPixel)


func _on_cleaning_technique_selected(index: int) -> void:
	currentCleaningLayer = index
	ToolDustSprite.visible = false
	ToolRubberSprite.visible = false
	ToolStainSprite.visible = false
	ToolWaxSprite.visible = false
	match currentCleaningLayer:
		cleaningLayers.DUST:
			selectedToolSprite = ToolDustSprite
		cleaningLayers.STAIN:
			selectedToolSprite = ToolStainSprite
		cleaningLayers.RUBBER:
			selectedToolSprite = ToolRubberSprite
		cleaningLayers.WAX:
			selectedToolSprite = ToolWaxSprite
		_:
			print("unknown tool selected")
			pass
	selectedToolSprite.visible = true
	isCleaning = false
