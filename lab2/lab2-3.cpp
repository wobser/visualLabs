#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include <cmath>
#include <cstdlib>  
#include <iostream>
#include "readfile.hpp"
#include <array>

#define GLM_FORCE_RADIANS
#include <glm/vec3.hpp> // glm::vec3
#include <glm/vec4.hpp> // glm::vec4
#include <glm/mat4x4.hpp> // glm::mat4
#include <glm/gtc/matrix_transform.hpp> // glm::translate, glm::rotate, glm::scale, glm::perspective
#include <glm/gtc/type_ptr.hpp> //glm::value_ptr
#include <glm/ext.hpp> // to_string

glm::vec3 g_rotation;

#define TINYOBJLOADER_IMPLEMENTATION // define this in only *one* .cc
#include "tiny_obj_loader.h"


std::string vertex_shader_file =
	"../lab2_vs.glsl";
std::string fragment_shader_file =
	"../lab2-3_fs.glsl";


// Helper function to tell you what went wrong if you have a syntax error in the shader program
void checkShaderCompileError(GLint shaderID)
{
  GLint isCompiled = 0;
  glGetShaderiv(shaderID, GL_COMPILE_STATUS, &isCompiled);
 
  if(isCompiled == GL_FALSE)
  {
    GLint maxLength = 0;
    glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, &maxLength);

    // The maxLength includes the NULL character
    std::string errorLog;
    errorLog.resize(maxLength);
    glGetShaderInfoLog(shaderID, maxLength, &maxLength, &errorLog[0]);

    std::cout << "shader compilation failed:" << std::endl;
    std::cout << errorLog << std::endl;
    return;
  }
  else
    std::cout << "shader compilation success." << std::endl;
    
  return;
}


static void error_callback(int error, const char* description)
{
    std::cerr << description;
}

static void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
	glViewport(0, 0, width, height);
}

static void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods)
{
    if ((key == GLFW_KEY_ESCAPE || key == GLFW_KEY_Q) && action == GLFW_PRESS)
        glfwSetWindowShouldClose(window, GL_TRUE);
    
    if ((key == GLFW_KEY_R) && action == GLFW_PRESS)
    {
	    std::cout << "Reloading " << vertex_shader_file << " and " << fragment_shader_file << "\n";
	    // Reload shader on the fly when pressing 'r'
	    std::string vertex_shader_str = readFile( vertex_shader_file.c_str() );
	    std::string fragment_shader_str = readFile( fragment_shader_file.c_str() );
	    const char *vertex_shader_src = vertex_shader_str.c_str();
	    const char *fragment_shader_src = fragment_shader_str.c_str();

	    GLuint vs = glCreateShader (GL_VERTEX_SHADER);
	    glShaderSource (vs, 1, &vertex_shader_src, NULL);
	    glCompileShader (vs);
	    checkShaderCompileError(vs);

	    GLuint fs = glCreateShader (GL_FRAGMENT_SHADER);
	    glShaderSource (fs, 1, &fragment_shader_src, NULL);
	    glCompileShader (fs);
	    checkShaderCompileError(fs);

	    GLuint shader_program = glCreateProgram ();
	    glAttachShader (shader_program, fs);
	    glAttachShader (shader_program, vs);
	    glLinkProgram (shader_program);
	    glDeleteShader(vs);
	    glDeleteShader(fs);

	    glUseProgram (shader_program);
    } 

    if ((key == GLFW_KEY_RIGHT) && ( (action == GLFW_PRESS) || action==GLFW_REPEAT) ) 
      g_rotation.x += 0.2; 
  
    if ((key == GLFW_KEY_LEFT) && ( (action == GLFW_PRESS) || action==GLFW_REPEAT) ) 
      g_rotation.x -= 0.2; 
    
    if ((key == GLFW_KEY_UP) && ( (action == GLFW_PRESS) || action==GLFW_REPEAT) ) 
      g_rotation.y += 0.2; 
  
    if ((key == GLFW_KEY_DOWN) && ( (action == GLFW_PRESS) || action==GLFW_REPEAT) ) 
      g_rotation.y -= 0.2; 

}


