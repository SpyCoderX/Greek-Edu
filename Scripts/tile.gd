extends Sprite2D
class_name Tile


@export var Offset : Vector2 = Vector2(0,-64)

var isPressed : bool = false
var contactPoint : Vector2
var lowerArea : Control
@export var text : Label
var Character : Letter:
	set(new_letter):
		Character = new_letter
		if text!=null:
			updateText()

var target_position : Vector2
var target_scale : Vector2
var deleted : bool = false
var isTileGenerator : bool = false
var isUpper : bool = false:
	set(new_upper):
		isUpper = new_upper
		if text!=null:
			updateText()
func _ready() -> void:
	updateVisuals()

func _process(delta: float) -> void:
	if deleted: return
	scale = (scale+target_scale)/2.0
	if isTileGenerator: return
	if isPressed:
		target_position = get_global_mouse_position()-contactPoint-(global_position-position)+Offset
	position = (position+target_position)/2.0

func updateText():
	text.text = Character.Upper if isUpper else Character.Lower
	

func _input(event: InputEvent) -> void:
	if deleted: return
	if event is InputEventMouseButton:
		if isMouseOnThis() && event.pressed:
			activatePressedEvent()
		elif isPressed:
			if !isTileGenerator:
				target_position = get_global_mouse_position()-contactPoint-(global_position-position)+Offset
			updateVisuals()
			isPressed = false
			if target_position.y + (global_position.y-position.y)<lowerArea.global_position.y:
				movedToTextArea.emit()
			else:
				movedToDeleteArea.emit()
	
	if event is InputEventMouseMotion:
		if isPressed:
			mouseMoved.emit()
		if isMouseOnThis() && !isPressed:
			updateVisuals()
		elif !isPressed && texture==Character.Selected_Texture:
			updateVisuals()
			
func isMouseOnThis() -> bool:
	return get_rect().has_point(get_global_mouse_position()-global_position)

func updateVisuals():
	texture = Character.Normal_Texture
	target_scale = Character.SIZE/get_rect().size
	z_index = 1
	if isPressed && !isTileGenerator:
		z_index = 2
	elif isMouseOnThis() && !isPressed:
		texture = Character.Selected_Texture
		target_scale *= 1.1
	$Label.set_anchors_preset(Control.PRESET_CENTER)
	

func delete():
	deleted = true
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self,"position",Vector2(position.x,6000),2)
	await tween.finished
	queue_free()
func activatePressedEvent():
	isPressed = true
	contactPoint = get_global_mouse_position()-global_position
	updateVisuals()
	if target_position.y + (global_position.y-position.y)>lowerArea.global_position.y:
		pickedUpFromSpawn.emit()
	else:
		pickedUpFromText.emit()
	if isTileGenerator:
		scale = Vector2()
	else:
		if Character.Sound!=null:
			$AudioPlayer.stream = Character.Sound
			$AudioPlayer.play()



signal movedToTextArea
signal movedToDeleteArea
signal pickedUpFromSpawn
signal pickedUpFromText
signal mouseMoved
