shader_type spatial;
render_mode cull_front, unshaded, depth_draw_opaque;

uniform float outline_size : hint_range(0.0, 100.0, 0.1) = 2.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void vertex() {
    vec4 clip_pos = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
    vec4 clip_normal = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(NORMAL, 0.0);
    vec2 offset = normalize(clip_normal.xy) * outline_size * clip_pos.w * 0.001;
    clip_pos.xy += offset;
    POSITION = clip_pos;
}

void fragment() {
    ALBEDO = outline_color.rgb;
}