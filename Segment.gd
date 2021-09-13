extends BodySegment

signal collision(segment)

func _process(_delta):
	animation = current_direction
	if is_head:
		if current_direction == "up" or current_direction == "down":
			$Area2D/CollisionShape2D.shape.extents.x = 18.965
			$Area2D/CollisionShape2D.shape.extents.y = 30.211
			$Area2D/CollisionShape2D.rotation_degrees = 0
			$Area2D/CollisionShape2D.position.y = 0
		else:
			$Area2D/CollisionShape2D.shape.extents.x = 20.96
			$Area2D/CollisionShape2D.shape.extents.y = 29.999
			$Area2D/CollisionShape2D.rotation_degrees = 270
			$Area2D/CollisionShape2D.position.y = 8.8


func _on_Area2D_area_entered(area):
	if is_head:
		#check collision. if area is another box - delete tail starting from that box
		if area.get_parent().get_class() == 'BodySegment':
			emit_signal("collision", area.get_parent())
