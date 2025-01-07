extends Node2D

func _ready() -> void:
	$OptionsMenu.attach_show_node(self)

func _on_options_button_pressed() -> void:
	$MainMenu.hide()
	$OptionsMenu.show()


func _on_options_menu_return_from_options() -> void:
	$OptionsMenu.hide()
	$MainMenu.show()
