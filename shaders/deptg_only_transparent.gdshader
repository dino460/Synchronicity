shader_type spatial;
// render_mode depth_draw_always ensures it blocks the column
// render_mode color_mask_none ensures the ground itself is invisible
render_mode depth_draw_always, unshaded;

void fragment() {
	ALBEDO = vec3(2.0f);
    //ALPHA = 0.0;
}