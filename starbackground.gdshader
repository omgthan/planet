shader_type canvas_item;

uniform vec3 SPACE_COLOR = vec3(0.0);
uniform sampler2D noise_texture;
const vec3 STAR_COLOR = vec3(0.2);

void fragment() {
	vec2 pos = VERTEX;
	
	float brightness = texture(noise_texture, UV).r;
	
	if (brightness > 0.95) {
		COLOR = mix(vec4(STAR_COLOR, 1.0), vec4(SPACE_COLOR, 1.0), 0.35);
	} else {
		COLOR = vec4(SPACE_COLOR, 1.0);
	}
}