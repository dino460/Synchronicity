shader_type spatial;

render_mode
	cull_disabled,
	depth_draw_never,
	depth_test_disabled,
	specular_disabled,
	ambient_light_disabled,
	blend_add,
	skip_vertex_transform;

// ---------------------------------------------------------------------------
// STEP 2 groundwork: light direction defines the orientation of every slice.
// ---------------------------------------------------------------------------
uniform vec3  light_direction   = vec3(0.0, -1.0, 0.0);

// ---------------------------------------------------------------------------
// STEP 1/2: how many slices exist, and how far apart they are.
// With num_slices = 1, this behaves exactly like the "step 1" single-plane
// test: one quad, guaranteed to fill the screen, so you can validate the
// unprojection + intersection math in isolation before scaling up.
// Raise num_slices (and set your MultiMesh instance_count to match) to move
// into step 2 - no other code changes needed.
// ---------------------------------------------------------------------------
uniform int   num_slices        = 1;
uniform float slice_spacing     : hint_range(0.1, 20.0, 0.1) = 2.0;

// World-space point the whole stack of slices is centered on (feed this from
// GDScript each frame - e.g. the player's or camera's position). Using an
// explicit uniform instead of a camera built-in keeps this flexible: you can
// anchor to the player, smooth it, or snap it to a grid to reduce shimmer.
uniform vec3  godray_anchor     = vec3(0.0, 0.0, 0.0);

// ---------------------------------------------------------------------------
// STEP 4 groundwork: anti-banding jitter. Leave jitter_strength at 0.0 while
// you validate steps 1-2; you want a clean, predictable result first. Once
// slices are working and you can *see* banding between them, dial this up.
// ---------------------------------------------------------------------------
uniform float jitter_strength   : hint_range(0.0, 1.0, 0.01) = 0.0;

// ---------------------------------------------------------------------------
// Every slice is a copy of the same plane. As the camera's view direction
// gets close to lying *inside* that plane (viewing the stack edge-on),
// each slice's screen footprint collapses toward a thin sliver and you see
// banding - a fundamental blind spot of a single-orientation stack, not a
// bug. stack_fade_start/end fade the whole effect out before you reach it,
// same idea denovodavid describes fading instances as the camera rotates.
// Tune by rotating your camera to the worst angle and adjusting until the
// banding disappears before it would otherwise show.
// ---------------------------------------------------------------------------
uniform float stack_fade_start : hint_range(0.0, 1.0, 0.01) = 0.15;
uniform float stack_fade_end   : hint_range(0.0, 1.0, 0.01) = 0.35;

uniform float ray_alpha         : hint_range(0.0, 1.0,   0.001) = 0.04;
uniform vec3  ray_color         : source_color                  = vec3(1.0, 0.95, 0.8);
uniform float depth_fade_near   : hint_range(0.0, 50.0,  0.1)   = 2.0;
uniform float depth_fade_far    : hint_range(0.0, 500.0, 1.0)   = 100.0;
uniform float ground_fade_y     : hint_range(-10.0, 10.0, 0.1)  = 1.0;
uniform float ground_fade_range : hint_range(0.0, 20.0,  0.1)   = 3.0;

uniform float sun_fade_start    : hint_range(0.0, 1.0,   0.01)  = 0.3;
uniform float sun_fade_end      : hint_range(0.0, 1.0,   0.01)  = 0.7;
uniform float sun_fade_strength : hint_range(0.0, 1.0, 0.01) = 0.9;

uniform float alignment_fade_strength : hint_range(0.0, 1.0, 0.01) = 0.9;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

group_uniforms clouds;
global uniform float cloud_cover_scale;
global uniform float cloud_cover_intensity;
global uniform vec2 cloud_scroll_speed;
global uniform sampler2D cloud_noise_texture;
global uniform float cloud_cover_threshold;

varying float v_view_depth;
varying vec2  v_quad_uv;
varying float v_world_y;
varying float alignment;
varying vec3  v_world_pos; // STEP 2 fix: per-fragment world pos, not a single instance-center point
varying float v_stack_alignment; // how edge-on the camera is to the slice stack right now

// Cheap pseudo-random float from an integer seed. Used only for jitter (step 4).
float hash11(float p) {
	p = fract(p * 0.1031);
	p *= p + 33.33;
	p *= p + p;
	return fract(p);
}

