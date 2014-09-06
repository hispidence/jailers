invisShaderSource = [[
vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = vec4(0.0f, 0.0f, 0.0f, 0.0f);// Texel(texture, texture_coords);
  return result;
  }
]]

fadeShaderSource = [[
  uniform vec3 fadeTo;
  uniform float fadeFactor;

  vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 result;
    vec4 col = Texel(texture, texture_coords);
    vec4 fade = vec4(fadeTo, col.a);
    result = (col * (1.0f - fadeFactor)) + (fade * fadeFactor);
    return result;
  }
]]
