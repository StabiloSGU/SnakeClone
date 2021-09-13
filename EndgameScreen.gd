extends Node2D

var mouse_on_restart = false
var emitted = false
signal restart

var amazing = preload("res://Assets/Sounds/game_won.wav")
var victory_theme = preload("res://Assets/Sounds/victory_theme.wav")
var death_scream = preload("res://Assets/Sounds/death_scream.wav")
var codec_screams_0 = preload("res://Assets/Sounds/death_screams_0.wav")
var codec_screams_1 = preload("res://Assets/Sounds/death_screams_1.wav")
var codec_screams_2 = preload("res://Assets/Sounds/death_screams_2.wav")
var codec_screams_3 = preload("res://Assets/Sounds/death_screams_3.wav")
var codec_screams_4 = preload("res://Assets/Sounds/death_screams_4.wav")

var codec_screams = [codec_screams_0,codec_screams_1, codec_screams_2, codec_screams_3, codec_screams_4]
var sound_picker_rng = RandomNumberGenerator.new()

func _ready():
	MainThemePlayer.low_sound_temporarily()
	if GlobalState.victory_state == "win":
		$GameOverText.text = "MISSION COMPLETE"
		$AudioStreamPlayer2D.stream = victory_theme
		$AnimationPlayer.set("volume_db", -5)
		$ScreamsPlayer.stream = amazing
	else:
		sound_picker_rng.randomize()
		$GameOverText.text = "GAME OVER"
		$AudioStreamPlayer2D.stream = death_scream
		$ScreamsPlayer.stream = codec_screams[sound_picker_rng.randi() % codec_screams.size()]
		
	$ScreamsPlayer.play()
	$AudioStreamPlayer2D.play()
	

func _on_AnimationPlayer_animation_finished(anim_name):
	$Restart.visible = true
	$Restart/AnimationPlayer.play("RestartAnimation")


func _physics_process(_delta):
	if !emitted:
		if Input.is_action_just_pressed("ui_accept") or (Input.is_action_just_pressed("left_mouse") and mouse_on_restart):
			if $Restart.visible:
				#keeps the endgame screen on for some reason only at defeat
				$Restart.visible = false
				$AudioStreamPlayer2D.stop()
				$ScreamsPlayer.stop()
				mouse_on_restart = false
				if !emitted:
					emitted = true
					emit_signal("restart")


func _on_Restart_mouse_entered():
	mouse_on_restart = true

func _on_Restart_mouse_exited():
	mouse_on_restart = false
