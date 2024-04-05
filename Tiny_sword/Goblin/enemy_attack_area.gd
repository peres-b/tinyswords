extends Area2D

@export var damage: int = 1


func on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(damage)
		#body.push_back()
	


func on_lifetime_timeout() -> void:
	queue_free()
	pass # Replace with function body.
