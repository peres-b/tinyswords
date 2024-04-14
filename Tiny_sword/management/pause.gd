extends Control

var _is_paused:bool = false:
	set = set_paused

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		_is_paused = !_is_paused

func set_paused(value:bool) -> void:
	_is_paused = value
	get_tree().paused = _is_paused
	visible = _is_paused

func on_resume_pressed():
	_is_paused = false



func on_main_menu_pressed():
	transition_screen.scene_path = 'res://Tiny_sword/management/menu.tscn'
	transition_screen.fade_in()
	_is_paused = false



func on_quit_pressed():
	transition_screen.can_quit = true
	transition_screen.fade_in()
	_is_paused = false
	
