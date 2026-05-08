shader_type spatial;

render_mode depth_draw_opaque;


uniform float time_scale = 1.0;

group_uniforms animation;
uniform int hframe : hint_range(1,128);
uniform int vframe : hint_range(1,128);
uniform vec2 current_frame = vec2(0,0);

group_uniforms clouds;
global uniform float cloud_cover_scale = 1.0;
global uniform float cloud_cover_intensity = 0.3;
global uniform vec2 cloud_scroll_speed = vec2(0.5, 0.2);
global uniform sampler2D cloud_noise_texture;
global uniform float cloud_cover_threshold;

group_uniforms color;
uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform float accent_noise_scale = 1.0;
uniform sampler2D grass_dark_noise;
uniform sampler2D grass_light_noise;

group_uniforms color.secondary;
uniform vec4 albedo_accent_lighter : source_color = vec4(1.0f);
uniform float albedo_lighter_threshold = 0.595;

group_uniforms color.tertiary;
uniform vec4 albedo_accent_darker : source_color = vec4(1.0f);
uniform float albedo_darker_threshold = 0.63;

group_uniforms toon_shading;
uniform int cuts : hint_range(1, 8) = 3;
uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;
uniform float threshold_gradient_size = 0.2; // Hybrid toon shading control (set to 0 for standard toon shading)
uniform bool clamp_diffuse_to_max = false;

uniform bool use_attenuation = true;

varying vec3 instance_origin;
varying vec3 instance_pos;

void vertex() {
	instance_pos = MODEL_MATRIX[3].xyz;
	instance_origin = MODELVIEW_MATRIX[3].xyz;
	
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
	NORMAL = vec3(0.0, 1.0, 0.0);
}

void fragment() {
	LIGHT_VERTEX = instance_origin;
	
	float time = (TIME * time_scale) + instance_pos.x - instance_pos.z;
	
	vec2 base_uv = (UV / vec2(float(hframe),float(vframe)));
	base_uv += (current_frame + floor(time))/vec2(float(hframe),float(vframe));
	vec4 final_tex = texture(albedo_texture, base_uv);
	
	float albedo_light_noise = texture(grass_light_noise, instance_pos.xz * (accent_noise_scale)).r;
	float albedo_dark_noise = texture(grass_dark_noise, instance_pos.xz * (accent_noise_scale)).r;
	vec3 final_albedo;
	final_albedo = albedo.rgb;
	if (albedo_light_noise > albedo_lighter_threshold) {
		final_albedo = albedo_accent_lighter.rgb;
	}
	if (albedo_dark_noise > albedo_darker_threshold) {
		final_albedo = albedo_accent_darker.rgb;
	}
	
	ALBEDO = final_albedo.rgb * final_tex.rgb;
	ALPHA *= final_tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}

void light() {
	// Attenuation.
	float attenuation = 1.0f;
	
	// Convert LIGHT from view space to world space
	vec3 LIGHT_world_space = (INV_VIEW_MATRIX * vec4(LIGHT, 0.0)).xyz;
	vec3 LIGHT_xz_projected = vec3(LIGHT_world_space.x, LIGHT_world_space.y, LIGHT_world_space.z);
	
	// Manipulate cloud noise UV values
	vec2 cloud_uv = (instance_pos.xz + (cloud_scroll_speed * TIME) /*+ (LIGHT_world_space.xz / 2.0f)*/) * (cloud_cover_scale);
	//vec2 cloud_uv = vec2(instance_pos.x, instance_pos.y * LIGHT_world_space.y);
	// Stretch UV in direction of the sun LIGHT
	cloud_uv = vec2(cloud_uv.x, cloud_uv.y * LIGHT_world_space.y);
	
	//Sample texture value for current pixel 
	float cloud_cover = texture(cloud_noise_texture, cloud_uv).r;
	
	// Threshold value for crisp shadows 
	if (cloud_cover >= cloud_cover_threshold) {
		cloud_cover = 0.0;
	} else {
		cloud_cover = 1.0;
	}
	
	//cloud_cover -= cloud_cover_intensity;
	
	// Apply a shadow if it exists
	if (use_attenuation) {
		if (LIGHT_IS_DIRECTIONAL) {
			attenuation = min(ATTENUATION, cloud_cover);
		} else {
			attenuation = ATTENUATION;
		}
		//attenuation = ATTENUATION;
	}

	// Diffuse lighting.
	float NdotL = dot(NORMAL, LIGHT);
	float diffuse_amount = NdotL + (attenuation - 1.0) + wrap;
	//float diffuse_amount = NdotL * attenuation;
	diffuse_amount *= steepness;
	float cuts_inv = 1.0f / float(cuts);
	float diffuse_stepped;
	
	//Toon Shading
	if (LIGHT_IS_DIRECTIONAL) {
		diffuse_stepped = clamp(diffuse_amount, 0.0f, 1.0f);
	} else {
		diffuse_stepped = clamp(diffuse_amount + mod(1.0f - diffuse_amount, cuts_inv), 0.0f, 1.0f);
	}
	
	// Hybrid Toon Shading
	if (threshold_gradient_size > 0.0) {
		// Find nearest threshold (k * cut). We use rounding so the threshold chosen is the boundary that the original hard-step used around this value.
		float nearest_k = floor(diffuse_amount / cuts_inv + 0.5); // round to nearest integer
		float threshold = nearest_k * cuts_inv;

		// Do not create gradients at the global edges (threshold==0 or threshold==1)
		if (nearest_k >= 0.0 && nearest_k <= float(cuts)) {
			float halfWidth = 0.5 * cuts_inv * threshold_gradient_size;

			// Clamp gradient low/high so they stay inside 0 to 1
			float low  = max(0.0, threshold - halfWidth);
			float high = min(1.0, threshold + halfWidth);

			float blend = 0.0;
			if (high > low) {
				blend = smoothstep(low, high, diffuse_amount);
			} else {
				blend = step(threshold, diffuse_amount);
			}

			// define which cut colours/lighting you take for upper and lower boundary
			float leftValue  = threshold;
			float rightValue = min(threshold + (cuts_inv * 1.0), 1.0);
			diffuse_stepped = mix(leftValue, rightValue, blend);
			diffuse_stepped = clamp(diffuse_stepped, 0.0, 1.0);
		}
	}

	// Apply diffuse result to different styles.
	vec3 diffuse = ALBEDO.rgb * LIGHT_COLOR / PI;
	diffuse *= diffuse_stepped;

	if (clamp_diffuse_to_max) {
		// Clamp diffuse to max for multiple light sources.
		DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, diffuse);
	} else {
		DIFFUSE_LIGHT += diffuse * attenuation;
	}
}