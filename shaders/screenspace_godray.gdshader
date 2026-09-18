//based on GPU Gems 3: Chapter 13. Volumetric Light Scattering as a Post-Process
shader_type spatial;
render_mode unshaded, cull_front, fog_disabled, blend_add;

uniform sampler2D depth_tex : hint_depth_texture,filter_nearest;

//attach a script that pass the -global_basis.z of your directional light
instance uniform vec3 light_world_dir = vec3(0.0, -1.0, 0.0);

uniform int num_samples = 32;
uniform float density = 0.75;
uniform float weight = 0.02;
uniform float decay = 0.95;
uniform float exposure = 0.5;

uniform float light_fade_start:hint_range(0.0, 1.0, 0.1) = 0.8;
uniform float light_fade_end:hint_range(0.0, 1.0, 0.1) = 1.0;

uniform vec3 ambient_col : source_color = vec3(1.167, 1.182, 0.725);

float bayer4x4(vec2 uv, vec2 viewport_size) {
	ivec2 p = ivec2(mod(uv * viewport_size, 4.0));
	int index = p.x + p.y * 4;

	float matrix[16] = float[](
		0.0/16.0,  8.0/16.0,  2.0/16.0, 10.0/16.0,
		12.0/16.0, 4.0/16.0, 14.0/16.0,  6.0/16.0,
		3.0/16.0, 11.0/16.0,  1.0/16.0,  9.0/16.0,
		15.0/16.0, 7.0/16.0, 13.0/16.0,  5.0/16.0
	);

	return matrix[index];
}

float sample_depth_value(sampler2D depth_texture, vec2 uv, float default_val)
{
	if (uv.x < 0.0 || uv.x > 1.0 ||
		uv.y < 0.0 || uv.y > 1.0) {
		return default_val;
	}
	return texture(depth_texture,uv).r;
}
void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);	
}

void fragment() {
	vec3 light_dir = normalize(light_world_dir);

	// Project directional light to screen
	vec3 world_light_pos = CAMERA_POSITION_WORLD + light_dir * 1000.0;
	vec4 clip = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world_light_pos, 1.0);
	vec2 ndc = clip.xy / clip.w;
	vec2 light_screen_pos = ndc * 0.5 + 0.5;

	// Prevent extreme stretching when off-screen
	light_screen_pos = clamp(light_screen_pos, -0.5, 1.5);

	// dither noise using bayer matrix to smooth out the banding
	// could use blue noise too
	float noise = bayer4x4(SCREEN_UV, VIEWPORT_SIZE);

	vec2 delta = (SCREEN_UV - light_screen_pos) / float(num_samples) * density;
	vec2 tex_coord = SCREEN_UV + delta * noise;

	vec3 color = vec3(0.0);
	float illumination_decay = 1.0;

	for (int i = 0; i < num_samples; i++) {
		tex_coord -= delta;

		//builtin function return any value outside screen as 0.0 meaning sky
		//for this we want any value outside screen as being occluded, so revert to 1.0
		float scene_depth = sample_depth_value(depth_tex,tex_coord,1.0);

		// Godot reversed Z:
		// near = 1.0
		// far / sky = 0.0
		//occlusion = 0 when depth>1e-10 using invert step function
		//otherwise occlusion = 1
		float occlusion = 1.0 - step(1e-10, scene_depth);

		float t = float(i) / float(num_samples);
		float sample_fade = 1.0-smoothstep(light_fade_start, light_fade_end, t);

		color += ambient_col *
				occlusion *
				illumination_decay *
				weight *
				sample_fade;
					
		illumination_decay *= decay;
	}

	float sun_facing =
		smoothstep(0.0, 0.3, dot(CAMERA_DIRECTION_WORLD, light_dir));

	ALBEDO = color * exposure* sun_facing;
}