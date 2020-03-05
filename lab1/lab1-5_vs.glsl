#version 400

layout(location=0) in vec4 vp;
out vec4 pos;

uniform mat4 modelViewProjectionMatrix;

void main () {
	gl_Position = modelViewProjectionMatrix * vp; // Needs to be updated with MVP matrix!
	pos = vp;
};
  
