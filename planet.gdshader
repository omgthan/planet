shader_type canvas_item;

uniform float angle; // current rotation angle of the planet
uniform float radius = 1.0; // radius of the planet
uniform vec3 axis; // axis to rotate the planet around
uniform vec2 coords = vec2(1.0, 1.0); // position of the planet on the screen

uniform sampler3D noise_texture; // 3d noise texture for planet surface

uniform vec4 color_main; // the base color for the planet, rgb between 0.2 and 0.8
uniform vec4 color_light; // 1.2 * rg of base, 0.8 * b of base
uniform vec4 color_dark; // 0.8 * rg of base, 1.2 * b of base

uniform vec3 light_source = vec3(0.0, 0.0, 0.0);
uniform vec3 light_axis;
uniform vec3 light_angle;

uniform vec3 lower_atmo_color;
uniform vec3 higher_atmo_color;
uniform float atmo_thickness = 1.0;

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

void fragment() {
	// XY position on the sphere
	vec2 pos = vec2(
		-((coords.x)/2.0 - VERTEX.x) / radius,
		-((coords.y)/2.0 - VERTEX.y) / radius
	);
	
	float atmo_radius = radius * atmo_thickness;
	vec2 atmo_pos = vec2(
		-((coords.x)/2.0 - VERTEX.x) / atmo_radius,
		-((coords.y)/2.0 - VERTEX.y) / atmo_radius
	);
	
	// distance from the center of the sphere using XY, given the z position
	float z_dist = sqrt(1.0 - dot(pos,pos));
	float atmo_z_dist = sqrt(1.0 - dot(atmo_pos, atmo_pos));
	
	// 3d point on the sphere, combining pos (XY) and z_dist (Z)
	vec3 point = vec3(pos, z_dist);
	vec3 atmo_point = vec3(atmo_pos, atmo_z_dist);
	
	// rotation around an axis
	mat3 planet_rotation = rotation_from_axis_and_angle(axis, angle);
	
	vec3 light_dir = normalize(light_source) * planet_rotation;
	vec3 light_color = vec3(1.0, 1.0, 1.0);
	float diffuse_strength = max(0.0, dot(normalize(light_dir), point));
	vec3 diffuse = diffuse_strength * light_color;
	
	// modify the point lookup by the rotation matrix to rotate the sphere
	point *= planet_rotation;
	
	/*
		i don't remember what this does exactly, i think it changes
		the bounds of the point to be between 0 and 1
	*/
	point = point/2.0 + 0.5;
	
	// get the noise value at the current point
	vec4 surface_noise = texture(noise_texture, abs(point));
	
	// depth is the absolute value of the noise value at the point
	vec3 depth = vec3(abs(surface_noise.xyz));
	
	// distance from the pixel to the center of the circle
	float circle_distance = sqrt(dot(pos,pos));
	
	float atmo_strength = max(0.0, dot(normalize(light_dir), atmo_point));
	float atmo_color_strength = distance(normalize(atmo_point), light_dir) / distance(normalize(axis), light_dir);
	vec3 atmo_color = light_color * mix(higher_atmo_color, lower_atmo_color, pow(atmo_color_strength, 2.0));
	vec3 atmo_diffuse = atmo_strength * atmo_color;
	
	// set the color, using the depth point to determine the color at the current point
	if (sqrt(dot(depth,depth)) > 0.999) {
		COLOR = vec4(
			// choose the max between background space color and the actual color
			max(vec3(0.05, 0.065, 0.09), color_light.rgb * diffuse + (atmo_diffuse * (atmo_thickness - 1.0) / 0.2) * 0.75),
			float(circle_distance < 1.0)
		);
	}
	else if (sqrt(dot(depth,depth)) < 0.7){
		COLOR = vec4(
			// choose the max between background space color and the actual color
			max(vec3(0.05, 0.065, 0.09), color_dark.rgb * diffuse + (atmo_diffuse * (atmo_thickness - 1.0) / 0.2) * 0.75),
			float(circle_distance < 1.0)
		);
	}
	else {
		COLOR = vec4(
			// choose the max between background space color and the actual color
			max(vec3(0.05, 0.065, 0.09), color_main.rgb * diffuse + (atmo_diffuse * (atmo_thickness - 1.0) / 0.2) * 0.75),
			float(circle_distance < 1.0)
		);
	}
	
	
	
	// set the color of the atmosphere
	if (circle_distance >= 1.0 && circle_distance < atmo_thickness) {
		COLOR = vec4(
			max(vec3(0.05, 0.065, 0.09), atmo_diffuse),
			pow(abs((circle_distance - atmo_thickness)) * (1.0 / (atmo_thickness - 1.0)), 2.0)
		);
	}
}