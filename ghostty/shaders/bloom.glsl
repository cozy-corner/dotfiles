// Subtle bloom — makes bright glyphs glow softly. Kept gentle so it reads as
// warmth on Kanagawa Wave, not neon.
// Shadertoy-style shader for Ghostty: iChannel0 = terminal, iResolution.

// Luminance above this starts to glow (0..1). Higher = only the brightest text.
const float BLOOM_THRESHOLD = 0.60;

// How strongly the glow is added back on top of the image.
const float BLOOM_INTENSITY = 0.20;

// Blur spread in pixels. Larger = softer, wider halo.
const float BLOOM_RADIUS = 2.0;

vec3 brightPass(vec2 uv) {
    vec3 c = texture(iChannel0, uv).rgb;
    float l = dot(c, vec3(0.299, 0.587, 0.114));
    return c * smoothstep(BLOOM_THRESHOLD, 1.0, l);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec3 base = texture(iChannel0, uv).rgb;

    // 5x5 Gaussian blur of the bright pass, single pass.
    vec2 px = BLOOM_RADIUS / iResolution.xy;
    vec3 bloom = vec3(0.0);
    float total = 0.0;
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            float w = exp(-float(x * x + y * y) * 0.5);
            bloom += brightPass(uv + vec2(float(x), float(y)) * px) * w;
            total += w;
        }
    }
    bloom /= total;

    fragColor = vec4(base + bloom * BLOOM_INTENSITY, 1.0);
}
