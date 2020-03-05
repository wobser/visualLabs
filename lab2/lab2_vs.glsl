#version 440

// vec3 position and normal, because that's how they are defined in the file
layout(location=0) in vec3 vp; 
layout(location=1) in vec3 vn;

out vec4 normal;
out vec4 position;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewMatrix;

void main () {
	// In the code below, we turn vec3 into a vec4
	// so that we can multiply them with a mat4.
	
	gl_Position = modelViewProjectionMatrix * (vec4(vp, 1));
	

	position = modelViewMatrix * (vec4(vp, 1));
	normal =   modelViewMatrix * (vec4(vn, 0));

	//position = modelViewProjectionMatrix * (vec4(vp, 1));
	//normal =   modelViewProjectionMatrix * (vec4(vn, 0));

};
  
