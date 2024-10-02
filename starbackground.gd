extends Node2D

# Noise texture to generate the stars
@export var star_noise_texture : NoiseTexture2D

func _ready() -> void:
	refresh_noise()
	material.set_shader_parameter("SPACE_COLOR", Globals.SPACE_COLOR)
	material.set_shader_parameter("noise_texture", star_noise_texture)

# Generate a new noise texture
func refresh_noise() -> void:
	star_noise_texture.noise.seed = randi()

# Draw a white rectangle over the screen, but shader renders
# space background instead
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Globals.planet_render_res), Color.WHITE)
