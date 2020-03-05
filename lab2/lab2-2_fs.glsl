#version 440

out vec4 frag_colour;
in vec4 normal;
in vec4 position;

uniform int light_count;
uniform vec4 light_position[4]; // can have up to 4 light sources
uniform vec4 light_colour[4];


vec3 lambertian_brdf( vec3 in_direction, vec3 out_direction, vec3 normal )
{
	// YOUR CODE GOES HERE
	// Implement a Lambertian BRDF 
	//vec4 direction = normalize(in_direction - out_direction);
	//vec4 brdf = vec4(dot(normal,direction));
	//return brdf;
	return vec3(0.8f,0.6f,0.3f);
}

void main () {
	
	frag_colour = vec4(0);
	for (int l = 0; l < light_count; ++l )
	{
		// YOUR CODE GOES HERE
		// Implement Equation 1 from the lab instructions to set frag_colour here:
		// (incoming light_colour) * (brdf) * (cosine of incoming light angle)
		vec3 normal = normalize(normal.xyz);
		vec3 indir = normalize(light_position[l].xyz - position.xyz);
		vec3 outdir = normalize(vec3(0) - position.xyz);
		vec3 lamb = lambertian_brdf(indir,outdir,normal);

		frag_colour = vec4(light_colour[l].xyz * lamb * dot(normalize(light_position[l].xyz-position.xyz),normal.xyz) , 1.0);
	}
}
