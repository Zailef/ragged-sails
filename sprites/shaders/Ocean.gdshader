shader_type canvas_item;

uniform sampler2D texture_offset_uv : hint_default_black;

uniform vec2 tiled_factor = vec2(1.0,1.0);
uniform float aspect_ratio = 0.5;

uniform vec2 tiled_offset_scale = vec2(0.2, 0.2);
uniform float texture_offset_time_scale = 0.05;

uniform float sine_time_scale = 0.03;
uniform vec2 sine_offset_scale = vec2(0.3, 0.6);
uniform float sine_wave_size = 0.4;

vec2 calculate_sine_wave(float time, float multiplier, vec2 uv, vec2 offset_scale) {
	float time_multiplied = time * multiplier;
	float unique_offset = uv.x + uv.y;
	return vec2(
		sin(time_multiplied + unique_offset * offset_scale.x),
		cos(time_multiplied + unique_offset * offset_scale.y)
	);
}

void fragment() {
	vec2 base_uv_offset = UV * tiled_offset_scale;
	base_uv_offset += TIME * texture_offset_time_scale;

	vec2 adjusted_uv = UV * tiled_factor;
	adjusted_uv.y *= aspect_ratio;

	vec2 texture_based_offset = texture(texture_offset_uv, base_uv_offset).rg * texture_offset_time_scale;
	vec2 sine_offset = calculate_sine_wave(TIME, sine_time_scale, adjusted_uv, sine_offset_scale);
	vec2 waves_uvs = adjusted_uv + texture_based_offset + sine_offset * sine_wave_size;

	COLOR = texture(TEXTURE, waves_uvs);
	NORMAL_MAP = texture(NORMAL_TEXTURE, waves_uvs / 5.0).rgb;
}