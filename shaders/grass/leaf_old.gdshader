shader_type spatial;

render_mode depth_draw_opaque;

//uniform vec4 color : source_color;
//uniform sampler2D alpha;
uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform float leaves_scale : hint_range(0.0, 1.0) = 1.0;
uniform float cuts = 3;

uniform float rim_width : hint_range(0.0f, 16.0f) = 8.0f;
uniform vec4 rim_color : source_color = vec4(1.0f);

varying vec4 view_pos;

void vertex() {
	view_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	
	vec4 new_position = vec4(UV.y, UV.x, 0.0, 1.0);
	new_position = new_position * 2.0 - 1.0;
	new_position = normalize(new_position);
	new_position *= leaves_scale;
	new_position *= MODELVIEW_MATRIX;
	
	VERTEX += new_position.xyz;
}

void fragment() {
	LIGHT_VERTEX = view_pos.xyz;
	vec4 final_tex = texture(albedo_texture,UV);

	ALBEDO = albedo.rgb * final_tex.rgb;
	ALPHA *= albedo.a * final_tex.a;
	//ALBEDO = color.rgb;
	//ALPHA = texture(alpha, UV).r;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ROUGHNESS = 0.0;
	SPECULAR = 0.0;
}

void light() {
	float attenuation = 1.0f;
	if (!LIGHT_IS_DIRECTIONAL) {
		attenuation = ATTENUATION;
	}
	
	// Diffuse lighting.
	float NdotL = dot(NORMAL, LIGHT);
	//float diffuse_amount = NdotL + (attenuation - 1.0) + wrap;
	float diffuse_amount = NdotL * attenuation;
	diffuse_amount *= 1.0;
	float cuts_inv = 1.0f / float(cuts);
	float diffuse_stepped;
	if (LIGHT_IS_DIRECTIONAL) {
		diffuse_stepped = clamp(diffuse_amount, 0.0f, 1.0f);
	} else {
		diffuse_stepped = clamp(diffuse_amount + mod(1.0f - diffuse_amount, cuts_inv), 0.0f, 1.0f);
	}
	
	// Apply diffuse result to different styles.
	vec3 diffuse = ALBEDO.rgb * LIGHT_COLOR / PI * ATTENUATION;
	// Clamp diffuse to max for multiple light sources.
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, diffuse);
	
	float NdotV = dot(NORMAL, VIEW);
	float rim_light = pow(1.0 - NdotV, rim_width) * ATTENUATION;
	DIFFUSE_LIGHT += rim_light * rim_color.rgb * rim_color.a * LIGHT_COLOR / PI;
	
	//// Cel shaded diffuse lighting
	//float light = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	//light = ceil(light * cuts) / cuts;
	//DIFFUSE_LIGHT += light * (LIGHT_COLOR / PI) * ATTENUATION;
//
	//// Rim Lighting
	//float rim = 1.0 - dot(NORMAL, VIEW);
	//rim *= light;
	//rim = round(rim * cuts) / cuts;
	//rim = rim * rim;
	//DIFFUSE_LIGHT += rim * ATTENUATION * LIGHT_COLOR / PI;
}
