extends Node

var planet_render_res : Vector2
var screen_size : Vector2
var screen_render_res_factor : int = 2

func _ready() -> void:
	screen_size = get_viewport().size
	planet_render_res = screen_size / screen_render_res_factor
