extends Node

var planet_render_res : Vector2	# Resolution to render the planet at
var screen_size : Vector2	# Current screen size
var screen_render_res_factor : int = 4	# Factor to shrink the actual resolution by
const SPACE_COLOR : Vector3 = Vector3(0.05, 0.065, 0.09)	# Color for space background

func _ready() -> void:
	screen_size = get_viewport().size
	planet_render_res = screen_size / screen_render_res_factor	# Set render size
