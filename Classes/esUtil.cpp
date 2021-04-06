//
//  esUtil.c
//  AlephOne
//
//  Created by Dustin Wenz on 2/20/18.
//  Copyright © 2018 SDG Productions. All rights reserved.
//

#include "esUtil.h"

#include "MatrixStack.hpp"

#include "AlephOneAcceleration.hpp"

/*typedef struct
{
  // Handle to a program object GLuint programObject;
  GLuint programObject;
} UserData;*/

// uniform index
enum {
  SAMPLER,
  COLOR,
  NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// attribute index
enum {
  ATTRIB_VERTEX,
  ATTRIB_TEXCOORDS,
  NUM_ATTRIBUTES
};

  //Global object containing shaders for drawing a quad.
GLuint quadProgramObject;

///
// Create a shader object, load the shader source, and
// compile the shader.
//
GLuint LoadQuadShader(const char *shaderSrc, GLenum type)
{
  GLuint shader;
  GLint compiled;
  
  // Create the shader object
  shader = glCreateShader(type);
  
  if(shader == 0)
    return 0;
  
  // Load the shader source
  glShaderSource(shader, 1, &shaderSrc, NULL);
  
  // Compile the shader
  glCompileShader(shader);
  
  // Check the compile status
  glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
  
  if(!compiled)
  {
    GLint infoLen = 0;
    
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
    
    if(infoLen > 1)
    {
      char* infoLog = (char*) malloc(sizeof(char) * infoLen);
      
      glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
      printf("Error compiling shader:\n%s\n", infoLog);
      free(infoLog);
    }
    
    glDeleteShader(shader);
    return 0;
  }
  
  if(type == GL_VERTEX_SHADER) {
    
  }
  
  return shader;
  
}

///
// Initialize the shader and program object
//
int InitES2Quads()
{
    //Are we already initialized?
  if(quadProgramObject)
    return 1;
  
  const char vShaderStr[] =
  "attribute vec4 vPosition;   \n"
  "attribute vec2 vTexCoord;   \n"
  "varying vec2 textureUV;   \n"
  "void main()                 \n"
  "{                           \n"
  " gl_Position = vPosition;  \n"
      //Shift origin from center to lower-left corner.
      //Do this by doubling the size, and shifting down and left by -1.
 // " gl_Position.x = gl_Position.x * 2.0 - 1.0;  \n"
 // " gl_Position.y = gl_Position.y * 2.0 - 1.0;  \n"
  " textureUV = vTexCoord;\n"
  "}                           \n";
  
  const char fShaderStr[] =
  "precision highp float;\n"
  "varying highp vec2 textureUV; \n"
  "uniform sampler2D texture; \n"
  "uniform vec4 vColor;\n"
  "void main()                                \n"
  "{                                          \n"
  //"  gl_FragColor = vec4(1.0, 1.0, 1.0, .25); \n"
  "  gl_FragColor = texture2D(texture, textureUV) * vColor; \n"
  //"  gl_FragColor.r=1.0; \n"
  "}                                          \n";
  
  GLuint vertexShader;
  GLuint fragmentShader;

  GLint linked;
  
  // Load the vertex/fragment shaders
  vertexShader = LoadQuadShader(vShaderStr, GL_VERTEX_SHADER);
  fragmentShader = LoadQuadShader(fShaderStr, GL_FRAGMENT_SHADER);
  
  // Create the program object
  quadProgramObject = glCreateProgram();
  
  if(quadProgramObject == 0)
    return 0;
  
  glAttachShader(quadProgramObject, vertexShader);
  glAttachShader(quadProgramObject, fragmentShader);
  
  // Bind vPosition to enum attribute
  glBindAttribLocation(quadProgramObject, ATTRIB_VERTEX, "vPosition");
  glBindAttribLocation(quadProgramObject, ATTRIB_TEXCOORDS, "vTexCoord");

  // Link the program
  glLinkProgram(quadProgramObject);
  
  // Check the link status
  glGetProgramiv(quadProgramObject, GL_LINK_STATUS, &linked);
  
  if(!linked)
  {
    GLint infoLen = 0;
    
    glGetProgramiv(quadProgramObject, GL_INFO_LOG_LENGTH, &infoLen);
    
    if(infoLen > 1)
    {
      char* infoLog = (char*) malloc(sizeof(char) * infoLen);
      
      glGetProgramInfoLog(quadProgramObject, infoLen, NULL, infoLog);
      printf("Error linking program:\n%s\n", infoLog);
      
      free(infoLog);
    }
    
    glDeleteProgram(quadProgramObject);
    return 0;
  }
  
  // Get uniform locations
  uniforms[SAMPLER] = glGetUniformLocation(quadProgramObject, "texture");
  uniforms[COLOR] = glGetUniformLocation(quadProgramObject, "vColor");

  
  //glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
  return 1;
}

///
// Draw a triangle using the shader pair created in Init()
//
void DrawQuad(float x, float y, float w, float h, float tleft, float ttop, float tright, float tbottom)
{
    //Initialize if needed
  int result = InitES2Quads();
    
  //printf("Drawing Quad. x:%f, y:%f  w:%f, h:%f\n", x,y,w,h);
  GLint viewport[4];
  glGetIntegerv( GL_VIEWPORT, viewport );
  
  //printf("Drawing quad!\nr");
  GLfloat vVertices[12] = { x, y, 0,
                            x + w, y, 0,
                            x + w, y + h, 0,
                            x, y + h, 0};
 
  MatrixStack::Instance()->transformVertex(vVertices[0], vVertices[1], vVertices[2]);
  MatrixStack::Instance()->transformVertex(vVertices[3], vVertices[4], vVertices[5]);
  MatrixStack::Instance()->transformVertex(vVertices[6], vVertices[7], vVertices[8]);
  MatrixStack::Instance()->transformVertex(vVertices[9], vVertices[10], vVertices[11]);

  /*GLfloat vVertices[12] = { -.5, .5, 0,
    .5, .5, 0,
    .5, -.5, 0,
    -.5, -.5, 0};*/
    
  GLfloat texCoords[8] = { tleft, ttop, tright, ttop, tright, tbottom, tleft, tbottom };

  GLubyte indices[] =   {0,1,2,
                        0,2,3};
  
  // Use the program object
  glUseProgram(quadProgramObject);
  
  glUniform1i(uniforms[SAMPLER], 0);
  
  float *color = MatrixStack::Instance()->color();
  
  glUniform4f(uniforms[COLOR], color[0], color[1], color[2], color[3]);

  glVertexAttribPointer(ATTRIB_TEXCOORDS, 2, GL_FLOAT, 0, 0, texCoords);
  glEnableVertexAttribArray(ATTRIB_TEXCOORDS);

  
  // Load the vertex data
  glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, vVertices);
  glEnableVertexAttribArray(ATTRIB_VERTEX);

  glPushGroupMarkerEXT(0, "Draw ES Quad");
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, indices);
  glPopGroupMarkerEXT();
 
  //glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, vVerticesTest);
  //glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, indices);

  
  glDisableVertexAttribArray(0);
}

void bindDrawable()
{
  //Bind to on-screen drawable frame and render buffers.
  //These are usually, but not guaranteed to be 1.
  //THe correct way is to bind to the core animation drawable.
  glBindFramebuffer(GL_FRAMEBUFFER, 1);
  glBindRenderbuffer(GL_RENDERBUFFER, 1);

}
