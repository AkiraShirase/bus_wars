shader_type canvas_item;

// Parameter to control the strength of random color change
uniform float change_power : hint_range(0.0, 1.0) = 0.5;
// Parameter to control the scale/size of noise pattern
uniform float noise_size : hint_range(0.1, 100.0) = 10.0;

// Simple hash function for pseudo-random values
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
    // Get the original color from the texture
    vec4 original_color = texture(TEXTURE, UV);

    // Scale UV by noise_size to control the scale of noise pattern
    vec2 scaled_uv = floor(UV * noise_size);

    // Generate random values for each color channel using scaled pixel position
    float r_offset = hash(scaled_uv + vec2(0.0, 0.0)) * 2.0 - 1.0;
    float g_offset = hash(scaled_uv + vec2(1.0, 0.0)) * 2.0 - 1.0;
    float b_offset = hash(scaled_uv + vec2(0.0, 1.0)) * 2.0 - 1.0;

    // Apply the random offsets scaled by change_power
    vec3 noise = vec3(r_offset, g_offset, b_offset) * change_power;

    // Add noise to original color and clamp to valid range
    vec3 final_color = clamp(original_color.rgb + noise, 0.0, 1.0);

    COLOR = vec4(final_color, original_color.a);
}