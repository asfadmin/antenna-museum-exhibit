shader_type spatial;


uniform sampler2D noise;
uniform vec4 base_color: source_color;
uniform vec4 secondary_color: source_color;
uniform float height_factor = 100.0;
void vertex() {
	// Called for every vertex the material is visible on.
	float offset = texture(noise, UV).r * 100.0;
	VERTEX.y += offset * height_factor;
	//VERTEX.y += cos(VERTEX.x) * sin(VERTEX.z) * 100.0;
}

void fragment() {
	vec4 base = base_color;
	ALBEDO =mix(base_color.rgb, secondary_color.rgb, texture(noise, UV.xy).r * texture(noise, UV.xy).r).rgb;
	//ALBEDO = base_color.rgb; //* texture(noise, UV).g; // + (base_color.rgb * texture(noise, UV).g);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
