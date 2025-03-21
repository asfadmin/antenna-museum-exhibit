shader_type canvas_item;

uniform sampler2D path_viewport;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = vec4(UV.x, UV.y, 0.5, 1.0);
	//COLOR =  vec4(0.5, 0.1, 1.0, 1.0); //texture(path_viewport, UV);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
