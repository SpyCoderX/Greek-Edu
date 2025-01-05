extends Sprite2D
class_name Tile

static var SIZE : Vector2 = Vector2(64,72)

@export var Normal : Texture
@export var Selected : Texture
@export var Pressed : Texture


var isPressed : bool = false
var contactPoint : Vector2
var lowerArea : Control
@export var text : Label
var Character : Letter:
	set(new_letter):
		Character = new_letter
		if text!=null:
			text.text = Character.Lower

func _ready() -> void:
	scale = SIZE/get_rect().size
	texture = Normal

func _process(delta: float) -> void:
	if isPressed:
		position = get_global_mouse_position()-contactPoint-(global_position-position)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if isMouseOnThis() && event.pressed:
			isPressed = true
			contactPoint = get_global_mouse_position()-global_position
			texture = Pressed
			if global_position.y>lowerArea.global_position.y:
				pickedUpFromSpawn.emit()
		elif isPressed:
				position = get_global_mouse_position()-contactPoint-(global_position-position)
				texture = Selected if isMouseOnThis() else Normal
				isPressed = false
				if global_position.y<lowerArea.global_position.y:
					movedToTextArea.emit()
				else:
					movedToDeleteArea.emit()
	
	if event is InputEventMouseMotion:
		if isMouseOnThis() && !isPressed:
			texture = Selected
		elif !isPressed && texture==Selected:
			texture = Normal
			
func isMouseOnThis() -> bool:
	return get_rect().has_point(get_global_mouse_position()-global_position)



signal movedToTextArea
signal movedToDeleteArea
signal pickedUpFromSpawn
