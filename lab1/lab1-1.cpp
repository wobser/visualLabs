#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include <cstdlib>  
#include <iostream>

static void error_callback(int error, const char* description)
{
    std::cerr << description;
}

int main(int argc, char const *argv[])
{
	// Start GL context and O/S window using the GLFW helper library  
	glfwSetErrorCallback(error_callback);
	if( !glfwInit() )
		exit(EXIT_FAILURE);
  GLFWwindow* window = glfwCreateWindow (20, 20, "Hello OpenGL", NULL, NULL);
  
  if (!window) {
        glfwTerminate();
        exit(EXIT_FAILURE);
  }
  glfwMakeContextCurrent (window);

  // Start GLEW extension handler (after this we can call OpenGL functions)
  glewExperimental = GL_TRUE;
  glewInit ();

  // Get version info
  const GLubyte* renderer = glGetString(GL_RENDERER);
  const GLubyte* version = glGetString(GL_VERSION);
  std::cout << "Renderer:\n" << renderer << "\n\n";
  std::cout << "OpenGL version supported:\n"  << version << "\n\n";

  // Close GL context and any other GLFW resources
  glfwTerminate();
  exit(EXIT_SUCCESS);
}
