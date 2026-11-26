shader_type spatial;
render_mode unshaded, fog_disabled, depth_test_disabled, cull_disabled;

uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;

uniform vec4 line_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float sensitivity : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform float thickness : hint_range(1.0, 4.0, 1.0) = 1.0;

/** Set this to your background/sky color so the far field blends seamlessly. */
uniform vec4 fog_color : source_color = vec4(0.05, 0.07, 0.07, 1.0);
uniform float fog_start : hint_range(0.0, 10000.0, 1.0) = 20.0;
uniform float fog_end : hint_range(0.0, 10000.0, 10.0) = 60.0;
/** Number of fog levels. Dither smooths the steps between them. */
uniform float fog_steps : hint_range(1.0, 16.0, 1.0) = 6.0;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float inv_z(vec2 uv, mat4 inv_proj) {
	float dep = texture(depth_tex, uv).r;
	vec4 v = inv_proj * vec4(vec3(uv, dep) * 2.0 - 1.0, 1.0);
	return -v.w / v.z;
}

float bayer4(vec2 p) {
	const float m[16] = float[16](
		0.0, 8.0, 2.0, 10.0,
		12.0, 4.0, 14.0, 6.0,
		3.0, 11.0, 1.0, 9.0,
		15.0, 7.0, 13.0, 5.0);
	ivec2 i = ivec2(mod(p, 4.0));
	return (m[i.y * 4 + i.x] + 0.5) / 16.0;
}

void fragment() {
	float threshold = sensitivity * 0.01;
	vec2 px = thickness / VIEWPORT_SIZE;
	mat4 ip = INV_PROJECTION_MATRIX;

	float c  = inv_z(SCREEN_UV, ip);
	float l  = inv_z(SCREEN_UV - vec2(px.x, 0.0), ip);
	float r  = inv_z(SCREEN_UV + vec2(px.x, 0.0), ip);
	float up = inv_z(SCREEN_UV - vec2(0.0, px.y), ip);
	float dn = inv_z(SCREEN_UV + vec2(0.0, px.y), ip);

	float lap = max(abs(l + r - 2.0 * c), abs(up + dn - 2.0 * c));
	float edge = step(threshold * c * thickness, lap);

	// Fog: smooth 0..1 by distance, snapped to N levels with Bayer dither between them
	float dist = 1.0 / max(c, 0.000001);
	float f = smoothstep(fog_start, fog_end, dist);
	float scaled = f * fog_steps;
	float lo = floor(scaled);
	float fq = (lo + step(bayer4(FRAGCOORD.xy), scaled - lo)) / fog_steps;

	edge *= 1.0 - fq; // outlines dissolve into the fog

	vec3 scene = texture(screen_tex, SCREEN_UV).rgb;
	vec3 col = mix(scene, fog_color.rgb, fq);
	col = mix(col, line_color.rgb, edge * line_color.a);

	ALBEDO = col;
	ALPHA = 1.0;
}