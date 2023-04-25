shader_type canvas_item;

uniform sampler2D curve;
uniform float strength: hint_range(-1, 1) = 0.5;
uniform int pixel_amount = 64
;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 vec_to_center = vec2(0.5, 0.5) - UV;
	float dist_to_center = length(vec_to_center);
	float curve_value = texture(curve, vec2(dist_to_center)).r;
	vec2 diff = normalize(vec_to_center) * strength * curve_value;
	
	vec2 grid_uv = round(UV * float(pixel_amount)) / float(pixel_amount);
	vec4 textr = texture(SCREEN_TEXTURE, grid_uv);

	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - (diff * grid_uv));
}
