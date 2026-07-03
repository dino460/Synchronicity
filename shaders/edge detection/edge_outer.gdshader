// object_outline_outer.gdshader
// Per-object outer silhouette outline using screen-space depth differencing.
// Use as a next_pass on any spatial material that should receive a dark outer edge.
// Does NOT run on meshes that don't have it assigned — grass is naturally excluded.
//
// Replaces: new_edge_outline.gdshader (screen-space quad post-process)
//
// The color logic is preserved exactly from the original:
//   outline color = mix(object's screen color, shadow_color, shadow_strength)
// This means the outline is tinted by the object's own color, not a flat black.
//
// How it works as a next_pass:
//   Fragment only executes over pixels covered by this object's geometry.
//   Depth differencing between SCREEN_UV and its neighbours detects where this
//   object's depth discontinuity lies (its silhouette against background or other
//   objects). ALPHA is driven by depth_diff so only edge pixels are visible —
//   interior pixels are fully transparent, zero overdraw.
//
// Setup:
//   - Assign as next_pass on your object's ShaderMaterial.
//   - Remove the old screen-space quad MeshInstance for new_edge_outline.
//   - The mask_texture uniform is no longer needed (per-object = implicit mask).

shader_type spatial;
render_mode unshaded, depth_draw_never, blend_mix;

// ----- Textures ----------------------------------------------------------------

uniform sampler2D DEPTH_TEXTURE  : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// ----- Uniforms (matching original new_edge_outline) ---------------------------

uniform bool  shadows_enabled = true;
uniform float shadow_strength    : hint_range(0.0, 1.0,  0.01) = 0.4;
uniform vec3  shadow_color       : source_color                 = vec3(0.0);

// Controls how many neighbour pixels to step out when sampling depth.
// 1.0 = one texel (matches original). Raise to 2-3 for a thicker outline.
uniform float outline_thickness  : hint_range(1.0, 8.0,  0.5)  = 1.0;

// ----- Helpers -----------------------------------------------------------------

float getDepth(vec2 uv, mat4 inv_projection_matrix) {
	float raw = texture(DEPTH_TEXTURE, uv)[0];
	vec3  ndc  = vec3(uv * 2.0 - 1.0, raw);
	vec4  view = inv_projection_matrix * vec4(ndc, 1.0);
	view.xyz  /= view.w;
	return -view.z;
}

// ----- Vertex ------------------------------------------------------------------

void vertex() {
	// No position modification — geometry is unchanged.
	// We are just an overlay pass that reads screen data.
}

// ----- Fragment ----------------------------------------------------------------

void fragment() {
	vec2 e = (vec2(1.0) / VIEWPORT_SIZE.xy) * outline_thickness;

	float depth_diff    = 0.0;

	if (shadows_enabled) {
		float depth = getDepth(SCREEN_UV, INV_PROJECTION_MATRIX);
		float du    = getDepth(SCREEN_UV + vec2( 0.0, -1.0) * e, INV_PROJECTION_MATRIX);
		float dr    = getDepth(SCREEN_UV + vec2( 1.0,  0.0) * e, INV_PROJECTION_MATRIX);
		float dd    = getDepth(SCREEN_UV + vec2( 0.0,  1.0) * e, INV_PROJECTION_MATRIX);
		float dl    = getDepth(SCREEN_UV + vec2(-1.0,  0.0) * e, INV_PROJECTION_MATRIX);
		
		float dx = dFdx(depth);
		float dy = dFdy(depth);
		
		float expected_u = -dy;
		float expected_d =  dy;
		float expected_r =  dx;
		float expected_l = -dx;

		depth_diff += clamp((du - depth) - expected_u, 0.0, 1.0);
		depth_diff += clamp((dd - depth) - expected_d, 0.0, 1.0);
		depth_diff += clamp((dr - depth) - expected_r, 0.0, 1.0);
		depth_diff += clamp((dl - depth) - expected_l, 0.0, 1.0);
		depth_diff  = smoothstep(0.1, 0.2, depth_diff);
	}

	// Preserve the original color blending: tint toward shadow_color by strength.
	// The outline inherits the object's screen color, giving the nuanced tinted look.
	vec3 original_color     = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	vec3 final_shadow_color = mix(original_color, shadow_color, shadow_strength);
	vec3 final              = original_color;

	if (shadows_enabled) {
		final = mix(final, final_shadow_color, depth_diff);
	}

	ALBEDO = final;

	// Only edge pixels are visible; interiors are transparent (no overdraw).
	float alpha_mask = depth_diff * float(shadows_enabled);
	ALPHA = clamp(alpha_mask * 5.0, 0.0, 1.0);
}
