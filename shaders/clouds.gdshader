shader_type spatial;

render_mode cull_disabled;

group_uniforms cloud_cover;
global uniform float cloud_cover_scale;
global uniform float cloud_cover_intensity;
global uniform sampler2D cloud_noise_texture;
global uniform float cloud_cover_threshold;
global uniform vec2 cloud_plane_offset; // integrated by cloud_sheet.gd

uniform float pixelation : hint_range(16.0, 512.0, 1.0) = 512;

varying vec2 v_plane;

void vertex() {
	// Position on the sheet in its own axes (works with any quad scale).
	vec3 rel = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz - MODEL_MATRIX[3].xyz;
	v_plane = vec2(dot(rel, normalize(MODEL_MATRIX[0].xyz)),
	               dot(rel, normalize(MODEL_MATRIX[1].xyz)));
}

void fragment() {
	vec2 cloud_uv = (v_plane + cloud_plane_offset) * cloud_cover_scale;
	cloud_uv = floor(cloud_uv * pixelation) / pixelation;
	float cloud_cover = texture(cloud_noise_texture, cloud_uv).r;
	cloud_cover = (cloud_cover >= cloud_cover_threshold) ? 1.0 : 0.0;

	ALPHA_SCISSOR_THRESHOLD = 1.0;
	ALPHA = cloud_cover;
}