int main(int argc, char const *argv[])
{
  // Start GL context and O/S window using the GLFW helper library  
  glfwSetErrorCallback(error_callback);
  if( !glfwInit() )
    exit(EXIT_FAILURE);

  // Window size
  int w_width = 1600;
  int w_height = 1200;

  // Create a window where we can draw
  GLFWwindow* window = glfwCreateWindow (w_width, w_height, "SimVis Lab 1", NULL, NULL);
  glfwSetKeyCallback(window, key_callback);
  glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);	
  if (!window) {
        glfwTerminate();
        exit(EXIT_FAILURE);
	}
  glfwMakeContextCurrent (window);
                                  
  // Start GLEW extension handler (after this we can call OpenGL functions)
  glewExperimental = GL_TRUE;
  glewInit ();

  // Tell GL to only draw onto a pixel if the shape is closer to the viewer
  glEnable (GL_DEPTH_TEST); // enable depth-testing
  glDepthFunc (GL_LESS);    // smaller value are "closer"


  //-------------------------------------------------------------------------//
  // Load bunny

  std::string inputfile =
	  "../../common/data/bunny.obj";
  std::vector<tinyobj::shape_t> shapes;
  std::vector<tinyobj::material_t> materials;

  std::string err;
  int flags = 0; // see load_flags_t enum for more information.
  bool ret = tinyobj::LoadObj(shapes, materials, err, inputfile.c_str(), 0, flags);

  if (!err.empty()) { // `err` may contain warning message.
	  std::cerr << err << std::endl;
  }

  if (!ret) {
	  exit(1);
  }
  else
  {
	  std::cout << "Loaded " << inputfile
	            << " ("
	            << shapes.size() << " shapes"
	            << ")"
	            << "\n";
  }

  // Resize obj (bunny will look too small otherwise)
  for (int i = 0; i < shapes[0].mesh.positions.size(); ++i)
  {
	  shapes[0].mesh.positions[i] /= 0.1;
	  //shapes[0].mesh.positions[i] /= 100.0; 
  }

  // Some additional error checking for the loaded model
  int old_ngon = 0;
  for (size_t i = 0; i < shapes.size(); i++) {
	  size_t indexOffset = 0;
	  for (size_t n = 0; n < shapes[i].mesh.num_vertices.size(); n++) {
		  int ngon = shapes[i].mesh.num_vertices[n];
		  if (ngon != old_ngon && old_ngon != 0)
			  std::cerr << "Heterogeneous mesh: " << ngon << " != " << old_ngon << "\n";
		  old_ngon = ngon;
	  }
  }

  //-------------------------------------------------------------------------//
  // Set up light sources

  int light_count = 0; 
  std::vector< float > light_position;
  std::vector< float > light_colour;
  std::array<float,4> position;
  std::array<float,4> colour;

  // First light source
  position = {0.0f, 0.0f, 5.0f, 1.0f};
  light_position.insert(light_position.end(), position.begin(), position.end());
  colour = {1.0f, 1.0f, 1.0f, 1.0f};
  light_colour.insert(light_colour.end(), colour.begin(), colour.end());
  ++light_count;

  // If you want to, you can add more light sources here

  
  //-------------------------------------------------------------------------//
  // Set up VAO
  GLuint vao = 0;
  glGenVertexArrays (1, &vao);
  glBindVertexArray (vao);

  // Set up attribute #0 (positions, read from file)
  glEnableVertexAttribArray (0);
  GLuint vbo = 0;
  glGenBuffers (1, &vbo);
  glBindBuffer (GL_ARRAY_BUFFER, vbo);
  glBufferData (GL_ARRAY_BUFFER, shapes[0].mesh.positions.size() * sizeof (float), &(shapes[0].mesh.positions[0]), GL_STATIC_DRAW);
  glVertexAttribPointer (0, 3, GL_FLOAT, GL_FALSE, 0, NULL);

  // Set up attribute #1 (normals, read from file)
  glEnableVertexAttribArray (1);
  GLuint nbo = 0; // Put them in a VBO of their own (called `nbo` here)
  glGenBuffers (1, &nbo);
  glBindBuffer (GL_ARRAY_BUFFER, nbo);
  glBufferData (GL_ARRAY_BUFFER, sizeof (float)*shapes[0].mesh.normals.size(), &(shapes[0].mesh.normals[0]), GL_STATIC_DRAW);
  glVertexAttribPointer (1, 3, GL_FLOAT, GL_FALSE, 0, NULL);

  // Set up EBO with vertex indices, read from file
  GLuint ebo = 0; 
  glGenBuffers(1, &ebo);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, shapes[0].mesh.indices.size() *sizeof(unsigned int), &(shapes[0].mesh.indices[0]), GL_STATIC_DRAW);

  // Read source code of shader programs from external files
  std::string vertex_shader_str = readFile( vertex_shader_file.c_str() );
  std::string fragment_shader_str = readFile( fragment_shader_file.c_str() );
  const char *vertex_shader_src = vertex_shader_str.c_str();
  const char *fragment_shader_src = fragment_shader_str.c_str();

  // Compile the shaders
  GLuint vs = glCreateShader( GL_VERTEX_SHADER );
  glShaderSource( vs, 1, &vertex_shader_src, NULL );
  glCompileShader( vs );
  checkShaderCompileError( vs );

  GLuint fs = glCreateShader( GL_FRAGMENT_SHADER );
  glShaderSource( fs, 1, &fragment_shader_src, NULL );
  glCompileShader( fs );
  checkShaderCompileError( fs );

  // Link the shaders
  GLuint shader_program = glCreateProgram();
  glAttachShader( shader_program, fs );
  glAttachShader( shader_program, vs );
  glLinkProgram( shader_program );
  glDeleteShader( vs );
  glDeleteShader( fs );

  glUseProgram (shader_program);

  // Setup done. Entering main draw loop.
  while (!glfwWindowShouldClose (window)) 
  {
	  // Update ratios if window size changes
    glfwGetFramebufferSize(window, &w_width , &w_height );

    // Set up projection matrix
    const float n = 1.0f;   // near clip distance
    const float f = 100.0f; // far clip distance
    glm::mat4 Projection = glm::perspective(glm::radians(90.0f), float(w_width)/w_height, n, f);

    glm::mat4 Model = glm::mat4(1.0f); // identity matrix
	//glm::mat4 translate = glm::translate(glm::mat4(1.f), glm::vec3(0.f, -1.f, -0.5f));
	//Model = Model * translate;
    glm::vec3 Rotate = g_rotation;
    Model = glm::rotate( Model, Rotate.y, glm::vec3(-1.0f, 0.0f, 0.0f));
    Model = glm::rotate( Model, Rotate.x, glm::vec3(0.0f, 1.0f, 0.0f));
	Model = glm::translate(Model, glm::vec3(0, -1, 0));

    glm::mat4 View = glm::mat4(1.0f); // identity matrix
    View = glm::translate( View, glm::vec3( 0, 0, 2 )); // Camera is at z=2
    View = glm::inverse( View );
   
    glm::mat4 MVP = Projection * View * Model;
    glm::mat4 MV = View * Model;

    // Set the 'modelViewProjection' uniform variable in the shader program 
    glUniformMatrix4fv(glGetUniformLocation(shader_program ,"modelViewProjectionMatrix"), 1, GL_FALSE, glm::value_ptr(MVP));
    // Also set the MV matrix separately
    glUniformMatrix4fv(glGetUniformLocation(shader_program ,"modelViewMatrix"), 1, GL_FALSE, glm::value_ptr(MV));

    // Pass lights to shader
    glUniform1i(glGetUniformLocation(shader_program ,"light_count"), light_count);
    glUniform4fv(glGetUniformLocation(shader_program ,"light_position"), light_position.size(), &light_position[0]);
    glUniform4fv(glGetUniformLocation(shader_program ,"light_colour"), light_colour.size(), &light_colour[0]); 
    
    // Update other events like input handling 
    glfwPollEvents ();
    
    // Clear the drawing surface
    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // Draw to frame buffer
    glDrawElements(GL_TRIANGLES, shapes[0].mesh.indices.size(), GL_UNSIGNED_INT, NULL);
    // Switch window display to the newly updated frame buffer 
    glfwSwapBuffers (window);
  }

  // Close GL context and any other GLFW resources
  glfwTerminate();
  exit(EXIT_SUCCESS);
}

