extends Node2D

@export var star_noise_texture : NoiseTexture2D

func _ready() -> void:
	refresh_noise()
	material.set_shader_parameter("SPACE_COLOR", Globals.SPACE_COLOR)
	material.set_shader_parameter("noise_texture", star_noise_texture)

func refresh_noise() -> void:
	star_noise_texture.noise.seed = randi()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Globals.planet_render_res), Color.WHITE)
