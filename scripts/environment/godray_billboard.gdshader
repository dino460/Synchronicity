shader_type spatial;

render_mode
    cull_disabled,
    depth_draw_never,
    depth_test_disabled,
    specular_disabled,
    ambient_light_disabled,
    blend_mix,
    skip_vertex_transform;

uniform vec3  light_direction   = vec3(0.0, -1.0, 0.0);
uniform float quad_size         : hint_range(1.0, 200.0, 0.5)   = 40.0;
uniform float ray_alpha         : hint_range(0.0, 1.0,   0.001) = 0.04;
uniform vec3  ray_color         : source_color                   = vec3(1.0, 0.95, 0.8);
uniform float depth_fade_near   : hint_range(0.0, 50.0,  0.1)   = 2.0;
uniform float depth_fade_far    : hint_range(0.0, 500.0, 1.0)   = 100.0;
uniform float edge_fade_margin  : hint_range(0.0, 0.5,   0.01)  = 0.15;
uniform float ground_fade_y     : hint_range(-10.0, 10.0, 0.1)  = 1.0;
uniform float ground_fade_range : hint_range(0.0, 20.0,  0.1)   = 3.0;

// Sun elevation at which godrays start fading out (0 = horizon, 1 = overhead).
uniform float sun_fade_start    : hint_range(0.0, 1.0,   0.01)  = 0.3;
// Sun elevation at which godrays are fully gone.
uniform float sun_fade_end      : hint_range(0.0, 1.0,   0.01)  = 0.7;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

varying float v_view_depth;
varying vec2  v_quad_uv;
varying float v_world_y;
varying float alignment;

void vertex() {
    // Full billboard: use camera right and up axes directly.
    // The quad always faces the camera regardless of light direction.
    vec3 cam_right = INV_VIEW_MATRIX[0].xyz;
    vec3 cam_up    = INV_VIEW_MATRIX[1].xyz;

    vec3 instance_pos = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;

    vec3 world_pos = instance_pos
                   + cam_right * VERTEX.x * quad_size
                   + cam_up    * VERTEX.y * quad_size;

    v_quad_uv  = VERTEX.xy + 0.5;
    v_world_y  = world_pos.y;

    vec4 view_pos = VIEW_MATRIX * vec4(world_pos, 1.0);
    v_view_depth  = -view_pos.z;
	alignment = abs(dot(normalize(light_direction), normalize(-INV_VIEW_MATRIX[2].xyz)));
	
    VERTEX   = view_pos.xyz;
    POSITION = PROJECTION_MATRIX * view_pos;
}

void fragment() {
    float raw_depth   = texture(DEPTH_TEXTURE, SCREEN_UV).r;
    vec4  scene_view  = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, raw_depth, 1.0);
    scene_view       /= scene_view.w;
    float scene_depth = -scene_view.z;

    float near_fade  = smoothstep(depth_fade_near, depth_fade_near + 3.0, v_view_depth);
    float soft_isect = smoothstep(0.0, 3.0, scene_depth - v_view_depth);
    float dist_fade  = 1.0 - smoothstep(depth_fade_far * 0.5, depth_fade_far, v_view_depth);

    float fade_left   = smoothstep(0.0, edge_fade_margin, v_quad_uv.x);
    float fade_right  = smoothstep(0.0, edge_fade_margin, 1.0 - v_quad_uv.x);
    float fade_bottom = smoothstep(0.0, edge_fade_margin, v_quad_uv.y);
    float fade_top    = smoothstep(0.0, edge_fade_margin, 1.0 - v_quad_uv.y);
    float edge_fade   = fade_left * fade_right * fade_bottom * fade_top;

    float ground_fade = smoothstep(ground_fade_y, ground_fade_y + ground_fade_range, v_world_y);

    // Sun elevation: abs(light_ws.y) is 0 at horizon, 1 directly overhead.
    // Godrays fade out as the sun rises above sun_fade_start.
    float sun_elevation = abs(normalize(light_direction).y);
    float sun_fade      = 1.0 - smoothstep(sun_fade_start, sun_fade_end, sun_elevation);

    ALBEDO = ray_color;
    ALPHA  = 0.9 * alignment * ray_alpha * near_fade * soft_isect * dist_fade * edge_fade * ground_fade * sun_fade;
}

//void light() {
    //if (LIGHT_IS_DIRECTIONAL) {
        //ALPHA         *= ATTENUATION;
        //DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION;
    //}
//}