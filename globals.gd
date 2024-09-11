extends Node

var planet_render_res : Vector2
var screen_size : Vector2

func _ready() -> void:
	screen_size = get_viewport().size
	planet_render_res = screen_size / 4.0
