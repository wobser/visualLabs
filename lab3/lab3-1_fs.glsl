#version 400
out vec4 o_fragment_color; // The final colour

// User input:
uniform vec2 i_window_size;
uniform float i_global_time;
uniform vec4 i_mouse_state;

// Camera parameters:
uniform vec3 i_position;
uniform vec3 i_up;
uniform vec3 i_right;
uniform vec3 i_dir;
uniform float i_focal_dist;

#define NUM_SPHERES 5
#define MAX_SAMPLES 1

struct Ray { vec3 origin, dir; float weight;};

struct Material{
  vec3 color_emission;
  vec3 color_diffuse;
  vec3 color_glossy;
  float roughness;
  float reflection;
  float transmission;
  float ior;  
};

struct Sphere {
  float radius;
  vec3 center;
  Material material;
};

struct Plane {
  float offset;
  vec3 normal;
  Material material;
};

struct Intersection
{
	vec3 point;
	vec3 normal;
	Material material;
};

struct Scene {	
	Sphere spheres[NUM_SPHERES];
	Plane ground_plane[1];
	vec3 sun_position;
	float sun_brightness;	
};

Scene scene;


void init( float sun_bright )
{
	// Hard-coded single point light source
	scene.sun_brightness = 10;
	scene.sun_position = vec3(6e3,  1e4, 1e4);
	
  // Initialise 5 spheres and a ground plane

	scene.spheres[0].center = vec3(0, 0.3, 0.5) ; 
	scene.spheres[0].radius = 0.3;
	scene.spheres[0].material.color_diffuse = vec3( 0.3, 0.1, 0.1 );
	scene.spheres[0].material.color_glossy = vec3( 1 );
	scene.spheres[0].material.color_emission = vec3( 0 );
	scene.spheres[0].material.roughness = 100;
	scene.spheres[0].material.reflection = 0.5;
	scene.spheres[0].material.transmission = 0;
	scene.spheres[0].material.ior = 1;
  
	scene.spheres[1].center = vec3(0.8, 0.3, 0.8);
	scene.spheres[1].radius = 0.3;
	scene.spheres[1].material.color_diffuse = 0.5 * vec3( 0.0, 1.0, 0.0 );
	scene.spheres[1].material.color_glossy = vec3( 1 );
	scene.spheres[1].material.roughness = 10000;
	scene.spheres[1].material.color_emission = vec3( 0 );
	scene.spheres[1].material.reflection = 0.1;
	scene.spheres[1].material.transmission = 0.8;
	scene.spheres[1].material.ior = 1.4;

  scene.spheres[2].center = vec3(0.55, 0.1, 0.2) ;
  scene.spheres[2].radius = 0.1;
  scene.spheres[2].material.color_diffuse = 0.8 * vec3( 0.0, 0.0, 0.0 );
  scene.spheres[2].material.color_glossy = vec3( 1 );
  scene.spheres[2].material.roughness = 1000;
  scene.spheres[2].material.color_emission = vec3( 3.6, 0, 0 );
  scene.spheres[2].material.reflection = 0.0;
  scene.spheres[2].material.transmission = 0;
  scene.spheres[2].material.ior = 1;

  scene.spheres[3].center = vec3(0.7, 0.8, -0.5) ;
  scene.spheres[3].radius = 0.8;
  scene.spheres[3].material.color_diffuse = 0.5 * vec3( 0.2, 0.2, 0.15 );
  scene.spheres[3].material.color_glossy = vec3( 1 );
  scene.spheres[3].material.roughness = 10;
  scene.spheres[3].material.color_emission = vec3( 0 );
  scene.spheres[3].material.reflection = 0.0;
  scene.spheres[3].material.transmission = 0;
  scene.spheres[3].material.ior = 1;

  scene.spheres[4].center = vec3(-0.65, 0.6, -1) ;
  scene.spheres[4].radius = 0.6;
  scene.spheres[4].material.color_diffuse = 0.5 * vec3( 0.5, 0.4, 0.25 );
  scene.spheres[4].material.color_glossy = vec3( 1 );
  scene.spheres[4].material.roughness = 5000;
  scene.spheres[4].material.color_emission = vec3( 0 );
  scene.spheres[4].material.reflection = 0.0;
  scene.spheres[4].material.transmission = 0;
  scene.spheres[4].material.ior = 1;

  scene.ground_plane[0].normal = vec3(0,1,0);
  scene.ground_plane[0].offset = 0;
  scene.ground_plane[0].material.color_diffuse = 1.0 * vec3( 0.6 );
  scene.ground_plane[0].material.color_glossy = vec3( 0 );
  scene.ground_plane[0].material.roughness = 0;
  scene.ground_plane[0].material.color_emission = vec3( 0 );
  scene.ground_plane[0].material.reflection = 0.0;
  scene.ground_plane[0].material.transmission = 0;
  scene.ground_plane[0].material.ior = 1;  

}

