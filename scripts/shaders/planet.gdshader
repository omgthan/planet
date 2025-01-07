shader_type canvas_item;

uniform vec3 SPACE_COLOR = vec3(0.0);

uniform float angle; // current rotation angle of the planet
uniform float radius = 1.0; // radius of the planet
uniform vec3 axis; // axis to rotate the planet around
uniform vec2 coords = vec2(1.0, 1.0); // the center of the planet on the 2d screen

uniform sampler3D noise_texture; // 3d noise texture for planet surface

uniform vec3 color_main; // the base color for the planet
uniform vec3 color_light; // lighter version of base
uniform vec3 color_dark; // darker version of base

uniform vec3 light_source = vec3(0.0, 0.0, 0.0); // 3d origin of light source

uniform vec3 horizon_atmo_color; // atmosphere color at the horizon
uniform vec3 base_atmo_color; // normal atmosphere color
uniform float atmo_thickness = 1.0; // thickness of atmosphere

// apply a matrix rotation to a point around an axis from a certain angle
mat3 rotation_from_axis_and_angle(vec3 rotate_axis, float rotate_angle) {
	// unit vector for the axis to rotate around
	vec3 u = normalize(rotate_axis);
	return mat3(
		vec3(
			u.x * u.x * (1.0 - cos(rotate_angle)) + cos(rotate_angle),
			u.x * u.y * (1.0 - cos(rotate_angle)) - u.z * sin(rotate_angle),
			u.x * u.z * (1.0 - cos(rotate_angle)) + u.y * sin(rotate_angle)
		),
		vec3(
			u.x * u.y * (1.0 - cos(rotate_angle)) + u.z * sin(rotate_angle),
			u.y * u.y * (1.0 - cos(rotate_angle)) + cos(rotate_angle),
			u.y * u.z * (1.0 - cos(rotate_angle)) - u.x * sin(rotate_angle)
		),
		vec3(
			u.x * u.z * (1.0 - cos(rotate_angle)) - u.y * sin(rotate_angle),
			u.y * u.z * (1.0 - cos(rotate_angle)) + u.x * sin(rotate_angle),
			u.z * u.z * (1.0 - cos(rotate_angle)) + cos(rotate_angle)
		)
	);
}

vec3 mix_surface_atmo_color(vec3 surface_color, vec3 atmo_color, bool has_atmo) {
	return mix(
		// mix the surface color with the atmosphere color
		// bias determined by thickness of atmosphere scaled from 0 to 1 (* 3/4)
		surface_color,
		atmo_color,
		((atmo_thickness - 0.95) / (1.2 - 0.95)) * float(has_atmo) * 0.6
	);
}

// calculate the color to apply at the certain point on the planet
vec3 get_color(
	vec3 surface_color, vec3 surface_diffuse, vec3 atmo_color,
	bool has_atmo, float distance_from_light
) {
	return max(
		mix(mix_surface_atmo_color(surface_color, atmo_color, has_atmo), SPACE_COLOR, 0.98),
		mix_surface_atmo_color(surface_color, atmo_color, has_atmo) * surface_diffuse
	);
}

