// object_edge_internal.gdshader
// Per-object internal edge detection using screen-space normals + depth sampling,
// but executed as a next_pass on individual objects — so it never fires on meshes
// that don't carry this material (e.g. grass).
//
// Replaces: edge_detection.gdshader (screen-space quad post-process)
//
// Preserves:
//   - Soft normal-based internal edges (NormalEdgeIndicator)
//   - Depth-based edge contribution
//   - Lighting reaction via light() — highlights and shadows driven by scene lights
//   - outlineMask via NORMAL_TEXTURE alpha (roughness=0 objects are excluded)
//   - lineHighlight / lineShadow non-lighting path
//
// Setup:
//   - Add this as next_pass on your object's ShaderMaterial (after object_outline_outer
//     if you want both, or alone).
//   - This pass reads screen textures, so it correctly sees the already-rendered scene.
//   - Set render_mode blend_add or blend_mix depending on preference (blend_mix default).

shader_type spatial;

// specular/ambient disabled matches original; we handle lighting manually in light().
// depth_draw_opaque so this pass writes depth (needed for correct next-pass ordering).
// No culling change — we render front faces of the object's geometry as the "canvas"
// for the edge overlay.
render_mode specular_disabled, ambient_light_disabled, depth_draw_never, blend_mix;

// ----- Textures (same hints as original) ---------------------------------------

uniform sampler2D DEPTH_TEXTURE   : hint_depth_texture,          filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE  : hint_screen_texture,          filter_nearest;
uniform sampler2D NORMAL_TEXTURE  : hint_normal_roughness_texture, filter_nearest;

// ----- Uniforms (matching original edge_detection) -----------------------------

uniform float lightIntensity  = 1.25;
uniform float lineAlpha       = 0.7;
uniform bool  useLighting     = true;
uniform float lineHighlight   = 0.2;
uniform float lineShadow      = 0.55;

// Extra per-object control: scale the normal-difference sensitivity.
// 1.0 = identical to original. Raise to detect subtler surface creases.
uniform float normalSensitivity : hint_range(0.1, 4.0, 0.05) = 1.0;

// ----- Varyings ----------------------------------------------------------------

varying vec2  v_screenUV;
varying float v_lineMask;

// ----- Helpers (identical to original) ----------------------------------------

float GetLinearDepth(vec2 sUV, mat4 invProj, float mask) {
	float depth  = texture(DEPTH_TEXTURE, sUV).x * mask;
	vec3  ndc    = vec3(sUV * 2.0 - 1.0, depth);
	vec4  view   = invProj * vec4(ndc, 1.0);
	view.xyz    /= view.w;
	return -view.z;
}

vec3 GetNormal(vec2 uv, float mask) {
	vec3 n = texture(NORMAL_TEXTURE, uv).rgb;
	n = n * 2.0 - 1.0 * mask;
	return n;
}

float NormalEdgeIndicator(vec3 bias, vec3 normal, vec3 neighbor, float depthDiff) {
	// Kody King / three.js pixel example — unchanged from original.
	float nd  = dot(normal - neighbor, bias);
	float ni  = clamp(smoothstep(-.01, .01, nd), 0.0, 1.0);
	float di  = clamp(sign(depthDiff * .25 + .0025), 0.0, 1.0);
	return (1.0 - dot(normal, neighbor)) * di * ni;
}

// ----- Vertex ------------------------------------------------------------------

void vertex() {
	// Standard passthrough — we are a full-geometry pass, not a quad.
	// No position override; we rely on the object's own vertices.
}

// ----- Fragment ----------------------------------------------------------------

void fragment() {
	vec2 texel   = 1.0 / VIEWPORT_SIZE.xy;
	v_screenUV   = SCREEN_UV;

	// Four cardinal neighbour UVs (same as original).
	vec2 offs[4];
	offs[0] = SCREEN_UV + vec2( 0.0, -1.0) * texel;
	offs[1] = SCREEN_UV + vec2( 0.0,  1.0) * texel;
	offs[2] = SCREEN_UV + vec2( 1.0,  0.0) * texel;
	offs[3] = SCREEN_UV + vec2(-1.0,  0.0) * texel;

	// outlineMask: objects with roughness == 0 are excluded (unchanged from original).
	float outlineMask = ceil(texture(NORMAL_TEXTURE, SCREEN_UV).a);

	// ---- Depth edge -----------------------------------------------------------
	float depthDiff    = 0.0;
	float invDepthDiff = 0.5;
	float depth        = GetLinearDepth(SCREEN_UV, INV_PROJECTION_MATRIX, outlineMask);

	for (int i = 0; i < 4; i++) {
		float dOff = GetLinearDepth(offs[i], INV_PROJECTION_MATRIX, outlineMask);
		depthDiff    += clamp(dOff - depth, 0.0, 1.0);
		invDepthDiff += depth - dOff;
	}
	invDepthDiff = clamp(invDepthDiff, 0.0, 1.0);
	invDepthDiff = clamp(smoothstep(0.9, 0.9, invDepthDiff) * 10.0, 0.0, 1.0);
	depthDiff    = smoothstep(0.25, 0.3, depthDiff);

	// ---- Normal edge ----------------------------------------------------------
	float normalDiff   = 0.0;
	vec3  edgeBias     = vec3(1.0, 1.0, 1.0);
	vec3  normal       = GetNormal(SCREEN_UV, outlineMask);

	for (int i = 0; i < 4; i++) {
		vec3 nOff   = GetNormal(offs[i], outlineMask);
		normalDiff += NormalEdgeIndicator(edgeBias, normal, nOff, depthDiff);
	}
	normalDiff = smoothstep(0.2, 0.2, normalDiff * normalSensitivity);
	normalDiff = clamp(normalDiff - invDepthDiff, 0.0, 1.0);

	// ---- Compose --------------------------------------------------------------
	ALBEDO    = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	v_lineMask = clamp(0.1, lineAlpha, (depthDiff + normalDiff * 5.0));

	if (!useLighting) {
		ALBEDO += clamp((normalDiff - depthDiff), 0.0, 1.0) * lineHighlight;
		ALBEDO -= ALBEDO * depthDiff * lineShadow;
	}

	// We only want this pass to be visible where edges actually are.
	// Blend the alpha so fully flat areas are transparent (no over-draw cost).
	ALPHA = clamp((depthDiff + normalDiff * 5.0) * 2.0, 0.0, 1.0);
}

// ----- Light -------------------------------------------------------------------
// Identical logic to original edge_detection light() — lighting reacts to
// scene directional lights and brightens/darkens the edge overlay accordingly.

void light() {
	if (useLighting) {
		vec4 n = texture(NORMAL_TEXTURE, v_screenUV);
		n = n * 2.0 - 1.0;

		float dotNL = dot(n.rgb, LIGHT);
		dotNL = pow(dotNL, 2.5);
		dotNL = clamp(dotNL, 0.0, 1.0);

		if (LIGHT_IS_DIRECTIONAL)
			DIFFUSE_LIGHT += mix(vec3(1.0), dotNL * LIGHT_COLOR * lightIntensity, v_lineMask);
	} else {
		DIFFUSE_LIGHT = vec3(1.0);
	}
}
