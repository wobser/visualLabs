#version 440

out vec4 frag_colour;
in vec4 normal;
in vec4 position;

uniform int light_count;
uniform vec4 light_position[4]; // can have up to 4 light sources
uniform vec4 light_colour[4];


vec4 lambertian_brdf( vec4 in_direction, vec4 out_direction, vec4 normal )
{
	// YOUR CODE GOES HERE
	// Implement a Lambertian BRDF 
}

void main () {

	frag_colour = vec4(0);
	for (int l = 0; l < light_count; ++l )
	{
		// YOUR CODE GOES HERE
		// Implement Equation 1 from the lab instructions to set frag_colour here:
		// (incoming light_colour) * (brdf) * (cosine of incoming light angle)
		frag_colour += vec4( 0.2, 0.2, 0.2, 0 ); // remove this!
	}
}
