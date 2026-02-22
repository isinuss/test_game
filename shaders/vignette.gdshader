shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.35;
uniform float radius : hint_range(0.0, 1.0) = 0.55;
uniform float softness : hint_range(0.0, 1.0) = 0.45;

void fragment() {
	vec2 uv = UV;
	// Slightly oval vignette (wider than tall)
	vec2 centered = (uv - 0.5) * vec2(1.0, 1.3);
	float dist = length(centered);
	float vig = smoothstep(radius, radius + softness, dist);
	COLOR = vec4(0.0, 0.0, 0.0, vig * strength);
}
