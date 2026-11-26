shader_type spatial;
render_mode diffuse_toon;

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : source_color, filter_nearest, repeat_enable;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.001) = 0.05;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);

/** Project the texture from 3 axes instead of using the mesh UVs. */
uniform bool use_triplanar = false;
/** On: texture is anchored to the world, so it tiles seamlessly across separate terrain chunks. Off: it follows the mesh. */
uniform bool triplanar_world_space = true;
/** Higher = harder transitions between the 3 projections. */
uniform float triplanar_sharpness : hint_range(1.0, 32.0, 0.5) = 8.0;

uniform float ambient_strength : hint_range(0.0, 1.0) = 0.65;
uniform vec4 shadow_color : source_color = vec4(0.6, 0.6, 0.65, 1.0);
uniform vec4 rim_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float rim_size : hint_range(0.0, 1.0) = 0.05;

varying vec3 tri_pos;
varying vec3 tri_weights;

void vertex() {
	if (use_triplanar) {
		vec3 pos = VERTEX;
		vec3 nrm = NORMAL;
		if (triplanar_world_space) {
			pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
			nrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
		}
		tri_pos = pos * uv1_scale + uv1_offset;
		tri_pos *= vec3(1.0, -1.0, 1.0);
		tri_weights = pow(abs(nrm), vec3(triplanar_sharpness));
		tri_weights /= dot(tri_weights, vec3(1.0));
	}
}

vec4 triplanar_sample(sampler2D tex, vec3 w, vec3 p) {
	vec4 s = vec4(0.0);
	s += texture(tex, p.xy) * w.z;
	s += texture(tex, p.xz) * w.y;
	s += texture(tex, p.zy * vec2(-1.0, 1.0)) * w.x;
	return s;
}

void fragment() {
	vec4 albedo_tex;
	if (use_triplanar) {
		albedo_tex = triplanar_sample(texture_albedo, tri_weights, tri_pos);
	} else {
		albedo_tex = texture(texture_albedo, UV * uv1_scale.xy + uv1_offset.xy);
	}
	vec3 base_color = albedo.rgb * albedo_tex.rgb;

	ALBEDO = base_color;
	EMISSION = base_color * shadow_color.rgb * ambient_strength;

	ALPHA *= albedo.a * albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
}

// light() stays exactly as you have it
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