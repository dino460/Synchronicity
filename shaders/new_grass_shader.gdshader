 shader_type spatial;

//render_mode depth_prepass_alpha, depth_draw_opaque;
render_mode diffuse_burley;

uniform bool do_billboard = false;
uniform float time_scale = 1.0;
uniform float pivot = 1.0;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_nearest, repeat_enable;
uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;
uniform int cuts : hint_range(1, 8) = 3;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

varying vec3 instance_origin;
varying float random_value;

void vertex() {
	random_value = INSTANCE_CUSTOM.z;

	float time = (TIME * (0.5 + INSTANCE_CUSTOM.y) * time_scale) + (6.28318 * INSTANCE_CUSTOM.x);
	float pivot_angle = cos(time) * 0.1 * pivot;
	mat2 rotation_matrix = mat2(vec2(cos(pivot_angle), -sin(pivot_angle)), vec2(sin(pivot_angle), cos(pivot_angle)));

	instance_origin = MODELVIEW_MATRIX[3].xyz;
	//billboarding
	if (do_billboard == true) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
		NORMAL = vec3(0.0, 1.0, 0.0);
	}
	VERTEX.xz = rotation_matrix * VERTEX.xz;
}

void fragment() {
	vec2 base_uv = UV;
	LIGHT_VERTEX = instance_origin;
	//vec4 original_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA *= albedo.a * albedo_tex.a;
}

void light() {
	float attenuation = ATTENUATION;
	float NdotL = dot(NORMAL, LIGHT);
	float diffuse_amount = NdotL + (attenuation - 1.0) + wrap;
	diffuse_amount *= steepness;
	float cuts_inv = 1.0f / float(cuts);
	float diffuse_stepped = clamp(diffuse_amount + mod(1.0f - diffuse_amount, cuts_inv), 0.0f, 1.0f);
	// Apply diffuse result
	vec3 diffuse = ALBEDO.rgb * LIGHT_COLOR / PI;
	diffuse *= diffuse_stepped;
	DIFFUSE_LIGHT += diffuse;
}