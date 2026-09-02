shader_type canvas_item;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    COLOR = vec4(1.0, 0.0, 0.0, smoothstep(0.2, 0.8, dist) * COLOR.a);
}