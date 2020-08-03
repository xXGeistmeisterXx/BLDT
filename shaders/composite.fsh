#version 120

const int RGBA = 0;
const int RGBA16 = 1;
const int shadowMapResolution = 4096;
const int noiseTextureResolution = 64;
const float sunPathRotation = 25.0;

const int gdepthFormat = RGBA;
const int gcolorFormat = RGBA16;
const int gnormalFormat = RGBA16;

uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D gdepth;

varying vec4 texcoord;

varying vec3 lightVector;
varying vec3 lightColor;
varying vec3 skyColor;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

uniform sampler2D gdepthtex;
uniform sampler2D shadow;
uniform sampler2D noisetex;
uniform sampler2D shadowcolor0;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform vec3 cameraPosition;

uniform int viewHeight;
uniform int viewWidth;

vec3 getAlbedo(in vec2 coord) {
  return pow(texture2D(gcolor, coord).rgb, vec3(2.2));
}

vec3 getNormal(in vec2 coord) {
  return texture2D(gnormal, coord).rgb * 2.0 - 1.0;
}

float getEmission(in vec2 coord) {
  return texture2D(gdepth, coord).b;
}

float getTorchLightStrength(in vec2 coord) {
  return texture2D(gdepth, coord).r;
}

float getSkyLightStrength(in vec2 coord) {
  return texture2D(gdepth, coord).g;
}

float getDepth(in vec2 coord) {
  return texture2D(gdepthtex, coord).r;
}

vec4 getCameraSpacePosition(in vec2 coord) {
  float depth = getDepth(coord);
  vec4 positionNdcSpace = vec4(coord.s * 2.0 - 1.0, coord.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0);
  vec4 positionCameraSpace = gbufferProjectionInverse * positionNdcSpace;

  return positionCameraSpace / positionCameraSpace.w;
}

vec4 getWorldSpacePosition(in vec2 coord) {
  vec4 positionCameraSpace = getCameraSpacePosition(coord);
  vec4 positionWorldSpace = gbufferModelViewInverse * positionCameraSpace;
  positionWorldSpace.xyz += cameraPosition;

  return positionWorldSpace;
}

vec3 getShadowSpacePosition(in vec2 coord) {
  vec4 positionWorldSpace = getWorldSpacePosition(coord);

  positionWorldSpace.xyz -= cameraPosition;
  vec4 positionShadowSpace = shadowModelView * positionWorldSpace;
  positionShadowSpace = shadowProjection * positionShadowSpace;
  positionShadowSpace /= positionShadowSpace.w;

  return positionShadowSpace.xyz * 0.5 + 0.5;
}

mat2 getRotationMatrix (in vec2 coord) {
  float rotationAmount = texture2D(
    noisetex,
    coord * vec2(
      viewWidth / noiseTextureResolution,
      viewHeight / noiseTextureResolution
      )

    ).r;

  return mat2(
    cos(rotationAmount), -sin(rotationAmount),
    sin(rotationAmount), cos(rotationAmount)
    );
}

vec3 getShadowColor(in vec2 coord) {
  vec3 shadowCoord = getShadowSpacePosition(coord);

  mat2 rotationMatrix = getRotationMatrix(coord);
  vec3 shadowColor = vec3(0.0);
  for(int y = -1; y < 2; y++) {
    for(int x = -1; x < 2; x++) {
        vec2 offset = vec2(x, y) / shadowMapResolution;
        offset = rotationMatrix * offset;
        float shadowMapSample = texture2D(shadow, shadowCoord.st + offset).r;
        float visibility = step(shadowCoord.z - shadowMapSample, 0.0005);

        vec3 colorSample = texture2D(shadowcolor0, shadowCoord.st + offset).rgb;
        shadowColor += mix(colorSample, vec3(1.0), visibility);
    }
  }

  return shadowColor * 0.111;

}

vec3 calculateLitSurface(in vec3 color) {
  vec3 sunlightAmount = getShadowColor(texcoord.st);
  vec3 ambientLighting = vec3(0.3)  ;

  return color * (sunlightAmount + ambientLighting);
}

struct LightMap {

  float torchLightStrength;
  float skyLightStrength;
};

struct Fragment {
  vec3 albedo;
  vec3 normal;

  float emission;
};

Fragment getFragment(in vec2 coord) {
  Fragment newFragment;

  newFragment.albedo = getAlbedo(coord);
  newFragment.normal = getNormal(coord);
  newFragment.emission = getEmission(coord);

  return newFragment;
}

LightMap getLightMapSample(in vec2 coord) {
  LightMap lightmap;

  lightmap.torchLightStrength = getTorchLightStrength(coord);
  lightmap.skyLightStrength = getSkyLightStrength(coord);

  return lightmap;
}

vec3 calculateLighting(in Fragment frag, in LightMap lightmap) {

  float directLightStrength = dot(frag.normal, lightVector);
  directLightStrength = max(0.0, directLightStrength);
  vec3 directLight = directLightStrength * lightColor;

  vec3 torchColor = vec3(.95, 0.93, 0.91) * 0.05;
  vec3 torchLight = torchColor * lightmap.torchLightStrength;
	torchLight = pow(torchLight, vec3(1.0/.22)) * vec3(5.0);

  vec3 skyLight = skyColor * lightmap.skyLightStrength;

  vec3 fcolor = max(skyLight, torchLight);
  fcolor = max(fcolor, directLight);

  vec3 sunlightAmount = getShadowColor(texcoord.st);

  vec3 litColor = frag.albedo * mix(fcolor, fcolor+directLight+torchLight, 0.4);
  litColor =  frag.albedo * mix(fcolor, fcolor + directLight + torchLight, sunlightAmount / vec3(0.8));

  return mix(litColor.rgb, frag.albedo, (frag.emission));
}

void main() {
	vec3 color = texture2D(gcolor, texcoord.st).rgb;
	Fragment frag = getFragment(texcoord.st);
  LightMap lightmap = getLightMapSample(texcoord.st);
  vec3 finalColor = calculateLighting(frag, lightmap);


	gl_FragData[0] = vec4(finalColor, 1.0); //gcolor
  //gl_FragData[0] = vec4(getShadowColor(texcoord.st), 1.0);
  //gl_FragData[0] = vec4(texture2D(gdepth, texcoord.st).rga, 1.0);
  //gl_FragData[0] = vec4(vec3(getDepth(texcoord.st)), 1.0);
  //gl_FragData[0] = vec4(pow(vec3(texture2D(depthtex0, texcoord.st).rgb), vec3(50.0)), 1.0);
}
