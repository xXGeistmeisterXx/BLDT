#version 120

attribute vec4 mc_Entity;

varying vec4 texcoord;
varying vec4 color;
varying float isTransparent;

float getIsTransparent(in float materialId) {
  if(materialId == 160.0 || materialId == 95.0 || materialId == 30.0) {
    return 1.0;
  } else {
    return 0.0;
  }
}

void main() {
  texcoord = gl_MultiTexCoord0;
  color = gl_Color;

  isTransparent = getIsTransparent(mc_Entity.x);

  gl_Position = ftransform();
}
