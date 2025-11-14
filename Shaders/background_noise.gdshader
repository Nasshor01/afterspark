shader_type canvas_item;
render_mode unshaded;

uniform vec4 background_color : source_color = vec4(0.05, 0.05, 0.1, 1.0);
uniform float noise_scale : hint_range(1.0, 100.0) = 25.0;
uniform float noise_speed : hint_range(0.0, 1.0) = 0.05;

// Funkce pro 2D náhodnou hodnotu
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Funkce pro generování šumu (jednoduchá verze)
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.y * u.x;
}

void fragment() {
    // Vstupní barva ze světel ve scéně
    vec4 light_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Generování šumu, který se pomalu mění v čase
    vec2 pos = FRAGCOORD.xy / (1.0 / VIEWPORT_SIZE);
    pos *= noise_scale;
    pos.x += TIME * noise_speed;

    float n = noise(pos);

    // Výsledná barva je kombinací barvy pozadí a šumu,
    // ale je viditelná pouze tam, kde je nějaké světlo.
    // Použijeme jas světla jako masku.
    float light_intensity = length(light_color.rgb);

    vec4 final_color = background_color + vec4(vec3(n * 0.05), 1.0);

    COLOR = mix(vec4(0.0), final_color, smoothstep(0.1, 0.5, light_intensity));
}
