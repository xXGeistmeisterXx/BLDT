#version 120

varying vec4 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 normal;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = gl_MultiTexCoord1;
	glcolor = gl_Color;
	normal = normalize(gl_NormalMatrix * gl_Normal);
}
