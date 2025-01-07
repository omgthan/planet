extends Control

var return_node : Node
signal return_from_options

## Attach the node to show when the returning after
## pressing the back button
func attach_show_node(in_node : Node) -> void:
	return_node = in_node

func _on_back_button_pressed() -> void:
	return_from_options.emit()

func _on_window_mode_dd_item_selected(index : int) -> void:
	var res : Vector2i = DisplayServer.window_get_size()
	var pos : Vector2i = DisplayServer.window_get_position()
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_size(res)
	DisplayServer.window_set_position(pos)

func _on_resolution_dd_item_selected(index : int) -> void:
	match index:
		0:
			get_window().size = Vector2i(320,180)
		1:
			get_window().size = Vector2i(320,180) * 2
		2:
			get_window().size = Vector2i(320,180) * 4
		3:
			get_window().size = Vector2i(320,180) * 6
		4:
			get_window().size = Vector2i(320,180) * 8
