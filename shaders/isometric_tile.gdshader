shader_type canvas_item;

// Generates a filled isometric square tile
uniform vec4 base_color : source_color = vec4(0.3, 0.6, 0.3, 1.0);
uniform vec4 edge_color : source_color = vec4(0.2, 0.4, 0.2, 1.0);
uniform float edge_width : hint_range(0.0, 0.5) = 0.05;
uniform float iso_angle : hint_range(0.0, 1.57079) = 0.785398; // 0 to 90 degrees

// Edge visibility controls
uniform bool show_top_edge = true;
uniform bool show_right_edge = true;
uniform bool show_bottom_edge = true;
uniform bool show_left_edge = true;

void fragment() {
	vec2 uv = UV;
	
	// Center the coordinates
	vec2 p = uv - vec2(0.5, 0.5);
	
	// Calculate isometric ratio
	float iso_ratio = tan(iso_angle);
	
	// Auto-scale to fit viewport
	float auto_scale = mix(1.5, 0.7, iso_angle / 1.57079);
	p *= auto_scale;
	
	// Transform to isometric coordinates
	vec2 iso_p = vec2(
		p.x,
		p.y / iso_ratio
	);
	
	// Apply 45-degree rotation for diamond shape
	float cos_45 = 0.707107;
	float sin_45 = 0.707107;
	
	vec2 rotated = vec2(
		iso_p.x * cos_45 - iso_p.y * sin_45,
		iso_p.x * sin_45 + iso_p.y * cos_45
	);
	
	// Check if inside the square
	float max_dist = max(abs(rotated.x), abs(rotated.y));
	
	// Inside the tile?
	float inside = step(max_dist, 0.5);
	
	// Distance from each edge (positive inside)
	float dist_right = 0.5 - rotated.x;
	float dist_top = 0.5 - rotated.y;
	float dist_left = 0.5 + rotated.x;
	float dist_bottom = 0.5 + rotated.y;
	
	// Find minimum distance to any edge
	float min_dist = min(min(dist_right, dist_top), min(dist_left, dist_bottom));
	
	// Check which edge we're closest to (with small tolerance to avoid ambiguity)
	float tolerance = 0.001;
	float is_right_edge = step(abs(min_dist - dist_right), tolerance) * float(show_right_edge);
	float is_top_edge = step(abs(min_dist - dist_top), tolerance) * float(show_top_edge);
	float is_left_edge = step(abs(min_dist - dist_left), tolerance) * float(show_left_edge);
	float is_bottom_edge = step(abs(min_dist - dist_bottom), tolerance) * float(show_bottom_edge);
	
	// Combine edge flags
	float show_any_edge = max(max(is_right_edge, is_top_edge), max(is_left_edge, is_bottom_edge));
	
	// Only show edge if we're close to it AND it's enabled
	float is_edge = step(min_dist, edge_width) * show_any_edge * inside;
	
	// Mix colors
	vec4 final_color = mix(base_color, edge_color, is_edge);
	
	// Set alpha to 0 outside the tile
	COLOR = final_color * inside;
}