extends CharacterBody2D

const Audio_Template: PackedScene = preload('res://Tiny_sword/management/audio_template.tscn')

@onready var collision: CollisionShape2D = get_node("CollisionShape2D")
@onready var attack_collision: CollisionShape2D = get_node("attackArea/Collision")
@onready var texture: Sprite2D = get_node("Texture")
@onready var animation: AnimationPlayer = get_node("Animation")
@onready var aux_animation_player: AnimationPlayer = get_node("AuxAnimationPlayer")
@onready var dust: GPUParticles2D = get_node("Dust")

@export var move_speed: float = 256.0
@export var health: int = 5
@export var damage: int = 1
@export var dash_speed: float = 2.0
@export var dash_damage: int = 2


var can_dash: bool = true
var can_attack: bool = true
var can_die: bool = false
var dashing: bool = false
var dash_timer: float = 0.2
var dash_cooldown: float = 1.5

func _ready() -> void:
	if transition_screen.player_health!= 0:
		health = transition_screen.player_health 
		return
	transition_screen.player_health = health
	
	

func _physics_process(_delta: float ) -> void:
	if(
		can_attack == false or 
		can_die):
		return
	move()
	dash()
	animate()
	attack_hanlder()
	
func move() -> void:
	var direction: Vector2 = get_direction()
	velocity = direction * move_speed
	move_and_slide()
	
func dash() :
	if Input.is_action_just_pressed("dash") and can_dash:
		spawn_sfx("res://assets/sfx/human_dash.wav")
		move_speed = move_speed * dash_speed
		can_dash = false
		texture.scale.x = 1.5
		texture.scale.y = 0.7
		dashing = true
		await get_tree().create_timer(dash_timer).timeout
		dashing = false
		move_speed = move_speed / dash_speed
		texture.scale.x = 1
		texture.scale.y = 1
		await get_tree().create_timer(dash_cooldown).timeout
		can_dash = true
		
	
func get_direction() -> Vector2:
	return Vector2(
		Input.get_axis("move_left","move_right"),
		Input.get_axis("move_up","move_down")
	).normalized()

func animate() -> void:
	if velocity.x < 0:
		texture.flip_h = true
		attack_collision.position.x = -58.0
		
	if velocity.x > 0:
		texture.flip_h = false
		attack_collision.position.x = 58.0
		
	
	if velocity!= Vector2.ZERO:
		dust.emitting = true
		animation.play("walk")
		return
	dust.emitting = false
	animation.play("idle")

func attack_hanlder() -> void:
	if Input.is_action_pressed("attack") and can_attack and !dashing:
		can_attack= false
		animation.play("attack")
	if Input.is_action_pressed("attack") and can_attack and dashing:
		can_attack= false
		animation.play("dash_attack")
		damage = damage * dash_damage


func _on_animation_finished(anim_name):
	match anim_name:
		"attack" :
			can_attack = true
		"dash_attack" :
			@warning_ignore("integer_division")
			damage = damage / dash_damage
			can_attack = true

		"death":
			transition_screen.fade_in()
			transition_screen.player_score = 0
			transition_screen.player_health = 0



func _on_attack_area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.update_health(damage)
	elif body.is_in_group("Destructible"):
		body.update_health(damage)
	pass
	
func take_damage(value: int) -> void:
	if dashing:
		Engine.time_scale = 0.5
		await get_tree().create_timer(dash_timer).timeout
		Engine.time_scale = 1
		return
	health -= value
	
	transition_screen.player_health = health
	get_tree().call_group('Level', 'update_health', health)
	if health <= 0 :
		can_die = true
		animation.play("death")
		attack_collision.set_deferred("disabled", true)
		return
	aux_animation_player.play("hit")
		
func spawn_sfx(sfx_path: String) -> void:
	var sfx = Audio_Template.instantiate()
	sfx.sfx_to_play = sfx_path
	add_child(sfx)
	
func heal(value: int)-> void:
	if transition_screen.player_health >= 5:
		return
	aux_animation_player.play("heal")
	health += value
	#spawn_sfx("res://assets/sfx/heal.wav")
	transition_screen.player_health = health
	get_tree().call_group('Level', 'update_health', health)
