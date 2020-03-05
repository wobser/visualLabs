#version 440

out vec4 frag_colour;
 
in vec4 normal;
in vec4 position;

void main () {
	//frag_colour = normal + position;
	frag_colour.r = normal.x;
	frag_colour.g = normal.y;
	frag_colour.b = normal.z;

}
