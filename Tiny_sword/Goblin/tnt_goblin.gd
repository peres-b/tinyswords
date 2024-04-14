extends CharacterBody2D

const Audio_Template : PackedScene = preload('res://Tiny_sword/management/audio_template.tscn')
const tnt_scene: PackedScene = preload("res://Tiny_sword/Goblin/tnt.tscn")


@onready var tnt_container = $TntContainer
@onready var texture: Sprite2D = get_node("Texture")
@onready var animation : AnimationPlayer = $Animation
@onready var aux_animation: AnimationPlayer = $Aux_animation
@onready var dust: GPUParticles2D = $Dust


@export var move_speed : int = 120
@export var health: int = 2
@export var distanceThreshold: float = 150.0
@export var attack_cooldown: float = 1.5

var playerRef: CharacterBody2D = null
var can_attack: bool = true
var can_walk: bool = true
var can_die: bool = false
var attack_direction: Vector2 = Vector2.ZERO

func _physics_process(_delta : float) -> void:
	if can_die:
		return
	if playerRef == null or playerRef.can_die and can_walk:
		velocity = Vector2.ZERO
		animate()
		return
	var direction: Vector2 = global_position.direction_to(playerRef.global_position)
	var distance: float = global_position.distance_to(playerRef.global_position)
	
	
	if direction.x  > 0 and can_walk:
		texture.flip_h = false
	if direction.x < 0 and can_walk:
		texture.flip_h = true

	if distance > distanceThreshold and can_attack:
		attack_handler()
		return
	else :
		if can_walk:
			velocity = direction * -move_speed
			move_and_slide()
			animate()

func attack_handler():
	animation.play("attack")
	on_tnt_throw(tnt_scene, attack_direction)
	can_walk = false
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func animate() -> void:
	if velocity.x > 0 and can_walk:
		texture.flip_h = false
	if velocity.x < 0 and can_walk:
		texture.flip_h = true
	if velocity != Vector2.ZERO and can_walk:
		animation.play("walk")
		dust.emitting = true
		return
	dust.emitting = false
	animation.play("idle")
	
func update_health(value: int) -> void:
	health -= value
	if health <= 0 :
		can_die = true
		animation.play("death")
		dust.emitting = false
		return
	
	aux_animation.play("hit")
	


func on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		playerRef = body
		

func on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		playerRef = null
		
func spawn_sfx(sfx_path: String) -> void:
	var sfx = Audio_Template.instantiate()
	sfx.sfx_to_play = sfx_path
	add_child(sfx)
	


func _on_animation_animation_finished(anim_name):
	if anim_name == "attack":
		can_walk = true
	if anim_name == "death":
		#transition_screen.player_score += score
		get_tree().call_group("Level", "update_score", transition_screen.player_score)
		get_tree().call_group("Level", "increase_kill_count")
		
		
func on_tnt_throw(tnt_scene, location):
	var tnt = tnt_scene.instantiate()
	tnt.direction = global_position.direction_to(playerRef.global_position)
	tnt.global_position = global_position
	
	get_parent().add_child(tnt)
	
