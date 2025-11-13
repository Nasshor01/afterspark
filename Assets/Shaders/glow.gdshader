shader_type canvas_item;

// ⚡ AFTERSPARK - Glow Shader
// Pro particle efekty a světelné objekty

uniform float glow_intensity : hint_range(0.0, 3.0) = 1.5;
uniform vec4 glow_color : source_color = vec4(0.2, 0.8, 1.0, 1.0);
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	// Základní textura
	vec4 tex = texture(TEXTURE, UV);
	
	// Pulzování
	float pulse = sin(TIME * pulse_speed) * 0.3 + 0.7;
	
	// Glow efekt
	vec4 glow = glow_color * tex.a * glow_intensity * pulse;
	
	// Kombinace
	COLOR = tex + glow;
	COLOR.a = tex.a;
}