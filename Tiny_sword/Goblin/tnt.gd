extends RigidBody2D
const Audio_Template : PackedScene = preload('res://Tiny_sword/management/audio_template.tscn')

@onready var animation: AnimationPlayer = $AnimationPlayer
@export var speed: int = 300
@export var damage: int = 2

var can_explode = false
var direction = null

func _physics_process(delta):
	global_position += speed * direction * delta
	animate()
	pass

func animate() -> void:
	if !can_explode:
		animation.play("throw")
		can_explode = true

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"throw":
			speed = 0
			animation.play("explosion")
		"explosion":
			queue_free()
			

func _on_area_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(damage)

func spawn_sfx(sfx_path: String) -> void:
	var sfx = Audio_Template.instantiate()
	sfx.sfx_to_play = sfx_path
	add_child(sfx)
