extends CharacterBody2D

const Audio_Template: PackedScene = preload('res://Tiny_sword/management/audio_template.tscn')
const attackArea: PackedScene = preload("res://Tiny_sword/Goblin/enemy_attack_area.tscn")
const offset: Vector2 = Vector2(0, 30)
@onready var texture: Sprite2D = get_node("Texture")
@onready var animation: AnimationPlayer = get_node("Animation")
@onready var aux_animation_player: AnimationPlayer = get_node("AuxAnimation")
@onready var dust: GPUParticles2D = get_node("Dust")

@export var move_speed: float = 150.0
@export var knockback_timer: float = 0.175
@export var health: int = 3
@export var damage: int = 1
@export var distanceThreshold: float = 60.0
@export var score: int = 1


var playerRef: CharacterBody2D = null

var can_walk: bool = true
var can_attack: bool = true
var can_die: bool = false

func _physics_process(_delta: float ) -> void:
	if can_die:
		return
	if playerRef == null or playerRef.can_die and can_walk:
		velocity = Vector2.ZERO
		animate()
		return
	
	var direction: Vector2 = global_position.direction_to(playerRef.global_position)
	var distance: float= global_position.distance_to(playerRef.global_position) 
	
	if distance < distanceThreshold and can_attack:
		animation.play("attack")
		return
	velocity = direction * move_speed
	move_and_slide()
	animate()

func spawnAttackArea() -> void:
	var AttackArea = attackArea.instantiate()
	AttackArea.position =  offset
	add_child(AttackArea)
	pass
func animate() -> void:
	if velocity.x > 0 and can_walk:
		texture.flip_h = false
	
		
	if velocity.x < 0 and can_walk:
		texture.flip_h = true
		
	
	if velocity != Vector2.ZERO and can_walk:
		dust.emitting = true
		animation.play("walk")
		return
	dust.emitting = false
	animation.play("idle")
	

func update_health(value: int) -> void:
	health -= value
	if health <= 0 :
		can_die = true
		animation.play("death")
		return
	
	aux_animation_player.play("hit")
	knockback()
	

func on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		playerRef = body
	

func on_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		playerRef = null
	

func _on_animation_finished(anim_name: String):
	if anim_name == "death":
		transition_screen.player_score += score
		get_tree().call_group("Level", "update_score", transition_screen.player_score)
		get_tree().call_group("Level", "increase_kill_count")
		queue_free()
		
func spawn_sfx(sfx_path: String) -> void:
	var sfx = Audio_Template.instantiate()
	sfx.sfx_to_play = sfx_path
	add_child(sfx)

func knockback() -> void:
	can_attack = false
	can_walk = false
	move_speed *= -1	
	await get_tree().create_timer(knockback_timer).timeout
	move_speed *= -1
	can_walk = true
	can_attack = true
	
	
