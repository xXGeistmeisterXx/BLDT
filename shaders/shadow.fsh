#version 120

uniform sampler2D tex;

varying vec4 texcoord;
varying vec4 color;
varying float isTransparent;

void main() {
  vec3 fragColor = color.rgb * texture2D(tex, texcoord.st).rgb * texture2D(tex, texcoord.st).a;
  fragColor = mix(vec3(0.0), fragColor, isTransparent);


  gl_FragData[0] = vec4(fragColor, 1.0);
}
