shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform float depth_scale = 100.0f;

varying vec3 world_position;

float getDepth(vec2 screen_uv, sampler2D depth_texture, mat4 inv_projection_matrix){
//	Credit: https://godotshaders.com/shader/depth-modulated-pixel-outline-in-screen-space/
	float raw_depth = texture(depth_texture, screen_uv)[0];
	vec3 normalized_device_coordinates = vec3(screen_uv * 2.0 - 1.0, raw_depth);
    vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);
	view_space.xyz /= view_space.w;
	return -view_space.z;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Output depth to the red channel (or pack into RGB for higher precision)
	float depth = getDepth(SCREEN_UV, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
	float world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;
	if (world_position.y > 0.0f) {
		ALBEDO = vec3(depth / depth_scale);
	} else {
		ALBEDO = vec3(10.0f);
	}
}
