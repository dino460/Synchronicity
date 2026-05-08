shader_type spatial;
render_mode unshaded;

uniform sampler2D depth_tex : hint_depth_texture;

void fragment() {
    float depth = texture(depth_tex, SCREEN_UV).r;
    // Output depth to the red channel (or pack into RGB for higher precision)
    ALBEDO = vec3(depth, 0.0, 0.0);
}