void fragment() {
	/*
		get the XY position on the sphere for the current pixel
		the first part gets the offset of the pixel from the planet center
			(planet origin pixel - current pixel)
		second part scales the current pixel by the radius
			e.g. with an offset of 20px and a radius of 40px, the final value is 0.5
			every axis is scaled from 0 to 1
	*/
	vec2 pos = vec2(
		(coords.x - VERTEX.x) / radius,
		(coords.y - VERTEX.y) / radius
	);

	float atmo_radius = radius * atmo_thickness;
	vec2 atmo_pos = vec2(
		(coords.x - VERTEX.x) / atmo_radius,
		(coords.y - VERTEX.y) / atmo_radius
	);

	/*
		3d point on the sphere, combining pos (XY) and the distance formula using
		pos to get the z value of the point
	*/
	vec3 point = vec3(pos, sqrt(1.0 - dot(pos,pos)));
	vec3 atmo_point = vec3(atmo_pos, sqrt(1.0 - dot(atmo_pos, atmo_pos)));

	// get the rotation matrix around the custom axis at the new angle for this frame
	mat3 planet_rotation = rotation_from_axis_and_angle(axis, angle);


	/*
		light_dir:			light direction is the normalized light source, with the rotation matrix applied
		light_color:		color of the light, set to be white but might change to be variable at some point
		diffuse_strength:	get the diffuse strength at the current point, which is the light direction dot the surface normal
		diffuse:			diffuse color
	*/
	vec3 light_dir = normalize(light_source) * planet_rotation;
	vec3 light_color = vec3(1.0);
	float diffuse_strength = max(0.0, dot(normalize(light_dir), point));
	vec3 diffuse = diffuse_strength * light_color;

	// modify the point lookup by the rotation matrix to rotate the sphere
	point *= planet_rotation;

	/*
		btw this section doesn't really have strictly defined rules in place, i was
		just trying to find a way to display the different colors of the atmosphere
		somewhat nicely
		atmo_strength:			same as diffuse_strength but for atmosphere
		atmo_color_strength:	scale the distance from the current point to a point on the axis
									this effectively scales the current point to the maximum possible
									distance that the light reaches
		atmo_color:				scales the color between the normal color and sunrise/sunset color
									based on the square of the atmo_color_strength
		atmo_diffuse:			diffuse color of the atmosphere
	*/
	float atmo_strength = max(0.0, dot(normalize(light_dir), atmo_point));
	float atmo_color_strength = distance(normalize(atmo_point), light_dir) / distance(normalize(axis), light_dir);
	vec3 atmo_color = light_color * mix(base_atmo_color, horizon_atmo_color, pow(atmo_color_strength, 2.0));
	vec3 atmo_color_surface = light_color * mix(horizon_atmo_color, base_atmo_color, pow(diffuse_strength, 2.0));
	vec3 atmo_diffuse = atmo_strength * atmo_color;

	bool has_atmo = atmo_thickness > 1.0;

	/*
		this scales the point values to be from 0 to 1 instead of
		(presumably) -1 to 1. from a technical standpoint, not sure why
		this works the way it does but it displays the planet correctly
		removing this line seems to make the surface texture symmetrical
	*/
	point = point/2.0 + 0.5;
	atmo_point = atmo_point/(atmo_thickness * 2.0) + atmo_thickness/2.0;

	// get the noise value at the current point
	vec4 surface_noise = texture(noise_texture, abs(point));

	// depth is the absolute value of the noise value at the point
	vec3 depth = vec3(abs(surface_noise.xyz));

	// distance from the pixel to the center of the circle
	float circle_distance = sqrt(dot(pos,pos));
	float dist_from_light = distance(normalize(point), light_dir);

	// set the color, using the depth point to determine the color at the current point
	// atmo strength application is done arbitrarily, no significance behind the formula
	if (sqrt(dot(depth,depth)) > 0.999) {
		COLOR = vec4(
			// choose the max between background space color and the actual color
			get_color(color_light, diffuse, atmo_color_surface, has_atmo, dist_from_light),
			float(circle_distance < 1.0)
		);
	}
	else if (sqrt(dot(depth,depth)) < 0.7){
		COLOR = vec4(
			// choose the max between background space color and the actual color
			get_color(color_dark, diffuse, atmo_color_surface, has_atmo, dist_from_light),
			float(circle_distance < 1.0)
		);
	}
	else {
		COLOR = vec4(
			// choose the max between background space color and the actual color
			get_color(color_main, diffuse, atmo_color_surface, has_atmo, dist_from_light),
			float(circle_distance < 1.0)
		);
	}

	// set the color of the atmosphere
	if (circle_distance >= 1.0 && circle_distance < atmo_thickness) {
		if (bool(has_atmo)) {
			COLOR = vec4(
				atmo_diffuse,
				pow(abs(circle_distance - atmo_thickness) / (0.2), 3.0) * atmo_strength
			);
		} else {
			COLOR = vec4(0.0);
		}
	}
}