shader_type canvas_item;
render_mode unshaded;

// CRT scanline + vignette overlay for bureaucratic surveillance aesthetic.
uniform float scanline_count : hint_range(100.0, 800.0) = 270.0;
uniform float scanline_strength : hint_range(0.0, 0.3) = 0.06;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.35;
uniform float flicker_amount : hint_range(0.0, 0.05) = 0.008;
uniform float time_scale : hint_range(0.0, 10.0) = 1.0;

void fragment() {
	vec2 uv = UV;

	// Scanlines — horizontal dark bands
	float scanline = sin(uv.y * scanline_count * 3.14159265) * 0.5 + 0.5;
	float sl_alpha = (1.0 - scanline) * scanline_strength;

	// Vignette — darken edges like old monitor
	vec2 vig = uv * 2.0 - 1.0;
	float vignette = dot(vig * 0.6, vig * 0.6);
	vignette = clamp(vignette, 0.0, 1.0) * vignette_strength;

	// Subtle temporal flicker
	float flicker = sin(TIME * time_scale * 8.0) * flicker_amount;

	COLOR = vec4(0.0, 0.0, 0.0, sl_alpha + vignette + flicker);
}
