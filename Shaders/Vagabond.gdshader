shader_type spatial;
// Note: We do NOT use 'unshaded' here, because we NEED Godot to pass light data to us.

uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform vec4 rim_color : source_color = vec4(1.0, 0.4, 0.0, 1.0); // e.g., Orange highlight
uniform float rim_size : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	// 1. Render the base texture perfectly flat (pixel-art friendly)
	vec4 tex = texture(albedo_texture, UV);
	ALBEDO = tex.rgb;
}

void light() {
	// 2. Calculate a sharp Toon light threshold (0.0 or 1.0, no smooth gradient)
	float dot_product = dot(NORMAL, LIGHT);
	float toon_light = smoothstep(0.0, 0.05, dot_product);
	
	// 3. Dynamic Rim Light calculation (Fresnel)
	float fresnel = 1.0 - dot(NORMAL, VIEW);
	// Only show the rim light on the side of the mesh facing the light source
	float rim_mask = smoothstep(1.0 - rim_size, 1.0, fresnel) * max(0.0, dot_product);
	
	// 4. Inject the color of your actual Godot scene lights into the mesh
	vec3 dynamic_diffuse = LIGHT_COLOR * toon_light * ATTENUATION;
	vec3 dynamic_rim = rim_color.rgb * LIGHT_COLOR * rim_mask * ATTENUATION;
	
	// 5. Output to Godot's lighting engine
	DIFFUSE_LIGHT += ALBEDO * dynamic_diffuse + dynamic_rim;
}
