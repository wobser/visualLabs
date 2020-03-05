#version 400
layout(location = 0) out vec4 o_fragment_color;

uniform sampler2D i_texture;
uniform bool i_display;
uniform uint i_frame_count;

uniform vec2 i_window_size;
uniform float i_global_time;
uniform vec4 i_mouse_state;
uniform vec3 i_position;
uniform vec3 i_up;
uniform vec3 i_right;
uniform vec3 i_dir;
uniform vec3 i_light_position;
uniform vec3 i_light_color;
uniform float i_focal_dist;


#define PI 3.14159265359

#define NUM_SPHERES 5
#define MAX_DEPTH 6
#define MAX_SAMPLES 5

float seed = 0.;
float rand(void){return fract(sin(seed+=0.14) * 43758.5453123);}

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


void init( )
{
	scene.sun_brightness = i_light_color.r;

	
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
	scene.spheres[2].material.color_diffuse = vec3( 0.0, 0.0, 0.0 );
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
	float emission_sky = 1e-1 * i_light_color.r;
	float emission_sun = 10.0 * i_light_color.r*i_light_color.r;
	vec3 sky_color = vec3(0.35, 0.65, 0.85);
	vec3 haze_color = vec3(0.8, 0.85, 0.9);
	vec3 light_color = clamp(i_light_color,0,1);

	float sun_spread = 2500.0;
	float haze_spread = 1.3;
	float elevation = acos(direction.y);
    
	float angle = abs(dot(direction, normalize(i_light_position)));
	float response_sun = pow(angle, sun_spread);
	float response_haze = pow(elevation, haze_spread);

	vec3 sun_component = mix(emission_sky*sky_color, emission_sun*light_color,response_sun);
	vec3 haze_component = mix(vec3(0),  emission_sky*haze_color,response_haze);
    
	return (sun_component+haze_component);
}


float intersect(Ray ray, Sphere s) 
{
	///\todo
	vec3 op = s.center - ray.origin;
	float t;
	float epsilon = 1e-6;
	float b = dot(op, ray.dir);
	float det = b * b - dot(op, op) + s.radius*s.radius;
    
	if (det < 0.) return 0.; 
	else det = sqrt(det);
	return (t = b - det) > epsilon ? t : ((t = b + det) > epsilon ? t : 0.);
}

float intersect(Ray ray, Plane p) 
{
	///\todo
	float a = dot(ray.origin, p.normal);
	float b = dot(ray.dir, p.normal);
	return (-a + p.offset)/b;
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


vec3 random_direction(vec3 d, float spread)
{

	float r2 = spread*rand();
	float phi = 2.0*PI*rand();
	float sina = sqrt(r2);
	float cosa = sqrt(1. - r2);

	vec3 w = normalize(d), u = normalize(cross(w.yzx, w)), v = cross(w, u);
	return (u*cos(phi) + v*sin(phi)) * sina + w * cosa;
}

vec3 pathtrace(Ray ray) 
{
	vec3 absorption = vec3(1);
	vec3 color = vec3(0);
	for(int depth = 0; depth< MAX_DEPTH; ++depth )
	{
		Intersection isec = intersect(ray);

		float R = rand();
        
		if(length(isec.material.color_emission) > 0.0) 
		{
			///\todo Add to `color`
			///\todo Update `absorption`
		}
		
		///\todo with probability isec.material.reflection
		{
			// Create a mirror ray
			///\todo Update `ray.origin` and `ray.dir`
			//ray.origin = x;
			//ray.dir = x;
			///\todo Set `ray.weight`
			///\todo Update `absorption`
			//No push in this version. Just keep going in the loop.
		}

		///\todo with probability isec.material.transmission
		{
			// Create a refracted ray
			///\todo Update `ray.origin` and `ray.dir`
			///\todo Set `ray.weight`
			///\todo Update `absorption`
		}

		//else, diffuse case
		{
			///\todo call `random_direction` to get a direction somewhere around the normal
			///\todo Update `ray.origin` and `ray.dir`
			///\todo Set `ray.weight`
			///\todo Update `absorption`
		}
	}
	return color;
}

void main() {
    
	vec2 tex_coords = gl_FragCoord.xy / i_window_size.xy;
	vec2 uv =  gl_FragCoord.xy - 0.5*i_window_size.xy;
    
	if(i_display)    
	{
		o_fragment_color = texture(i_texture,tex_coords);
	}    
	else
	{
		init();

		//seed for pseudorandom number, time and pixel dependent
		seed = i_global_time + i_window_size.y * gl_FragCoord.x / i_window_size.x + gl_FragCoord.y / i_window_size.y;
     
		//basis for defining the image plane
		vec3 cx = i_right;
		vec3 cy = i_up;   
		vec3 cz = i_dir;  

		//crude zooming by pressing right mouse button
		float f_dist = i_focal_dist + i_focal_dist*i_mouse_state.w; 
        
		vec3 color = vec3(0);
        
		for(int iter = 0; iter< MAX_SAMPLES; ++iter)
			color += pathtrace(Ray( i_position, normalize( uv.x*cx + uv.y*cy + cz*f_dist), 1.0 ));

		// gamma corrected output color, and blended over several frames (good for path tracer)
		o_fragment_color = (texture(i_texture,tex_coords)*i_frame_count + vec4( pow ( clamp(color.xyz/MAX_SAMPLES, 0., 1.), vec3(1./2.2)), 1.))/float(1+ i_frame_count); 
	}
    
}
