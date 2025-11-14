shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.05;
uniform float outline_width : hint_range(0.0, 10.0) = 1.0;

// Funkce pro generování náhodných hodnot
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 size = textureSize(TEXTURE, 0);
    float outline = outline_width / size.x;

    // Vzorkování okolních pixelů pro detekci obrysu
    float alpha = texture(TEXTURE, UV).a;
    float up = texture(TEXTURE, UV + vec2(0.0, outline)).a;
    float down = texture(TEXTURE, UV - vec2(0.0, outline)).a;
    float left = texture(TEXTURE, UV - vec2(outline, 0.0)).a;
    float right = texture(TEXTURE, UV + vec2(outline, 0.0)).a;

    // Glitch efekt
    float glitch = (random(vec2(TIME, UV.y)) - 0.5) * glitch_intensity;
    vec2 glitch_uv = UV + vec2(glitch, 0.0);

    float glitch_alpha = texture(TEXTURE, glitch_uv).a;

    // Výsledná barva
    vec4 color = vec4(0.0);

    if (glitch_alpha > 0.1) {
        // Silueta
        color = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // Obrys (pokud je pixel průhledný, ale okolní ne)
        if (alpha < 0.1 && (up > 0.1 || down > 0.1 || left > 0.1 || right > 0.1)) {
            color = outline_color;
        } else {
            // Průhledné pozadí
            color = vec4(0.0);
        }
    }

    COLOR = color;
}
