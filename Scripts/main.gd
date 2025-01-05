extends PanelContainer

@export var Characters : Array[Letter]
@export var LowerGrid : Control
@export var UpperLines : Control
@export var TileRef : PackedScene

var Text : Array[Tile]

const Spacing : Vector2 = Vector2(10,10)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup.call_deferred()

func setup() -> void:
	for c in Characters:
		addNewTile(c)

func deleteTile(tile:Tile):
	tile.queue_free()
	Text.erase(tile)
	positionTextTiles()

func addNewTile(c:Letter):
	
	var tile : Tile = TileRef.instantiate()
	tile.Character = c
	tile.position = offsetFromID(Characters.find(c))
	LowerGrid.add_child(tile)
	tile.movedToDeleteArea.connect(deleteTile.bind(tile))
	tile.movedToTextArea.connect(addTile.bind(tile))
	tile.pickedUpFromSpawn.connect(addNewTile.bind(c))
	tile.lowerArea = LowerGrid
	return tile

func addTile(tile:Tile):
	Text.erase(tile) # If it is being moved around then remove it from the list first.
	tile.reparent(UpperLines)
	var id : int
	if tile.position.x>Text.size()*Tile.SIZE.x || tile.position.y>Tile.SIZE.y*2.5:
		id = Text.size()
	else:
		id = floor(tile.position.x/Tile.SIZE.x+0.5)
	Text.insert(id,tile)
	positionTextTiles()
func positionTextTiles():
	var id : int = 0
	for letter in Text:
		letter.position = offsetInTextByID(id)
		id += 1

func offsetFromID(id):
	var tilesPerRow : int = ceili(LowerGrid.size.x/(Tile.SIZE.x+Spacing.x)-0.5)
	return Tile.SIZE/2+Vector2((Tile.SIZE.x+Spacing.x)*(id%tilesPerRow),(Tile.SIZE.y+Spacing.y)*floor(id/tilesPerRow))
func offsetInTextByID(id):
	var tilesPerRow : int = ceili(UpperLines.size.x/(Tile.SIZE.x)-0.5)
	return Tile.SIZE/2+Vector2((Tile.SIZE.x)*(id%tilesPerRow),(Tile.SIZE.y)*floor(id/tilesPerRow))
