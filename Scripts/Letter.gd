extends Resource
class_name Letter

@export var Lower : String
@export var Upper : String
@export var Vowel : bool = false:
	set(new_vowel):
		Vowel = new_vowel
		if Vowel:
			Normal_Texture = preload("res://Assets/Vowel Card.svg")
			Selected_Texture = preload("res://Assets/Vowel Card Selected.svg")
@export var Sound : AudioStream

var SIZE : Vector2 = Vector2(64,72)

var Normal_Texture : Texture = preload("res://Assets/Letter Card.svg")
var Selected_Texture : Texture = preload("res://Assets/Letter Card Selected.svg")
