shader_type canvas_item;

// Damage flash parameters
uniform vec4 flash_color : source_color = vec4(1.0, 0.4544071, 0.44399953, 1.0);
uniform float flash_strength : hint_range(0.0, 1.0) = 0.0;

// Outline parameters
uniform vec4 outline_color : source_color = vec4(0.573, 0.314, 0.247, 1.0);
uniform float outline_thickness : hint_range(0, 10) = 0.5;

const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1), 
	vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment() {
	// Get the base color
	vec4 base = texture(TEXTURE, UV);
	
	// Apply damage flash
	vec3 flashed = mix(base.rgb, flash_color.rgb, flash_strength);
	vec4 color = vec4(flashed, base.a);
	
	// Calculate outline
	vec2 size = TEXTURE_PIXEL_SIZE * outline_thickness;
	float outline = 0.0;
	
	for (int i = 0; i < OFFSETS.length(); i++) {
		outline += texture(TEXTURE, UV + size * OFFSETS[i]).a;
	}
	outline = min(outline, 1.0);
	
	// Apply outline (only in transparent areas around the sprite)
	COLOR = mix(color, outline_color, outline - color.a);
}
