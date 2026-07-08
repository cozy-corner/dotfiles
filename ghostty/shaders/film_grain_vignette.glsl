// Subtle film grain + vignette, tuned to sit quietly under Kanagawa Wave.
// Shadertoy-style shader for Ghostty: iChannel0 = terminal, iResolution, iTime.

// Amount of grain added per pixel (peak deviation). Keep low so it reads as
// texture, not noise. ~0.05 is barely-there on Kanagawa's dark bg.
const float GRAIN_STRENGTH = 0.05;

// How much the corners are darkened relative to the center (0 = none).
const float VIGNETTE_STRENGTH = 0.32;

float hash(vec2 p) {
    // Cheap value noise; good enough for grain.
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 color = texture(iChannel0, uv);

    // Animate the grain by jittering the sample coord every frame.
    float n = hash(fragCoord + fract(iTime) * vec2(53.7, 91.3));
    color.rgb += (n - 0.5) * GRAIN_STRENGTH;

    // Radial vignette: 0 at center, grows toward corners.
    vec2 d = uv - 0.5;
    float vig = smoothstep(0.35, 0.85, length(d));
    color.rgb *= 1.0 - vig * VIGNETTE_STRENGTH;

    fragColor = color;
}
