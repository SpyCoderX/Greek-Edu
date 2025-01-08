extends PanelContainer

@export var Characters : Array[Letter]
@export var LowerGrid : Control
@export var UpperLines : Control
@export var TileRef : PackedScene

@export var PlayButton : Button
@export var StopButton : Button


@export var Speaker : AudioStreamPlayer

@export_group("Button Textures")
@export var NormalPlay : Texture
@export var DisabledPlay : Texture
@export var PressedPlay : Texture

@export var NormalStop : Texture
@export var DisabledStop : Texture
@export var PressedStop : Texture

var Text : Array[Tile]
var Letters : Array[Tile]

const SentenceEnding : String = ".!;"

var speaking : bool = false:
	set(new_speaking):
		speaking = new_speaking
		if PlayButton!=null and StopButton!=null:
			updateButtonTextures()

const Spacing : Vector2 = Vector2(10,10)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup.call_deferred()

func setup() -> void:
	for c in Characters:
		addGeneratorTile(c)

func deleteTile(tile:Tile):
	tile.delete()
	Text.erase(tile)
	positionTextTiles()

func addNewTile(c:Letter):
	speaking = false
	var tile : Tile = TileRef.instantiate()
	Letters.append(tile)
	prepTile(tile,c)
	LowerGrid.add_child(tile)
	tile.movedToDeleteArea.connect(deleteTile.bind(tile))
	tile.movedToTextArea.connect(addTile.bind(tile))
	tile.mouseMoved.connect(addTile.bind(tile))
	tile.activatePressedEvent()
	addTile(tile)

func addGeneratorTile(c):
	var tile : Tile = TileRef.instantiate()
	tile.isTileGenerator = true
	Letters.append(tile)
	prepTile(tile,c)
	LowerGrid.add_child(tile)
	tile.pickedUpFromSpawn.connect(addNewTile.bind(c))

func prepTile(tile,c):
	tile.Character = c
	tile.target_position = offsetFromID(Characters.find(c))
	tile.position = offsetFromID(Characters.find(c))
	tile.lowerArea = LowerGrid

func regenerateGeneratorPositions():
	for tile in Letters:
		if !tile.isTileGenerator: continue
		tile.target_position = offsetFromID(Characters.find(tile.Character))
		tile.position = offsetFromID(Characters.find(tile.Character))

func addTile(tile:Tile):
	Letters.erase(tile)
	Text.erase(tile) # If it is being moved around then remove it from the list first.
	var diff : Vector2 = tile.target_position-tile.position
	tile.reparent(UpperLines)
	tile.target_position = tile.position+diff
	var id : int = len(Text)
	var offset : Vector2 = Vector2()
	for x in range(len(Text)):
		offset.x += Text[x].Character.SIZE.x
		if offset.x>UpperLines.size.x:
			offset.x = 0
			offset.y += Text[x].Character.SIZE.y
		if tile.Character.SIZE.y+offset.y>tile.target_position.y && offset.x>tile.target_position.x:
			id = x
			break
		
	Text.insert(id,tile)
	positionTextTiles()
func sumTextWidth():
	var width : float = 0
	for tile in Text:
		width += tile.Character.SIZE.x
	return width
func positionTextTiles():
	var id : int = 0
	for letter in Text:
		letter.target_position = offsetInTextByID(id)
		letter.isUpper = true if id==0 or SentenceEnding.contains(Text[id-1].Character.Lower) else false
		id += 1

func offsetFromID(id):
	var offset : Vector2 = Vector2()
	for x in range(len(Letters)):
		if x>=id: break
		offset.x += Letters[x].Character.SIZE.x + Spacing.x
		if offset.x+Letters[x+1].Character.SIZE.x>LowerGrid.size.x:
			offset.x = 0
			offset.y += Letters[id].Character.SIZE.y + Spacing.y
	return offset+Letters[id].Character.SIZE/2
func offsetInTextByID(id):
	var offset : Vector2 = Text[id].Character.SIZE/2
	for x in range(len(Text)):
		if x>=id: break
		offset.x += Text[x].Character.SIZE.x
		if offset.x>UpperLines.size.x:
			offset.x = Text[id].Character.SIZE.x/2
			offset.y += Text[id].Character.SIZE.y
	return offset


func _on_resized() -> void:
	regenerateGeneratorPositions()

func speak():
	speaking = true
	for letter in Text:
		if !speaking:
			return
		if letter.Character.Sound:
			Speaker.stream = letter.Character.Sound
			Speaker.play()
			await Speaker.finished
		else:
			await get_tree().create_timer(0.6).timeout
	speaking = false

func _on_play_button_pressed() -> void:
	if !speaking:
		speak()


func _on_stop_button_pressed() -> void:
	speaking = false

func updateButtonTextures():
	PlayButton.icon = DisabledPlay if speaking else (PressedPlay if PlayButton.button_pressed else NormalPlay)
	StopButton.icon = (PressedStop if StopButton.button_pressed else NormalStop) if speaking else DisabledStop


func _on_play_button_button_down() -> void:
	updateButtonTextures()


func _on_stop_button_button_down() -> void:
	updateButtonTextures()


func _on_stop_button_button_up() -> void:
	updateButtonTextures()


func _on_play_button_button_up() -> void:
	updateButtonTextures()
