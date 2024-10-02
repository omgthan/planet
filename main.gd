extends Node2D

@export var noise_texture : NoiseTexture3D

var planet_pos : Vector2 = Vector2(0.0, 0.0)
var radius : float = 1.0
var angle : float = 0.0
var axis : Vector3 = Vector3(1.0, 1.0, 1.0)
var rotation_speed : float = 1.0

var planet_color_main : Color
var planet_color_light : Color
var planet_color_dark : Color

var light_source : Vector3 = Vector3(1.0, 1.0, 1.0)
var light_axis : Vector3 = Vector3(1.0, 1.0, 1.0)
var light_angle : float = 0.0

var lower_atmo_color : Vector3 = Vector3(0.0, 0.0, 0.0)
var higher_atmo_color : Vector3 = Vector3(1.0, 1.0, 1.0)
var atmo_thickness : float = 1.0

func _ready() -> void:
	gen_planet()
	material.set_shader_parameter("SPACE_COLOR", Globals.SPACE_COLOR)


func _process(delta: float) -> void:
	angle += (rotation_speed * delta) / 2.0
	material.set_shader_parameter("angle", angle)
	%FPS.text = "FPS: " + str(Engine.get_frames_per_second())

func gen_planet() -> void:
	radius = randf_range(
		Globals.planet_render_res.x / 8,
		Globals.planet_render_res.x / 4
	)

	angle = 0.0
	rotation_speed = randf_range(0.01, 0.1)
	planet_pos = Vector2(
		randf_range(Globals.planet_render_res.x * 0.5, 1.5 * Globals.planet_render_res.x),
		randf_range(Globals.planet_render_res.y * 0.5, 1.5 * Globals.planet_render_res.y)
	)
	axis = Vector3(
		randf_range(-1,1),
		randf_range(-1,1),
		randf_range(-1,1)
	)

	gen_colors()

	noise_texture.noise.seed = randi()
	noise_texture.noise.frequency = 0.1 * (radius/Globals.planet_render_res.y)

	light_source = axis.cross(Vector3(10,10,10))
	atmo_thickness = randf_range(1.0, 1.2)

	set_shader_params()

func set_shader_params() -> void:
	material.set_shader_parameter("color_main", planet_color_main)
	material.set_shader_parameter("color_light", planet_color_light)
	material.set_shader_parameter("color_dark", planet_color_dark)
	material.set_shader_parameter("coords", planet_pos)
	material.set_shader_parameter("radius", radius)
	material.set_shader_parameter("axis", axis)
	material.set_shader_parameter("light_source", light_source)
	material.set_shader_parameter("lower_atmo_color", lower_atmo_color)
	material.set_shader_parameter("higher_atmo_color", higher_atmo_color)
	material.set_shader_parameter("atmo_thickness", atmo_thickness)
	material.set_shader_parameter("noise_texture", noise_texture)

func gen_colors() -> void:
	planet_color_main = Color(
		clamp(randf(), 0.5, 0.9),
		clamp(randf(), 0.5, 0.9),
		clamp(randf(), 0.5, 0.9),
	)
	planet_color_light = Color(
		planet_color_main.r * 1.2,
		planet_color_main.g * 1.2,
		planet_color_main.b * 0.8
	)
	planet_color_dark = Color(
		planet_color_main.r * 0.8,
		planet_color_main.g * 0.8,
		planet_color_main.b * 1.2,
	)

	higher_atmo_color = Vector3(
		randf_range(0.5, 1.0),
		randf_range(0.5, 1.0),
		randf_range(0.5, 1.0)
	)
	lower_atmo_color = Vector3(
		1.0 - higher_atmo_color.x + 0.5,
		1.0 - higher_atmo_color.y + 0.5,
		1.0 - higher_atmo_color.z + 0.5,
	)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Globals.planet_render_res), Color.WHITE)
