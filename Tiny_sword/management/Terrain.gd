extends Node2D
const default_layer = 0
const foam: PackedScene = preload("res://Tiny_sword/management/foam.tscn")
@onready var grass_tilemap: TileMap = get_node('Grass')
@onready var water_tilemap: TileMap = get_node('Water')
# Called when the node enters the scene tree for the first time.
 
var grass_used_cells: Array
var sand_used_cells: Array
var water_used_cells: Array
var rock_used_cells: Array

 
func _ready():
	var used_grass_rect: Rect2 = grass_tilemap.get_used_rect()
	grass_used_cells = grass_tilemap.get_used_cells(3)
	sand_used_cells = grass_tilemap.get_used_cells(1)
	rock_used_cells = grass_tilemap.get_used_cells(2)
	generate_water_tiles(used_grass_rect)
	generate_foam_tiles()
	

func generate_water_tiles(used_rect: Rect2) -> void:
	for x in range(used_rect.position.x - 100, used_rect.size.x + 100):
		for y in range(used_rect.position.y - 100, used_rect.size.y + 100):
			
			
			if sand_used_cells.has(Vector2i(x, y)):
				continue
			if grass_used_cells.has(Vector2i(x, y)):
				continue
			
			water_tilemap.set_cell(0,Vector2i(x, y),0,Vector2i(0,0))
	water_used_cells = water_tilemap.get_used_cells(default_layer)

func generate_foam_tiles() -> void:
	
		
	for cell in grass_used_cells:
		if check_grass_neighbors(cell):
			spawn_foam(cell)
	for cell in sand_used_cells:
		if check_grass_neighbors(cell):
			spawn_foam(cell)
	
	
		
func check_grass_neighbors(cell: Vector2i) -> bool:
	var left_neighbor: Vector2i = Vector2i(cell.x -1, cell.y)
	var right_neighbor: Vector2i = Vector2i(cell.x +1, cell.y)
	var top_neighbor: Vector2i = Vector2i(cell.x, cell.y-1)
	var bottom_neighbor: Vector2i = Vector2i(cell.x, cell.y+1)
	var neighbors_list: Array = [left_neighbor, right_neighbor, top_neighbor, bottom_neighbor]
	for neighbor in neighbors_list:
		if water_used_cells.has(neighbor):
			return true
	return false


		
func spawn_foam(foam_cell: Vector2) -> void:
	var foam = foam.instantiate()
	foam.position = (foam_cell * 64.0) + Vector2(32, 32)
	add_child(foam)
	

