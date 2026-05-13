shader_type canvas_item;
// loads textures

uniform sampler2D BookTexture;
uniform sampler2D DustTexture;
uniform sampler2D StainTexture;
uniform sampler2D RubberTexture;
uniform sampler2D WaxTexture;

void fragment() { // Called for every pixel the material is visible on.

	//
	vec4 colorBook = texture(BookTexture, UV);
	vec4 colorWax = texture(WaxTexture, UV);
	vec4 colorRubber = texture(RubberTexture,UV);
	vec4 colorStain = texture(StainTexture,UV);
	vec4 colorDust = texture(DustTexture,UV);
	
	vec4 colorFinal = mix(colorBook,colorWax, 0.1);
	colorFinal = mix(colorFinal,colorRubber, colorRubber.a);
	colorFinal = mix(colorFinal,colorStain, colorStain.a);
	colorFinal = mix(colorFinal,colorDust, colorDust.a);
	COLOR = colorFinal;
	

}
