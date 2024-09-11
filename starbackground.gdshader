shader_type canvas_item;

uniform sampler2D noise_texture;

void fragment() {
	vec2 pos = VERTEX;
	
	vec4 star_noise = texture(noise_texture, UV);
	vec3 brightness = abs(star_noise.xyz);
	
	if (sqrt(dot(brightness,brightness)) > 1.6) {
		COLOR = vec4(0.24, 0.24, 0.24, 1.0);
	}
	else {
		COLOR = vec4(0.05, 0.065, 0.09, 1.0);
	}
}