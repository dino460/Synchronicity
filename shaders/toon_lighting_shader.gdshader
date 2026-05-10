shader_type spatial;

//render_mode ambient_light_disabled;
render_mode depth_draw_opaque;
//const float PI = 3.1415926536f;

group_uniforms color;
uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D albedo_texture : source_color;
uniform bool clamp_diffuse_to_max = false;

group_uniforms clouds;
global uniform float cloud_cover_scale;
global uniform float cloud_cover_intensity;
global uniform vec2 cloud_scroll_speed;
global uniform sampler2D cloud_noise_texture;
global uniform float cloud_cover_threshold;
//uniform float correction = 1.0f;

group_uniforms toon_shading;
uniform int cuts : hint_range(1, 8) = 3;
uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;
uniform float threshold_gradient_size = 0.2; // Hybrid toon shading control (set to 0 for standard toon shading)

uniform bool use_attenuation = true;

uniform bool use_specular = true;
uniform float specular_strength : hint_range(0.0f, 1.0f) = 1.0f;
uniform float specular_shininess : hint_range(0.0f, 32.0f) = 16.0f;
uniform sampler2D specular_map : source_color;

uniform bool use_rim = true;
uniform float rim_width : hint_range(0.0f, 16.0f) = 8.0f;
uniform vec4 rim_color : source_color = vec4(1.0f);

uniform bool use_ramp = false;
uniform sampler2D ramp : source_color;

uniform bool use_borders = false;
uniform float border_width = 0.01f;

varying vec3 instance_pos;
varying vec3 vertex_pos;
varying vec3 normal;

float split_specular(float specular) {
	return step(0.5f, specular);
}

void vertex() {
	instance_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vertex_pos = VERTEX;
	normal = NORMAL;
}

void fragment() {
	ALBEDO = albedo.rgb * texture(albedo_texture, UV).rgb;
}

void light() {
	// Attenuation.
	float attenuation = 1.0f;
	
	// Convert LIGHT from view space to world space
	vec3 LIGHT_world_space = (INV_VIEW_MATRIX * vec4(LIGHT, 0.0)).xyz;
	
	// Manipulate cloud noise UV values
	vec2 cloud_uv = (instance_pos.xz + (cloud_scroll_speed * TIME) /*+ (LIGHT_world_space.xz / 2.0f)*/) * (cloud_cover_scale);
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
		DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, diffuse * attenuation);
	} else {
		DIFFUSE_LIGHT += diffuse * attenuation;
	}
}