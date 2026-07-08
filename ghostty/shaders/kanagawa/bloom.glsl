// Subtle bloom — makes bright glyphs glow softly. Kept gentle so it reads as
// warmth on Kanagawa Wave, not neon.
// Shadertoy-style shader for Ghostty: iChannel0 = terminal, iResolution.

// Luminance above this starts to glow (0..1). Higher = only the brightest text.
const float BLOOM_THRESHOLD = 0.60;

// How strongly the glow is added back on top of the image.
const float BLOOM_INTENSITY = 0.20;

// Blur spread in pixels. Larger = softer, wider halo.
const float BLOOM_RADIUS = 2.0;

vec3 brightPass(vec3 c) {
    float l = dot(c, vec3(0.299, 0.587, 0.114));
    return c * smoothstep(BLOOM_THRESHOLD, 1.0, l);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec3 base = texture(iChannel0, uv).rgb;

    // 5x5 Gaussian blur of the bright pass. Weights are baked constants
    // (exp(-i*i*0.5), separable) so the hot path does no per-pixel exp().
    const float G[5] = float[5](0.135335, 0.606531, 1.0, 0.606531, 0.135335);
    const float GAUSS_SUM = 6.16892; // (G[0] + 2*G[1] + 2*G[2])^2

    vec2 px = BLOOM_RADIUS / iResolution.xy;
    vec3 bloom = vec3(0.0);
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            // Reuse the already-sampled center texel rather than re-fetching.
            vec3 c = (x == 0 && y == 0)
                ? base
                : texture(iChannel0, uv + vec2(float(x), float(y)) * px).rgb;
            bloom += brightPass(c) * (G[x + 2] * G[y + 2]);
        }
    }
    bloom /= GAUSS_SUM;

    fragColor = vec4(base + bloom * BLOOM_INTENSITY, 1.0);
}
