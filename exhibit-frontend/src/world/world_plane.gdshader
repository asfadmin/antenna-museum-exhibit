shader_type spatial;


uniform sampler2D noise;
uniform vec4 base_color: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
	float offset = texture(noise, UV).r;
	VERTEX.y += offset * 10.0;
}

void fragment() {
	ALBEDO = base_color.rgb;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
