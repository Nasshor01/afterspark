shader_type canvas_item;

// ⚡ AFTERSPARK - Floor Grid Shader
// Reaguje na světlo a vytváří cyberpunk mřížku

uniform vec4 grid_color : source_color = vec4(0.2, 0.4, 0.6, 0.3);
uniform vec4 background_color : source_color = vec4(0.05, 0.05, 0.1, 1.0);
uniform float grid_size : hint_range(10.0, 200.0) = 50.0;
uniform float line_width : hint_range(0.5, 5.0) = 1.5;
uniform float light_response : hint_range(0.0, 2.0) = 0.8;

void fragment() {
	// World position
	vec2 world_pos = FRAGCOORD.xy;
	
	// Grid lines
	vec2 grid = abs(fract(world_pos / grid_size - 0.5) - 0.5) / fwidth(world_pos / grid_size);
	float line = min(grid.x, grid.y);
	float grid_strength = 1.0 - min(line, 1.0);
	
	// Fade grid based on distance from center
	float dist = length(UV - vec2(0.5)) * 2.0;
	float fade = 1.0 - smoothstep(0.3, 1.0, dist);
	
	// Base color
	vec4 base = background_color;
	
	// Add grid
	vec4 grid_col = mix(base, grid_color, grid_strength * fade);
	
	// Scan lines effect (optional)
	float scan = sin(world_pos.y * 0.5 + TIME * 2.0) * 0.05 + 0.95;
	
	COLOR = grid_col * scan;
}