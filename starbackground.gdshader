shader_type canvas_item;

uniform vec3 SPACE_COLOR = vec3(0.0);
uniform sampler2D noise_texture;

void fragment() {
	vec2 pos = VERTEX;
	
	vec4 star_noise = texture(noise_texture, UV);
	vec3 brightness = abs(star_noise.xyz);
	
	if (sqrt(dot(brightness,brightness)) > 1.6) {
		COLOR = vec4(0.24, 0.24, 0.24, 1.0);
	}
	else {
		COLOR = vec4(SPACE_COLOR, 1.0);
	}
}