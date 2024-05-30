extends Node2D

@onready var tile_map : TileMap = $TileMap

var day : int = 1
var money : int = 0
var seeds_available : int = 5
var tools : Array = ["Hoe", "Seed Bag", "Watering Can", "Sickle"]

enum farming_modes{DIRT, SEEDS, WATER, HARVEST}
var farming_mode_state : farming_modes = farming_modes.DIRT

# Called when the node enters the scene tree for the first time.
func _ready(): 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	manage_tools()
	manage_UI()
	daylight_control()
	
	if Input.is_action_just_pressed("ui_accept"):
		next_day()
		

	if Input.is_action_just_pressed("interact"):
		var mouse_pos : Vector2 = get_global_mouse_position()
		var tile_map_pos : Vector2i = tile_map.local_to_map(mouse_pos)

		if farming_mode_state == farming_modes.DIRT:
			use_dirt(tile_map_pos)
		if farming_mode_state == farming_modes.SEEDS:
			use_seeds(tile_map_pos)
		if farming_mode_state == farming_modes.WATER:
			use_water(tile_map_pos)
		if farming_mode_state == farming_modes.HARVEST:
			use_sickle(tile_map_pos)

func manage_UI() -> void:
	$CanvasLayer/Control/Day.text = "Day: " + str(day)
	$CanvasLayer/Control/Tool.text = "Tool: " + tools[farming_mode_state]
	$CanvasLayer/Control/Money.text = "Money: $" + str(money)
	$CanvasLayer/Control/Seeds.text = "Seeds: " + str(seeds_available)
	$CanvasLayer/Control/Time.text = "Time left: " + str(int($Timer.time_left))
func use_sickle(tile_map_pos : Vector2i) -> void:
	if retrieve_custom_data(tile_map_pos, "has_seeds", 1):
		var seed_level = retrieve_custom_data(tile_map_pos, "seed_level", 1)
		if retrieve_custom_data(tile_map_pos,"can_harvest",1):
			tile_map.set_cell(1,tile_map_pos,-1,Vector2i(-1,-1))
			money+=4

func use_seeds(tile_map_pos : Vector2i) -> void:
	if retrieve_custom_data(tile_map_pos, "can_place_seeds", 0) and seeds_available>0:
		if !retrieve_custom_data(tile_map_pos, "has_seeds", 1):
			tile_map.set_cell(1,tile_map_pos,3,Vector2i(0,0))
			seeds_available-=1
	
func use_water(tile_map_pos : Vector2i) -> void:
	if retrieve_custom_data(tile_map_pos, "can_water", 0):
		tile_map.set_cell(0,tile_map_pos,2,Vector2i(0,0))
	
func use_dirt(tile_map_pos : Vector2i) -> void:
	tile_map.set_cell(0,tile_map_pos,1,Vector2i(0,0))
	
func manage_tools() -> void:
	if Input.is_action_just_pressed("dirt"):
		farming_mode_state = farming_modes.DIRT
	if Input.is_action_just_pressed("seeds"):
		farming_mode_state = farming_modes.SEEDS
	if Input.is_action_just_pressed("water"):
		farming_mode_state = farming_modes.WATER
	if Input.is_action_just_pressed("harvest"):
		farming_mode_state = farming_modes.HARVEST

func retrieve_custom_data(tile_map_pos : Vector2i, custom_data_layer: String, layer:int):
	var tile_data : TileData = tile_map.get_cell_tile_data(layer, tile_map_pos)
	
	if tile_data:
		return tile_data.get_custom_data(custom_data_layer)
	else:
		return false
		
func next_day() -> void:
	day+=1
	$Timer.start()
	
	
	for cell in tile_map.get_used_cells(1):
		var cell_pos : Vector2i = Vector2i(cell.x, cell.y)
		var cell_level = retrieve_custom_data(cell_pos, "seed_level", 1)
		
		if cell_level < 3:
			if retrieve_custom_data(cell_pos, "is_watered", 0):
				tile_map.set_cell(1,cell_pos,3,Vector2i(cell_level+1, 0))
			else:
				if cell_level>0:
					tile_map.set_cell(1,cell_pos,3,Vector2i(cell_level-1, 0))
				else:
					tile_map.set_cell(1,cell_pos,-1,Vector2i(-1,-1))
		
	for cell in tile_map.get_used_cells(0):
		var cell_pos : Vector2i = Vector2i(cell.x, cell.y)		
		if retrieve_custom_data(cell_pos, "is_watered", 0):
			tile_map.set_cell(0,cell_pos,1,Vector2i(0, 0))


func _on_shop_pressed():
	if money>1:
		money-=2
		seeds_available+=1
		


func _on_next_day_pressed():
	next_day()


func _on_seedx_5_pressed():
	if money>9:
		money-=10
		seeds_available+=5

func _on_timer_timeout():
	next_day()
	
func daylight_control() -> void:
	if $Timer.time_left>2:
		$Shadow.energy=((1/($Timer.time_left/2))*16)
	else:
		$Shadow.energy=16
	
