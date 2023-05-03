// Thanks so much https://www.youtube.com/watch?v=32jdNLTJ3zY, I even kinda understood
shader_type canvas_item;

uniform vec2 scale;
uniform float y_zoom;
uniform vec4 reflection_color: source_color;
uniform sampler2D noise: repeat_enable;
uniform vec2 distorsion_scale;
uniform float intensity;
uniform float speed;

uniform float wave_amplitude;
uniform float wave_speed;
uniform float wave_frequency;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	float waves = UV.y * scale.y + sin(UV.x*scale.x/wave_frequency - TIME*wave_speed) * cos(0.2*UV.x*scale.x/wave_frequency + TIME*wave_speed) * wave_amplitude - wave_amplitude;
	
	float distorsion = texture(noise, UV * scale * distorsion_scale + TIME * speed).x;
	distorsion -= 0.5;
	
	float uv_height = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 reflected_screenuv = vec2(SCREEN_UV.x - distorsion * intensity * y_zoom, SCREEN_UV.y - uv_height * UV.y * scale.y * y_zoom * 2.0);
	
	vec4 reflection = texture(SCREEN_TEXTURE, reflected_screenuv);
	
	COLOR.rgb = mix(reflection.rgb, reflection_color.rgb, reflection_color.a);
	
	//wave mask:
	//COLOR.rgb = vec3(smoothstep(0.0, 0.13, waves));
	
	COLOR.a = smoothstep(0.0, 0.13, waves) * 0.75;
}
