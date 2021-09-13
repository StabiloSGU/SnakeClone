extends Node2D

var endgame_scene = load("res://EndgameScreen.tscn")
var segment_scene = preload("res://Segment.tscn")
var food_scene = preload("res://Food.tscn")
onready var audioplayer = $EffectsPlayer
onready var pb = $ProgressBar

var alert = preload("res://Assets/Sounds/low_health_alert.wav")
var food_pickup = preload("res://Assets/Sounds/itemused.wav")
var mine_explosion = preload("res://Assets/Sounds/cabled-mess__boom-c-01.wav")

var head_segment
var last_segment
var endgame_screen

var rng = RandomNumberGenerator.new()
var game_objects = []
var food
var box_counter = 0

var START_X = 512
var START_Y = 304

const SPAWN_MARGIN = 64
const HEALTH_OK = Color("2fbc0d")
const HEALTH_LOW = Color.red


var game_is_running = false
var new_game_preparing = false


func _ready():
	$ProgressBar.max_value = GlobalState.WIN_CONDITION + 1
	new_game()

func new_game():
	#clear endgame screen
	if MainThemePlayer.volume_db == -MainThemePlayer.VOLUME_DAMP:
		MainThemePlayer.restore_sound()
	#half assed workaround
	if endgame_screen:
		endgame_screen.disconnect("restart", self, "new_game")
	if endgame_screen:
		endgame_screen.queue_free()
	#new game reset conditions
	if game_objects:
		for object in game_objects:
			object.queue_free()
	game_objects.clear()
	
	head_segment = null
	last_segment = null
	food = null
	box_counter = 0
	game_is_running = false
	GlobalState.victory_state = null
	pb.get("custom_styles/fg").set("color", HEALTH_OK)
	
	#spawn head and start game timer
	
	head_segment = segment_scene.instance()
	head_segment.position.x = START_X
	head_segment.position.y = START_Y
	head_segment.is_head = true
	head_segment.current_direction = "right"
	
	head_segment.connect("collision", self, "delete_segments")
	
	add_child(head_segment)
	game_objects.append(head_segment)
	last_segment = head_segment
	box_counter += 1
	
	game_is_running = true
	$SnakeTimer.start()
	
func _process(_delta):
	$ProgressBar.value = box_counter + 1
	
	if box_counter == GlobalState.WIN_CONDITION and game_is_running:
		game_is_running = false
		game_over('win')


func spawn_segment():	
	#can only be called upon eating food
	#so resetting food to 0 should be done here
	#play pickup sound
	$EffectsPlayer.stream = food_pickup
	$EffectsPlayer.play()
	
	#disconnect current food from signals
	food.disconnect("nom", self, "spawn_segment")
	food.disconnect("boom", self, "caught_mine")
	food.disconnect("expired", self, "food_expired")
	#remove current food from tree and game_objects
	game_objects.erase(food)
	food.queue_free()
	food = null
	#create new segment
	var new_segment = segment_scene.instance()
	#set it as tail
	last_segment.is_tail = false
	last_segment.is_segment = true
	new_segment.is_tail = true
	#set its initital direction same as the last segment
	new_segment.current_direction = last_segment.current_direction
	#spawn on the opposite side of its direction
	match last_segment.current_direction:
		"up":
			new_segment.position.x = last_segment.position.x
			new_segment.position.y = last_segment.position.y + SPAWN_MARGIN
		"down":
			new_segment.position.x = last_segment.position.x
			new_segment.position.y = last_segment.position.y - SPAWN_MARGIN
		"left":
			new_segment.position.x = last_segment.position.x + SPAWN_MARGIN
			new_segment.position.y = last_segment.position.y
		"right":
			new_segment.position.x = last_segment.position.x - SPAWN_MARGIN
			new_segment.position.y = last_segment.position.y
	#tie last segments next_node to this new node
	last_segment.next_node = new_segment
	#place last_segment as new_segment
	last_segment = new_segment
	
	game_objects.append(new_segment)
	add_child(new_segment)
	box_counter += 1
	if box_counter >= 2:
		pb.get("custom_styles/fg").set("color", HEALTH_OK)

