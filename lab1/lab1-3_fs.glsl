#version 400

out vec4 frag_colour;
in vec4 pos;


void main () {
	frag_colour = pos+0.5; // Set R,G,B,A colour old -> vec4(0.4, 0.6, 0.8, 1);
}
