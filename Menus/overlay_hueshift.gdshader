shader_type canvas_item;

// Overlay tint
uniform vec4 OverlayColor : source_color = vec4(1.0, 0.7, 0.3, 1.0);
uniform float Overlay : hint_range(0.0, 1.0) = 0.5;
uniform float HueShift = 0.0; // radians

// overlay blend
vec3 overlay_mode(vec3 base, vec3 blend) {
    return mix(
        2.0 * base * blend,
        1.0 - 2.0 * (1.0 - base) * (1.0 - blend),
        step(0.5, base)
    );
}

// hue shift via YIQ
vec3 hue_shift(vec3 color, float shift) {
    // matrices written as 3 vec3 (columns)
    mat3 toYIQ = mat3(
        vec3(0.299,      0.595716,  0.211456),
        vec3(0.587,     -0.274453, -0.522591),
        vec3(0.114,     -0.321263,  0.311135)
    );

    mat3 toRGB = mat3(
        vec3(1.0,  1.0,  1.0),
        vec3(0.9563, -0.2721, -1.1070),
        vec3(0.6210, -0.6474,  1.7046)
    );

    vec3 yiq = toYIQ * color;
    float h = atan(yiq.z, yiq.y) + shift;
    float chroma = length(yiq.yz);
    yiq.y = chroma * cos(h);
    yiq.z = chroma * sin(h);
    return clamp(toRGB * yiq, 0.0, 1.0);
}

void fragment() {
    vec4 src = texture(TEXTURE, UV);

    // 1. overlay
    vec3 over = overlay_mode(src.rgb, OverlayColor.rgb);
    vec3 mixed = mix(src.rgb, over, Overlay);

    // 2. hue shift
    vec3 shifted = hue_shift(mixed, HueShift);

    COLOR = vec4(shifted, src.a);
}