shader_type spatial;

render_mode depth_prepass_alpha, depth_draw_opaque;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap, repeat_disable;

varying vec3 instance_origin;

void vertex() {
	// Called for every vertex the material is visible on.
	instance_origin = MODELVIEW_MATRIX[3].xyz;
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
	NORMAL = vec3(0.0, 1.0, 0.0);
}

void fragment() {
	//LIGHT_VERTEX = instance_origin;
	vec2 base_uv = UV;
	vec4 original_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	ALBEDO = original_color.rbg;
	//ALPHA = 1.0;
	// Called for every pixel the material is visible on.
}

//void light() {
	//// Called for every pixel for every light affecting the material.
	//// Uncomment to replace the default light processing function with this one.
	//float attenuation = ATTENUATION;
	//float NdotL = dot(NORMAL, LIGHT);
	//float diffuse_amount = NdotL + (attenuation - 1.0);
//
	//vec3 diffuse = ALBEDO.rgb * LIGHT_COLOR / PI;
	//diffuse *= diffuse_amount;
	//DIFFUSE_LIGHT += diffuse;
//}
