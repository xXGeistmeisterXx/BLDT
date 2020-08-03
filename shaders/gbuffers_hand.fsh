#version 120

#include "/lib/framebuffer.glsl"

uniform sampler2D texture;
uniform int heldBlockLightValue;

varying vec3 tintColor;
varying vec3 normal;
varying vec4 texcoord;
varying vec2 lmcoord;

void main() {
  vec4 handColor = texture2D(texture, texcoord.st);
  handColor.rgb *= tintColor;
  //color *= texture2D(lightmap, lmcoord);

  gl_FragData[0] = vec4(handColor); //gcolor
  gl_FragData[2] = vec4((normal * 0.5 + 0.5), 1.0); //gnormal
  gl_FragData[1] = vec4(texcoord.st / 16.0, max(.3, heldBlockLightValue/16.0), 1.0); //gdepth

}
