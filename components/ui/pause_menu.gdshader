shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;

void fragment() {
	COLOR = textureLod(screen_texture, SCREEN_UV, blur_amount);
	COLOR.rgb *= 0.75; // Oscurece levemente para dar contraste a los botones
}