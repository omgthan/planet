shader_type canvas_item;

uniform vec3 SPACE_COLOR = vec3(0.0); // color of the space background
uniform sampler2D noise_texture; // noise texture input
const vec3 STAR_COLOR = vec3(0.2); // color of the stars

void fragment() {
	vec2 pos = VERTEX;

	// texture color at a point is grayscale value from 0 to 1, so just need to take one color channel
	float brightness = texture(noise_texture, UV).r;

	// if point is bright enough, color pixel as star, otherwise color as background
	if (brightness > 0.95) {
		COLOR = mix(vec4(STAR_COLOR, 1.0), vec4(SPACE_COLOR, 1.0), 0.35);
	} else {
		COLOR = vec4(SPACE_COLOR, 1.0);
	}
}