#version 120

#include "/lib/framebuffer.glsl"

uniform sampler2D lightmap;
uniform sampler2D texture;
uniform vec4 entityColor;
uniform sampler2D gnormal;

varying vec4 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 normal;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	//color *= texture2D(lightmap, lmcoord);

/* DRAWBUFFERS:012 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(lmcoord.st / 16.0, 0.01, 1.0);
	gl_FragData[2] = vec4(normal * 0.5 + 0.5, 1.0);
}