func delete_segments(segment):
	if segment.next_node:
		delete_segments(segment.next_node)
	last_segment = get_next_to_last_segment(segment)
	last_segment.is_tail = true
	last_segment.next_node = null
	game_objects.erase(segment)
	segment.call_deferred('queue_free')
	box_counter -= 1

func food_expired():
	if game_is_running:
		spawn_food()

func spawn_food():
	rng.randomize()
	var possible_locations = []
	for y in range(1, 9):
		for x in range(1, 16):
			possible_locations.append(Vector2(64 * x, 48 * y))
	#find an empty cell by cycling through game_objects
	#check their positions. if position is in possible_locations, delete it
	#from the latter
	for object in game_objects:
		if object.position in (possible_locations):
			possible_locations.erase(object.position)
	#get a random number from 0 to len(possible_locations)
	var food_spawn_location = possible_locations[rng.randi_range(0, len(possible_locations) - 1)]
	# and spawn food at these coords
	food = food_scene.instance()
	food.position = food_spawn_location
	#TODO: dont forget from array upon consumption!!!
	game_objects.append(food)
	food.connect("nom", self, "spawn_segment")
	food.connect("boom", self, "caught_mine")
	food.connect("expired", self, "food_expired")
	add_child(food)

func get_next_to_last_segment(segment):
	#cycle through game_objects, find which segment points to _segment_
	for object in game_objects:
		if object.get_class() == 'BodySegment':
			if !object.is_tail:
				if object.next_node == segment:
					return object

func caught_mine(mine_obj):
	#play explosion sound
	$EffectsPlayer.stream = mine_explosion
	$EffectsPlayer.play()
	#check if none of the last two boxes are head
	
	#if head and last object are the same call game over
	#if head has only one child call game over
	if last_segment.is_head or head_segment.next_node == last_segment:
		if head_segment.next_node:
			last_segment.call_deferred('queue_free')
			
		game_is_running = false
		pb.get("custom_styles/fg").set("color", HEALTH_LOW)
		head_segment.flip_v = true
		head_segment.stop()
		game_over('fail')
	
	#otherwise look for last two segments to delete them
	else:
		#get segment that points to tail
		var points_to_tail = get_next_to_last_segment(last_segment)
		#get segment that points to this pointer
		var pointer_to_pointer = get_next_to_last_segment(points_to_tail)
		#delete tail and pointer to it
		game_objects.erase(points_to_tail)
		game_objects.erase(last_segment)
		
		#TODO: dissapearance animation and sound
		
		points_to_tail.call_deferred('queue_free')
		last_segment.call_deferred('queue_free')
		#make pointer to pointer tail, clear its next node variable
		pointer_to_pointer.is_tail = true
		pointer_to_pointer.next_node = null
		#place it as last segment
		last_segment = pointer_to_pointer
		box_counter -= 2
		if box_counter <= 2:
			audioplayer.stream = alert
			audioplayer.play()
			pb.get("custom_styles/fg").set("color", HEALTH_LOW)
	
	#delete mine from screen
	game_objects.erase(mine_obj)
	mine_obj.disconnect("nom", self, "spawn_segment")
	mine_obj.disconnect("boom", self, "caught_mine")
	mine_obj.disconnect("expired", self, "food_expired")

func game_over(state):
	game_is_running = false
	$SnakeTimer.stop()
	
	GlobalState.victory_state = state
	#play death animation on head_segment
	endgame_screen = endgame_scene.instance()
	endgame_screen.connect("restart", self, "new_game")
	add_child(endgame_screen)

func _on_SnakeTimer_timeout():
	if game_is_running:
		if !food:
			spawn_food()
		head_segment.get_new_direction_for_head()