vec3 simple_sky(vec3 direction)
{
	// Also include a textured sky sphere, for niceness
	float emission_sky = 1e-1*scene.sun_brightness;
	float emission_sun = 1.0*scene.sun_brightness*scene.sun_brightness;
	vec3 sky_color = vec3(0.35, 0.65, 0.85);
	vec3 haze_color = vec3(0.8, 0.85, 0.9);
	vec3 light_color = vec3(1);
	
	float sun_spread = 2500.0;
	float haze_spread = 1.6;
	float elevation = acos(direction.y);
	
	//float angle = abs(dot(direction, normalize(i_light_position)));
	float angle = abs(dot(direction, normalize(scene.sun_position)));
	float response_sun = pow(angle, sun_spread);
	float response_haze = pow(elevation, haze_spread);
	
	vec3 sun_component = mix(emission_sky*sky_color, emission_sun*light_color,response_sun);
	vec3 haze_component = mix(vec3(0),  emission_sky*haze_color,response_haze);
	
	return (sun_component+haze_component);
}


// Ray-sphere intersection
///\todo LAB TASK
float intersect(Ray ray, Sphere s) 
{

	
	// Return 0 if no hit
	return 0;
}

// Ray-plane intersection
///\todo LAB TASK
float intersect(Ray ray, Plane p) 
{
	// Return 0 if no hit
	return 0;
}

// Check for intersection of a ray and all objects in the scene
Intersection intersect(Ray ray)
{
	Intersection I;
	float t = 1e32;
	int id = -1;
	
	//CHECK SPHERES
	for (int i = 0; i < NUM_SPHERES; ++i) {
		// Check intersection with sphere #i
		float d = intersect(ray,scene.spheres[i]);
		// Keep closest hit t
		if (d!=0. && d<t) {
			t = d; 
			id = i;
		}
	}
	I.point = t * ray.dir + ray.origin;
	I.normal = normalize(I.point-scene.spheres[id].center);
	I.material = scene.spheres[id].material;
	
	//CHECK PLANE
	{
		float d = intersect(ray,scene.ground_plane[0]);
		if (d>0 && d<=t){
			t=d;
			I.point = t * ray.dir + ray.origin;
			I.normal = scene.ground_plane[0].normal;
			I.material = scene.ground_plane[0].material;
			// Compute procedural checker texture because it's nice
			I.material.color_diffuse =
				(mod(floor(I.point.x) + floor(I.point.z),2.0) == 0.0) ?
				scene.ground_plane[0].material.color_diffuse :
				vec3(1.0) - scene.ground_plane[0].material.color_diffuse;
		}
	}
	
	//HIT SKY IF NO OBJECT HIT
	if (t>1e20){
		I.point = ray.dir*t;
		I.normal = -ray.dir;

		// Compute sky colour 
		vec3 sky = simple_sky(ray.dir);

		// Sky is all emission, no diffuse or glossy shading:
		I.material.color_diffuse = 0 * sky; 
		I.material.color_glossy = 0.0 * vec3( 1 );
		I.material.roughness = 1;
		I.material.color_emission = 0.3 * sky;
		I.material.reflection = 0.0;
		I.material.transmission = 0;
		I.material.ior = 1;		
	}
	
	return I;
}

vec3 raycast(Ray ray) 
{
	// Initialise colour
	vec3 color = vec3(0);

	// Find intersection
	Intersection isec = intersect(ray);

	vec3 nl = isec.normal;
	vec3 light_direction = normalize(scene.sun_position - isec.point);
	float cos_angle = max(0,dot(nl, light_direction));

	///\todo COMPUTE A MORE INTERESTING COLOUR HERE
	color = isec.material.color_diffuse + isec.material.color_emission;
	    
	return  color;
}

void main() {
	vec2 uv =  gl_FragCoord.xy - 0.5*i_window_size.xy;
	
	//init(i_light_position, 10.0 ); //i_mouse_state.y); 
	init( 10.0 );
	
	//basis for defining the image plane
	vec3 cx = i_right;
	vec3 cy = i_up;   
	vec3 cz = i_dir;  
	
	//crude zooming by pressing right mouse button
	float f_dist = i_focal_dist + i_focal_dist*i_mouse_state.w; 
	
	int num_samples=1;

	Ray ray;
	ray.origin = i_position;
	ray.dir = normalize( uv.x*cx + uv.y*cy + cz*f_dist);
	
	vec3 color = raycast(ray);
	
	//linear blend, will look terrible
	// o_fragment_color =  vec4((color),1);

	//gamma correction
	o_fragment_color = vec4( pow ( clamp(color.xyz/num_samples, 0., 1.), vec3(1./2.2)), 1.); 

	///\todo REMOVE THIS LINE after you have the triangles set up
	//o_fragment_color = vec4(1,0.9,0.8,1); 
}
