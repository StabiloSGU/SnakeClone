extends AnimatedSprite

signal nom
signal boom(mine_obj)
signal expired

var has_expired = false


func _ready():
	$ProgressBar/LifeTimer.start()

func _on_Area2D_area_entered(area):
	if area.get_parent().is_head:
		if !has_expired:
			emit_signal("nom")
		else:
			emit_signal("boom", self)
			animation = "explosion"
		
		


func _on_LifeTimer_timeout():
	$ProgressBar.value += $ProgressBar.step
	if $ProgressBar.value == 100:
		#stop timer and remove nodes
		$ProgressBar/LifeTimer.stop()
		$ProgressBar/LifeTimer.call_deferred('queue_free')
		$ProgressBar.call_deferred('queue_free')
		
		#switch state to mine
		has_expired = true
		emit_signal("expired")
		#switch animation to mine
		animation = "mine"


func _on_Food_animation_finished():
	if animation == 'explosion':
		call_deferred('queue_free')
