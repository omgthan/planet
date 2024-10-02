extends Node

var planet_render_res : Vector2
var screen_size : Vector2
var screen_render_res_factor : int = 4
const SPACE_COLOR : Vector3 = Vector3(0.05, 0.065, 0.09)

func _ready() -> void:
	screen_size = get_viewport().size
	planet_render_res = screen_size / screen_render_res_factor
