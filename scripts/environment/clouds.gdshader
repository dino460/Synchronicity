shader_type spatial;

group_uniforms cloud_cover;
global uniform float cloud_cover_scale;
global uniform float cloud_cover_intensity;
global uniform vec2 cloud_scroll_speed;
global uniform sampler2D cloud_noise_texture;
global uniform float cloud_cover_threshold;

uniform float pixelation : hint_range(16.0, 512.0, 1.0) = 512;

varying vec3 v_world_pos;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 cloud_uv = (v_world_pos.xz + (cloud_scroll_speed * TIME)) * cloud_cover_scale;
	cloud_uv = floor(cloud_uv * pixelation) / pixelation;
	float cloud_cover = texture(cloud_noise_texture, cloud_uv).r;
	cloud_cover = (cloud_cover >= cloud_cover_threshold) ? 1.0 : 0.0;
	
	ALPHA_SCISSOR_THRESHOLD = 1.0;
	ALPHA = cloud_cover;
}