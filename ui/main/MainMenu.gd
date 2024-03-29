extends TextureRect

@onready var top_menu_level = get_node("../../")

func _on_new_pressed():
	top_menu_level.switch_to(%NewGame)

func _on_load_pressed():
	%LoadGame.update()
	top_menu_level.switch_to(%LoadGame)

func _on_save_pressed():
	Client.save_game()

func _on_quit_pressed():
	get_tree().quit()

func _on_continue_pressed():
	Client.toggle_pause()

func _on_visibility_changed():
	if Client.ready_to_continue():
		$Continue.disabled = false
	else:
		$Continue.disabled = true
