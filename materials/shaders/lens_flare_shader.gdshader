shader_type canvas_item;
render_mode blend_mix;

uniform vec2 sun_position = vec2(0.0);
uniform vec3 tint = vec3(1.4,1.2,1.0);
uniform sampler2D noise_texture;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform bool use_debug = false;


void fragment()
{
  vec2 uv = UV;
  // Convert UV to range [-1, 1]
  uv = (uv * 2.0 - 1.0);

  // Calculate sun position in UV space
  vec2 sun_uv = (sun_position * 2.0) - 1.0;

  // if use_debug is true, draw a circle at the sun position
  if (use_debug) {
    float radius = 0.05; // Radius of the debug circle
    float circle = 1. - ceil(length(uv - sun_uv) - radius);
    if (circle > 0.0) {
      COLOR = vec4(1.0, 0.0, 0.0, 1.0); // Red circle for debug
    } else {
      COLOR = vec4(0.0);
    }
  } else {
    COLOR = vec4(0.0);
  }
}