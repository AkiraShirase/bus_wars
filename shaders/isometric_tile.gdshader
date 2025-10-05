shader_type canvas_item;

// Generates an isometric tile texture
uniform vec4 base_color : source_color = vec4(0.3, 0.6, 0.3, 1.0);
uniform vec4 edge_color : source_color = vec4(0.2, 0.4, 0.2, 1.0);
uniform float tile_width = 64.0;
uniform float tile_height = 32.0;

void fragment() {
	vec2 uv = UV;
	vec2 center = vec2(0.5, 0.5);

	// Calculate isometric diamond shape
	// Transform UV to centered coordinates
	vec2 centered = (uv - center) * 2.0;

	// Isometric diamond boundaries
	// For a 2:1 ratio isometric tile
	float x = abs(centered.x) * tile_height;
	float y = abs(centered.y) * tile_width;

	// Diamond shape: |x| + |y| <= 1
	float dist = x + y;

	// Edge detection
	float edge_threshold = tile_width * 0.9;
	float is_edge = step(edge_threshold, dist);

	// Mix colors
	vec4 final_color = mix(base_color, edge_color, is_edge);

	// Alpha for diamond shape
	float alpha = step(dist, tile_width);

	COLOR = vec4(final_color.rgb, alpha);
}
