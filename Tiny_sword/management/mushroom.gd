extends StaticBody2D

@onready var animation: AnimationPlayer = get_node("Animation")
@export var health: int = 1

var damage: int = 1



func update_health(value: int) -> void:
	health -= value
	if health <= 0 :
		animation.play('hit')
		



func on_animation_finished(anim_name):
	if anim_name == 'hit':
		var player = get_tree().get_first_node_in_group("Player")
		player.heal(1)
		
		queue_free()
		
	
