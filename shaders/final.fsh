#version 120

#include "/lib/framebuffer.glsl"

varying vec4 texcoord;

uniform sampler2D gcolor;

vec3 convertToHDR(in  vec3 color)
{
  vec3 HDRImage;

  vec3 overExposed = color * 1.1f;
  vec3 underExposed = color / 1.3f;

  HDRImage = mix(underExposed, overExposed, color);

  return HDRImage;
}

vec3 getExposure(in vec3 color) {
  vec3 retColor;
  color *= 1.115;
  //retColor = pow(color, vec3(1/2.2));

  retColor = color;
  return retColor;
}

vec3 Reinghard(in vec3 color) {
  color = color /  (1 + color);

  return color;
}

void main() {

  vec3 color = texture2D(gcolor, texcoord.st).rgb;

  color = convertToHDR(color);

  color = getExposure(color);

  color = Reinghard(color);

  gl_FragColor = vec4(pow(color.rgb, vec3(1.0 / 2.2)), 1.0);

}