void vertex() {
	vec3 light_ws = normalize(light_direction);
	vec3 world_up = vec3(0.0, 1.0, 0.0);

	// --- Slice orientation (same idea as your original code) -------------
	// plane_right: the horizontal axis perpendicular to the sun's azimuth.
	// This is one of the two directions that lie *inside* every slice plane.
	vec3 cross_lu    = cross(light_ws, world_up);
	vec3 plane_right = length(cross_lu) > 0.001 ? normalize(cross_lu) : vec3(1.0, 0.0, 0.0);

	// plane_normal: perpendicular to the plane itself. This is the axis we
	// space multiple slices along - each slice is a copy of the same plane,
	// shifted along this one direction.
	vec3 plane_normal = normalize(cross(plane_right, light_ws));

	// Which slice is this instance? Center the range around 0 so slices sit
	// evenly on both sides of the anchor.
	float slice_index = float(INSTANCE_ID) - (float(num_slices) - 1.0) * 0.5;

	// A plane's position is fully described by ONE number: how far along
	// plane_normal it sits (dot(point, plane_normal)). godray_anchor's other
	// components don't affect which plane this is at all - an infinite
	// plane doesn't care where within itself a point sits.
	//
	// Snapping that one number to the nearest multiple of slice_spacing
	// doesn't move the plane grid - it's infinite and repeats every
	// slice_spacing units, so a snapped anchor always lands exactly on a
	// position some other instance already occupies. What it DOES do is
	// stop the whole stack from sliding continuously with the anchor: now
	// it only steps by a full slice_spacing at a time, and each step is
	// invisible because the new position was already part of the same
	// repeating pattern.
	float anchor_grid = round(dot(godray_anchor, plane_normal) / slice_spacing);
	float grid_index  = anchor_grid + slice_index; // stable world-space slot for this instance right now

	// STEP 4: jitter, keyed to the world-space grid slot rather than
	// INSTANCE_ID. That matters here: when the stack steps and a different
	// INSTANCE_ID starts representing a given physical slot, keying jitter
	// to INSTANCE_ID would make that slot's jitter suddenly change - a
	// visible pop right at the step. Keying to grid_index keeps a given
	// physical location's jitter stable regardless of which instance is
	// currently drawing it.
	float jitter = (hash11(grid_index + 17.0) - 0.5) * jitter_strength;

	vec3 plane_point = plane_normal * (grid_index + jitter) * slice_spacing;

	// --- Build this vertex's view ray -------------------------------------
	// VERTEX.xy on a standard 1x1 QuadMesh is in [-0.5, 0.5]. Multiply by 2
	// to get NDC (Normalized Device Coordinates), which run [-1, 1] and
	// represent "which point on the screen is this."
	vec2 ndc = VERTEX.xy * 2.0;

	// Unproject that screen point back into a 3D point using the camera's
	// inverse projection matrix - the same trick your fragment shader
	// already uses on DEPTH_TEXTURE. The z value here (0.0) is arbitrary:
	// for an orthographic camera every point on this ray has the *same*
	// view-space x/y regardless of depth, so any z gives a valid point on
	// the correct ray. (This stops being true for a perspective camera -
	// see the note below the shader.)
	vec4 near_view = INV_PROJECTION_MATRIX * vec4(ndc, 0.0, 1.0);
	near_view /= near_view.w;

	// Move that point from view space (camera-relative) into world space.
	vec3 ray_origin_ws = (INV_VIEW_MATRIX * vec4(near_view.xyz, 1.0)).xyz;

	// Orthographic camera: every ray points the same direction - straight
	// out along the camera's forward axis. INV_VIEW_MATRIX[2].xyz is the
	// camera's local Z axis expressed in world space; the camera looks down
	// its *negative* Z, hence the minus sign (you already used this exact
	// expression for `alignment` below).
	vec3 ray_dir_ws = normalize(-INV_VIEW_MATRIX[2].xyz);

	// --- Ray/plane intersection -------------------------------------------
	float denom = dot(ray_dir_ws, plane_normal);
	v_stack_alignment = abs(denom); // 0 = viewing the stack edge-on, 1 = viewing it face-on
	float t = (abs(denom) > 0.0001)
		? dot(plane_point - ray_origin_ws, plane_normal) / denom
		: 1000.0; // camera looking edge-on along the slice plane: push far away rather than divide by ~0

	vec3 world_pos = ray_origin_ws + ray_dir_ws * t;

	v_quad_uv   = VERTEX.xy + 0.5;
	v_world_y   = world_pos.y;
	v_world_pos = world_pos;

	vec4 view_pos = VIEW_MATRIX * vec4(world_pos, 1.0);
	v_view_depth  = -view_pos.z;

	alignment = abs(dot(light_ws, normalize(-INV_VIEW_MATRIX[2].xyz)));

	VERTEX   = view_pos.xyz;
	POSITION = PROJECTION_MATRIX * view_pos;
}

void fragment() {
	// --- Unchanged from your original shader ------------------------------
	float raw_depth   = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	vec4  scene_view  = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, raw_depth, 1.0);
	scene_view       /= scene_view.w;
	float scene_depth = -scene_view.z;

	float near_fade  = smoothstep(depth_fade_near, depth_fade_near + 3.0, v_view_depth);
	float soft_isect = smoothstep(0.0, 3.0, scene_depth - v_view_depth);
	float dist_fade  = 1.0 - smoothstep(depth_fade_far * 0.5, depth_fade_far, v_view_depth);

	// STEP 1 note: edge_fade is deliberately removed. Once the quad always
	// spans the full screen by construction, there's no seam left to hide.
	float ground_fade = smoothstep(ground_fade_y, ground_fade_y + ground_fade_range, v_world_y);

	float sun_elevation = abs(normalize(light_direction).y);
	float sun_fade = abs(sun_fade_strength - smoothstep(sun_fade_start, sun_fade_end, sun_elevation));

	float stack_fade = smoothstep(stack_fade_start, stack_fade_end, v_stack_alignment);

	ALBEDO = ray_color;
	ALPHA  = ray_alpha * near_fade * soft_isect * dist_fade * ground_fade * sun_fade * stack_fade / float(num_slices);
}

void light() {
	float attenuation = 1.0;

	vec3 LIGHT_world_space = (INV_VIEW_MATRIX * vec4(LIGHT, 0.0)).xyz;

	// STEP 2 fix: sample clouds using the actual per-fragment world position
	// (v_world_pos) instead of a single per-instance center point, since a
	// slice quad now spans a large, non-uniform area of world space.
	vec2 cloud_uv = (v_world_pos.xz + (cloud_scroll_speed * TIME)) * cloud_cover_scale;
	cloud_uv = vec2(cloud_uv.x, cloud_uv.y * LIGHT_world_space.y);

	float cloud_cover = texture(cloud_noise_texture, cloud_uv).r;
	cloud_cover = (cloud_cover >= cloud_cover_threshold) ? 0.0 : 1.0;

	if (LIGHT_IS_DIRECTIONAL) {
		attenuation = min(ATTENUATION, cloud_cover);
		ALPHA         *= attenuation;
		DIFFUSE_LIGHT += LIGHT_COLOR * attenuation;
	}
}
