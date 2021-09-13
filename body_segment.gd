class_name BodySegment
extends AnimatedSprite

export var next_node = NodePath()
var current_direction: String
var direction_before_movement: String
var is_head = false
var is_segment = false
var is_tail = false
var movement_speed = 64

const LEVEL_X_MIN = 64
const LEVEL_X_MID = 512
const LEVEL_X_MAX = 960
const LEVEL_Y_MIN = 48
const LEVEL_Y_MID = 304
const LEVEL_Y_MAX = 560

func get_class():
	return 'BodySegment'

func move(to_new_direction):
	#placeholder used to alter new direction in case of headd box being at the edge of the level
	var new_direction_placeholder = to_new_direction
	#change direction based on incoming direction and current position
	if is_head:
		if current_direction == "up" and position.y == LEVEL_Y_MIN:
			if position.x >= LEVEL_X_MIN and position.x <= LEVEL_X_MID:
				new_direction_placeholder = "right"
			elif position.x > LEVEL_X_MID and position.x <= LEVEL_X_MAX:
				new_direction_placeholder = "left"
		if current_direction == "down" and position.y == LEVEL_Y_MAX:
			if position.x >= LEVEL_X_MIN and position.x <= LEVEL_X_MID:
				new_direction_placeholder = "right"
			elif position.x > LEVEL_X_MID and position.x <= LEVEL_X_MAX:
				new_direction_placeholder = "left"
		if current_direction == "left" and position.x == LEVEL_X_MIN:
			if position.y >= LEVEL_Y_MIN and position.y <= LEVEL_Y_MID:
				new_direction_placeholder = "down"
			elif position.y > LEVEL_Y_MID and position.y <=LEVEL_Y_MAX:
				new_direction_placeholder = "up"
		if current_direction == "right" and position.x == LEVEL_X_MAX:
			if position.y >= LEVEL_Y_MIN and position.y <= LEVEL_Y_MID:
				new_direction_placeholder = "down"
			elif position.y > LEVEL_Y_MID and position.y <=LEVEL_Y_MAX:
				new_direction_placeholder = "up"
	
	#save current direction
	direction_before_movement = current_direction
	#moving
	
	#match to_new_direction:
	match new_direction_placeholder:
		"up":
			position.y -= movement_speed
		"down":
			position.y += movement_speed
		"left":
			position.x -= movement_speed
		"right":
			position.x += movement_speed
			
	#change current direction after movement
	#current_direction = to_new_direction
	current_direction = new_direction_placeholder
	#making next segment move to my previous location
	if next_node:
		next_node.move(direction_before_movement)

func get_new_direction_for_head():
	if Input.is_action_pressed("ui_up") and (current_direction !="up" and current_direction !="down") and position.y > LEVEL_Y_MIN:
		move("up")
	elif Input.is_action_pressed("ui_down") and (current_direction !="up" and current_direction !="down") and position.y < LEVEL_Y_MAX:
		move("down")
	elif Input.is_action_pressed("ui_left") and (current_direction !="left" and current_direction !="right") and position.x > LEVEL_X_MIN:
		move("left")
	elif Input.is_action_pressed("ui_right") and (current_direction !="left" and current_direction !="right") and position.x < LEVEL_X_MAX:
		move("right")
	else:
		move(current_direction)
