shader_type spatial;
render_mode diffuse_toon;

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : source_color, filter_nearest, repeat_enable;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.001) = 0.05;

/** Copy these from the extracted material's Uv1 section. */
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);

/** Base brightness when no lights are in the scene (0.0 to 1.0). */
uniform float ambient_strength : hint_range(0.0, 1.0) = 0.65;
/** Color tint for unlit/ambient areas. */
uniform vec4 shadow_color : source_color = vec4(0.6, 0.6, 0.65, 1.0);

/** Defaults to White Rim Light. Should take in the color of the "sun" primarily. */
uniform vec4 rim_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
/** Size of the Rim Band */
uniform float rim_size : hint_range(0.0, 1.0) = 0.05;

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	vec3 base_color = albedo.rgb * albedo_tex.rgb;

	ALBEDO = base_color;
	// Guarantees the texture is always visible even with 0 lights and no WorldEnvironment
	EMISSION = base_color * shadow_color.rgb * ambient_strength;

	ALPHA *= albedo.a * albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
}

void light() {
	// 1. Sharp Toon light threshold
	float dot_product = dot(NORMAL, LIGHT);
	float toon_light = smoothstep(0.0, 0.05, dot_product) * ATTENUATION;

	// 2. Dynamic Rim Light calculation (Fresnel)
	float fresnel = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float rim_mask = smoothstep(1.0 - rim_size, 1.0, fresnel) * max(0.0, dot_product);

	// 3. Add directional light and rim light on top of the base emission
	vec3 dynamic_diffuse = (LIGHT_COLOR / PI) * toon_light * (1.0 - ambient_strength);
	vec3 dynamic_rim = rim_color.rgb * (LIGHT_COLOR / PI) * rim_mask * ATTENUATION;

	DIFFUSE_LIGHT += ALBEDO * dynamic_diffuse + dynamic_rim;
}