extends Node2D

# 3D noise texture for planet surface
@export var noise_texture : NoiseTexture3D

var planet_pos : Vector2 = Vector2(0.0, 0.0)	# Position of planet center on screen
var radius : float = 1.0	# Radius of the planet
var angle : float = 0.0	# The angle that the planet is rotated at
var axis : Vector3 = Vector3(1.0, 1.0, 1.0)	# The axis that the planet rotates around
var rotation_speed : float = 0.1	# The speed that the planet rotates at

# Colors of the planet
var planet_color_main : Color
var planet_color_light : Color
var planet_color_dark : Color

var light_source : Vector3 = Vector3(1.0, 1.0, 1.0)	# 3D origin of light source

# Base atmosphere color and sunset/sunrise atmosphere color
var base_atmo_color : Vector3 = Vector3(1.0, 1.0, 1.0)
var horizon_atmo_color : Vector3 = Vector3(0.0, 0.0, 0.0)

var atmo_color_min : float = 0.25
var atmo_color_max : float = 1.0

# Thickness of the atmosphere
var atmo_thickness : float = 1.0

func _ready() -> void:
	# Generate a planet upon loading in
	gen_planet()
	
	# Send global space color to shader
	material.set_shader_parameter("SPACE_COLOR", Globals.SPACE_COLOR)


func _process(delta: float) -> void:
	# Increase the angle and send the new angle to the shader
	angle += (rotation_speed * delta) / 2.0
	material.set_shader_parameter("angle", angle)
	%FPS.text = "FPS: " + str(Engine.get_frames_per_second())

func gen_planet() -> void:
	# Generate a radius for the planet, depending on the width of the render res
	radius = randf_range(
		Globals.planet_render_res.x / 8,
		Globals.planet_render_res.x / 4
	)

	angle = 0.0	# Reset the angle
	rotation_speed = randf_range(0.01, 0.1)	# New rotation speed
	# Generate center for new planet, can't go past outer quarter of screen
	planet_pos = Vector2(
		randf_range(Globals.planet_render_res.x * 0.25, 0.75 * Globals.planet_render_res.x),
		randf_range(Globals.planet_render_res.y * 0.25, 0.75 * Globals.planet_render_res.y)
	)
	# Generate a random axis for the new planet to rotate around
	axis = Vector3(
		randf_range(-1,1),
		randf_range(-1,1),
		randf_range(-1,1)
	)

	gen_colors()	# Generate new colors

	# Generate a new noise texture and scale the frequency to the planet size
	noise_texture.noise.seed = randi()
	noise_texture.noise.frequency = 0.1 * (radius/Globals.planet_render_res.y)

	# Make a new light source, orthogonal to the axis that the planet rotates around
	light_source = axis.cross(Vector3(1,1,1))
	
	atmo_thickness = randf_range(0.95, 1.2)	# New random atmosphere thickness

	set_shader_params()	# Update the shader parameters

# Update the shader parameters for the new planet
func set_shader_params() -> void:
	material.set_shader_parameter("color_main", planet_color_main)
	material.set_shader_parameter("color_light", planet_color_light)
	material.set_shader_parameter("color_dark", planet_color_dark)
	material.set_shader_parameter("coords", planet_pos)
	material.set_shader_parameter("radius", radius)
	material.set_shader_parameter("axis", axis)
	material.set_shader_parameter("light_source", light_source)
	material.set_shader_parameter("base_atmo_color", base_atmo_color)
	material.set_shader_parameter("horizon_atmo_color", horizon_atmo_color)
	material.set_shader_parameter("atmo_thickness", atmo_thickness)
	material.set_shader_parameter("noise_texture", noise_texture)

# Generate new colors for the planet
func gen_colors() -> void:
	# Generate random main color
	planet_color_main = Color(
		clamp(randf(), 0.5, 0.9),
		clamp(randf(), 0.5, 0.9),
		clamp(randf(), 0.5, 0.9),
	)
	# Light color is slightly more yellow than main
	planet_color_light = Color(
		planet_color_main.r * 1.2,
		planet_color_main.g * 1.2,
		planet_color_main.b * 0.8
	)
	# Dark color is slightly more blue than main
	planet_color_dark = Color(
		planet_color_main.r * 0.8,
		planet_color_main.g * 0.8,
		planet_color_main.b * 1.2,
	)

	# Generate base atmosphere color
	base_atmo_color = Vector3(
		randf_range(atmo_color_min, atmo_color_max),
		randf_range(atmo_color_min, atmo_color_max),
		randf_range(atmo_color_min, atmo_color_max)
	)
	# Horizon color is "inverse" of base color
	# max - value + min
	# e.g. 1.0-0.8+0.5 = 0.2+0.5 = 0.7 
	horizon_atmo_color = Vector3(
		atmo_color_max - base_atmo_color.x + atmo_color_min,
		atmo_color_max - base_atmo_color.y + atmo_color_min,
		atmo_color_max - base_atmo_color.z + atmo_color_min
	)

# Draw a white rectangle over the screen, but the shader only renders the
# planet and its atmosphere
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Globals.planet_render_res), Color.WHITE)
