#version 400

in vec3 vp;   // vertex position (input)
out vec4 pos; 

void main () {
	gl_Position = vec4( vp, 1.0 ); // position sent to rasteriser old -> vec4( vp, 1.0 );
	pos = vec4(vp, 1.0);
};