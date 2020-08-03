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

float A = 0.15;
float B = 0.50;
float C = 0.10;
float D = 0.20;
float E = 0.02;
float F = 0.30;
float W = 11.2;

vec3 uncharted2Math(in vec3 x) {
  return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

vec3 uncharted2Tonemap(in vec3 color) {
  vec3 retColor;
  float exposureBias = 2.0;

  vec3 curr = uncharted2Math(exposureBias * color);

  vec3 whiteScale = 1.0 / uncharted2Math(vec3(W));

  retColor = curr * whiteScale;

  return retColor;
}

vec3 Burgess (in vec3 color) {
  vec3 maxColor = max(vec3(0.0), color - 0.004);
  vec3 retColor = (maxColor * (6.2 * maxColor + 0.05)) /  (maxColor * (maxColor * 6.2 + 2.7) + 0.06);

  return retColor;
}

void main() {

  vec3 color = texture2D(gcolor, texcoord.st).rgb;

  color = convertToHDR(color);

  color = getExposure(color);

  float profile_color = 0.0; //[0.0, 1.0, 2.0, 3.0]

  if(profile_color == 0.0) {
    color = Reinghard(color);
  } else if (profile_color == 1.0) {
    color = uncharted2Tonemap(color);
  } else if (profile_color == 2.0) {
    color = Burgess(color);
  }

  gl_FragColor = vec4(pow(color.rgb, vec3(1.0 / 2.2)), 1.0);

}
