shader_type canvas_item;

// used for static colors
uniform float color_r : hint_range(0.0, 1.0, 0.1);
uniform float color_g : hint_range(0.0, 1.0, 0.1);
uniform float color_b : hint_range(0.0, 1.0, 0.1);

// loads textures

uniform sampler2D BookTexture;
uniform sampler2D DirtTexture;
uniform sampler2D BlendTexture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() { // Called for every pixel the material is visible on.

	//blending dirt with book texture based on blend texture
	vec4 colorBook = texture(BookTexture, UV);
	vec4 colorDirt = texture(DirtTexture,UV);
	vec4 alphaBlend = texture(BlendTexture, UV);
	COLOR = mix(colorDirt,colorBook, alphaBlend);


	//horizontal blending, no blendtexture
	//vec4 colorBook = texture(BookTexture, UV);
	//vec4 colorDirt = texture(DirtTexture,UV);
	//COLOR = mix(colorBook,colorDirt, UV.x);
	
	
	//gradient shader
	//COLOR = vec4(UV.x, UV.y, 0.0, 1.0);
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
