#version 120

uniform int worldTime;
uniform vec3 sunPosition;
uniform vec3 moonPosition;

varying vec4 texcoord;

varying vec3 lightVector;
varying vec3 lightColor;
varying vec3 skyColor;
varying float test;

void main() {
  gl_Position = ftransform();

  texcoord = gl_MultiTexCoord0;

  float realWorldTime;

  vec3 skyColorD = vec3(0.03);
  vec3 skyColorN = vec3(0.003);

  if(worldTime >= 0 && worldTime <= 6000) {

    realWorldTime = float(worldTime) / 6000.0;

  } else if(worldTime > 6000 && float(worldTime) <= 12000) {

    realWorldTime = -1*(((float(worldTime) - 6000.0) / 6000.0) - 1);

  } else if(worldTime > 12000 && worldTime <= 18000) {

    realWorldTime = -1*((float(worldTime) - 12000.0) / 6000.0);

  } else if(worldTime > 18000 && worldTime <= 24000) {

    realWorldTime = (((float(worldTime) - 18000.0) / 6000.0) - 1);

  }

  if(realWorldTime >= 0) {
    skyColor = skyColorD - -.0270*(realWorldTime - 1);
  } else {
    skyColor = skyColorN - vec3(-.002*(realWorldTime));
  }


  test = realWorldTime;

  if(worldTime < 12700 || worldTime > 23250) {
    lightVector = normalize(sunPosition);
    //skyColor = vec3(0.03);
  } else {
    lightVector = normalize(moonPosition);
    //skyColor = vec3(0.003);
  }

  lightColor = vec3(0.001);

}
