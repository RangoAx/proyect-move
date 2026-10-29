shader_type fog;

uniform float radius : hint_range(5.0, 60.0) = 17.5;
uniform float thickness : hint_range(1.0, 20.0) = 5.5;
uniform float max_density : hint_range(0.1, 15.0) = 4.5;
uniform float fade_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec3 fog_albedo : source_color = vec3(0.60, 0.64, 0.68);
uniform vec3 fog_emission : source_color = vec3(0.04, 0.05, 0.06);
uniform float swirl_speed = 0.12;
uniform float noise_scale = 0.22;

float hash3(vec3 p) {
    p = fract(p * 0.1031);
    p += dot(p, p.zyx + 31.32);
    return fract((p.x + p.y) * p.z);
}

float noise3(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(mix(hash3(i + vec3(0.0, 0.0, 0.0)), hash3(i + vec3(1.0, 0.0, 0.0)), f.x),
            mix(hash3(i + vec3(0.0, 1.0, 0.0)), hash3(i + vec3(1.0, 1.0, 0.0)), f.x), f.y),
        mix(mix(hash3(i + vec3(0.0, 0.0, 1.0)), hash3(i + vec3(1.0, 0.0, 1.0)), f.x),
            mix(hash3(i + vec3(0.0, 1.0, 1.0)), hash3(i + vec3(1.0, 1.0, 1.0)), f.x), f.y), f.z);
}

float fbm3(vec3 p) {
    float v = 0.0;
    float a = 0.55;
    for (int i = 0; i < 3; ++i) {
        v += a * noise3(p);
        p = p * 2.05 + vec3(13.7, 29.1, 47.9);
        a *= 0.5;
    }
    return v;
}

void fog() {
    float dist = length(OBJECT_POSITION.xz);
    float ring_dist = abs(dist - radius);

    if (ring_dist < thickness) {
        // Radial profile: smooth peak at the radius, falling off softly to zero at edges
        float norm_d = ring_dist / thickness;
        float profile = 1.0 - norm_d;
        profile = profile * profile * (3.0 - 2.0 * profile);

        // Vertical falloff: soft near ground and top of the volume
        float y_norm = abs(OBJECT_POSITION.y) / 7.0;
        float v_fade = clamp(1.0 - (y_norm * y_norm), 0.0, 1.0);

        // Swirling 3D procedural noise in local coordinates
        vec3 np = OBJECT_POSITION * noise_scale + vec3(TIME * swirl_speed, TIME * (swirl_speed * 0.35), -TIME * (swirl_speed * 0.65));
        float n = fbm3(np);

        float final_density = max_density * profile * v_fade * (0.45 + 0.95 * n) * fade_progress;

        DENSITY = clamp(final_density, 0.0, 12.0);
        ALBEDO = fog_albedo;
        EMISSION = fog_emission;
    } else {
        DENSITY = 0.0;
    }
}
