#version 400

out vec4 frag_colour;
in vec4 pos;

void main () {
	frag_colour = pos+0.6; // Set R,G,B,A colour
}
