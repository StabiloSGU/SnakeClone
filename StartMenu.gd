extends Node2D

var mouse_on_start = false
var level_scene = preload("res://Level.tscn")

func _ready():
	$GUI/RichTextLabel.text = """You are the legendary agent Stiff Snak fighting your ultimate battle against the ever-elusive enemy - The Hunger!
Age slowed you down but to win this battle you must eat and grow at least ["""+ str(GlobalState.WIN_CONDITION) + """] boxes long.
Each banana you eat will give you 1 box.
Don't let your food expire or it will become a mine and hurt you!
And don't try to eat your 'tail' or it will fall off."""

func start_game():
	get_tree().change_scene_to(level_scene)

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_accept") or (Input.is_mouse_button_pressed(1) and mouse_on_start):
		$GUI/Label2/AnimationPlayer.stop()
		$GUI/FadeOutAnimationPlayer.play("FadeOut")
		$AudioStreamPlayer2D.play()

func _on_Label2_mouse_entered():
	mouse_on_start = true


func _on_Label2_mouse_exited():
	mouse_on_start = false


func _on_AudioStreamPlayer2D_finished():
	start_game()
