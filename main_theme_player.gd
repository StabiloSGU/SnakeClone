extends AudioStreamPlayer

var main_theme = preload("res://Assets/Sounds/main_theme.wav")
const VOLUME_DAMP = 30.0

func _ready():
	stream = main_theme
	playing = true


func low_sound_temporarily():
	volume_db -= VOLUME_DAMP

func restore_sound():
	volume_db += VOLUME_DAMP
