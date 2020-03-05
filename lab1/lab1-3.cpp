// Copy lab1-2.cpp here, but make sure the file names below are updated.


#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include <cmath>
#include <cstdlib>  
#include <iostream>
#include "readfile.hpp"

#define GLM_FORCE_RADIANS
#include <glm/vec3.hpp> // glm::vec3
#include <glm/vec4.hpp> // glm::vec4
#include <glm/mat4x4.hpp> // glm::mat4
#include <glm/gtc/matrix_transform.hpp> // glm::translate, glm::rotate, glm::scale, glm::perspective
#include <glm/gtc/type_ptr.hpp> //glm::value_ptr
#include <glm/ext.hpp> // to_string

glm::vec3 g_rotation;

/*std::string vertex_shader_file =
"../lab1-2_vs.glsl";
std::string fragment_shader_file =
"../lab1-2_fs.glsl";
*/

std::string vertex_shader_file =
"../lab1/lab1-3_vs.glsl";
std::string fragment_shader_file =
"../lab1-3_fs.glsl";

// Helper function to tell you what went wrong if you have a syntax error in the shader program
void checkShaderCompileError(GLint shaderID)
{
	GLint isCompiled = 0;
	glGetShaderiv(shaderID, GL_COMPILE_STATUS, &isCompiled);

	if (isCompiled == GL_FALSE)
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
	{
		glfwSetWindowShouldClose(window, GL_TRUE);
	}

	if ((key == GLFW_KEY_R) && action == GLFW_PRESS)
	{
		std::cout << "Reloading " << vertex_shader_file << " and " << fragment_shader_file << "\n";
		// Reload shader on the fly when pressing 'r'
		std::string vertex_shader_str = readFile(vertex_shader_file.c_str());
		std::string fragment_shader_str = readFile(fragment_shader_file.c_str());
		const char* vertex_shader_src = vertex_shader_str.c_str();
		const char* fragment_shader_src = fragment_shader_str.c_str();

		GLuint vs = glCreateShader(GL_VERTEX_SHADER);
		glShaderSource(vs, 1, &vertex_shader_src, NULL);
		glCompileShader(vs);
		checkShaderCompileError(vs);

		GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);
		glShaderSource(fs, 1, &fragment_shader_src, NULL);
		glCompileShader(fs);
		checkShaderCompileError(fs);

		GLuint shader_program = glCreateProgram();
		glAttachShader(shader_program, fs);
		glAttachShader(shader_program, vs);
		glLinkProgram(shader_program);
		glDeleteShader(vs);
		glDeleteShader(fs);

		glUseProgram(shader_program);
	}

	if ((key == GLFW_KEY_RIGHT) && ((action == GLFW_PRESS) || action == GLFW_REPEAT))
		g_rotation.x += 0.2;

	if ((key == GLFW_KEY_LEFT) && ((action == GLFW_PRESS) || action == GLFW_REPEAT))
		g_rotation.x -= 0.2;

	if ((key == GLFW_KEY_UP) && ((action == GLFW_PRESS) || action == GLFW_REPEAT))
		g_rotation.y += 0.2;

	if ((key == GLFW_KEY_DOWN) && ((action == GLFW_PRESS) || action == GLFW_REPEAT))
		g_rotation.y -= 0.2;

}


int main(int argc, char const* argv[])
{
	// Start GL context and O/S window using the GLFW helper library  
	glfwSetErrorCallback(error_callback);
	if (!glfwInit())
		exit(EXIT_FAILURE);

	// Window size
	int w_width = 800;
	int w_height = 600;

	// Create a window where we can draw
	GLFWwindow* window = glfwCreateWindow(w_width, w_height, "SimVis Lab 1", NULL, NULL);
	glfwSetKeyCallback(window, key_callback);
	glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
	if (!window) {
		glfwTerminate();
		exit(EXIT_FAILURE);
	}
	glfwMakeContextCurrent(window);

	// Start GLEW extension handler (after this we can call OpenGL functions)
	glewExperimental = GL_TRUE;
	glewInit();

	// Tell GL to only draw onto a pixel if the shape is closer to the viewer
	glEnable(GL_DEPTH_TEST); // enable depth-testing
	glDepthFunc(GL_LESS);    // smaller value are "closer"

	// Initiate geometry:
	float positions[] = {
	  -0.5,-0.5,0.0,
	  0.5,-0.5,0.0,
	  0.0,0.5,0.0
	  ///\todo INSERT VERTEX POSITIONS HERE
	};
	int num_vertices = 3; ///\todo SET NUMBER OF VERTICES

	unsigned short faces[] = { 0,1,2
		///\todo INSERT FACE INDICES HERE
	};
	///\todo SET NUMBER OF FACES AND INDICES
	int num_faces = 1;
	int num_indices = 3;

	// Vertex Array Object that keeps track of what to draw:
	GLuint vao = 0;
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);

	// Vertex Buffer Object that keeps the data needed for all vertices
	GLuint vbo = 0;
	glGenBuffers(1, &vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	// Copy the vertex data in 'positions' to this VBO
	glBufferData(GL_ARRAY_BUFFER, num_vertices * 3 * sizeof(float), positions, GL_STATIC_DRAW);
	// Position will be attribute #0. Tell GPU in what order the data is stored in the VBO:
	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);

	// Element Buffer Object (or index buffer), to keep track of which vertices make triangles
	GLuint ebo = 0;
	glGenBuffers(1, &ebo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
	// Copy the index data in 'faces' to this EBO:
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, num_indices * sizeof(unsigned short), faces, GL_STATIC_DRAW);

	// Read source code of shader programs from external files
	std::string vertex_shader_str = readFile(vertex_shader_file.c_str());
	std::string fragment_shader_str = readFile(fragment_shader_file.c_str());
	const char* vertex_shader_src = vertex_shader_str.c_str();
	const char* fragment_shader_src = fragment_shader_str.c_str();

	// Compile the shaders
	GLuint vs = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vs, 1, &vertex_shader_src, NULL);
	glCompileShader(vs);
	checkShaderCompileError(vs);

	GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fs, 1, &fragment_shader_src, NULL);
	glCompileShader(fs);
	checkShaderCompileError(fs);

	// Link the shaders
	GLuint shader_program = glCreateProgram();
	glAttachShader(shader_program, fs);
	glAttachShader(shader_program, vs);
	glLinkProgram(shader_program);
	glDeleteShader(vs);
	glDeleteShader(fs);

	glUseProgram(shader_program);

	// Setup done. Entering main draw loop.
	while (!glfwWindowShouldClose(window))
	{
		// Update other events like input handling 
		glfwPollEvents();

		// Clear the drawing surface
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		// Draw to frame buffer
		glDrawElements(GL_TRIANGLES, num_indices, GL_UNSIGNED_SHORT, NULL);
		// Switch window display to the newly updated frame buffer 
		glfwSwapBuffers(window);
	}

	// Close GL context and any other GLFW resources
	glfwTerminate();
	exit(EXIT_SUCCESS);
}



