//
//  MatrixStack.hpp
//  AlephOne
//
//  Created by Dustin Wenz on 2/7/18.
//  Copyright © 2018 SDG Productions. All rights reserved.
//

#ifndef MatrixStack_hpp
#define MatrixStack_hpp

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_inverse.hpp>
#include <stdio.h>

#include "map.h"

#define STACK_MAX 10

//Cribbed from gl.h.
#define MS_MODELVIEW                      0x1700
#define MS_PROJECTION                     0x1701
#define MS_TEXTURE                        0x1702

#define MS_MODELVIEW_MATRIX               MS_MODELVIEW
#define MS_PROJECTION_MATRIX              MS_PROJECTION
#define MS_TEXTURE_MATRIX                 MS_TEXTURE

  //Our normal array must big enough to hold normals up to MAXIMUM_VERTICES_PER_WORLD_POLYGON and MAXIMUM_VERTICES_PER_POLYGON. Must be multiple of 3.
#define MAX_NORMAL_ELEMENTS (MAXIMUM_VERTICES_PER_POLYGON+4) * 3

class MatrixStack{
public:
  static MatrixStack* Instance();
  
  glm::mat4 (&activeStack())[STACK_MAX]; //Returns a reference to the active matrix stack.
  int activeStackIndex(); //Returns reference to top index of active stack.
  void setActiveStackIndex(int index); //Sets index for the top of active stack.

  void matrixMode(int newMode);
  glm::mat4 activeMatrix();
  void pushMatrix();
  void popMatrix();
  void getFloatv (GLenum pname, GLfloat* params);
  void getFloatvInverse (GLenum pname, GLfloat* params);
  void getFloatvModelviewProjection(GLfloat* params); //populates params with the product of modelview and projection


  void loadIdentity();
  void loadMatrixf(const GLfloat *m);
  void translatef(GLfloat x, GLfloat y, GLfloat z);
  void scalef (GLfloat x, GLfloat y, GLfloat z);
  void rotatef (GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
  void multMatrixf (const GLfloat *m);

  void transformVertex (GLfloat &x, GLfloat &y, GLfloat &z);
  
  void orthof (GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat zNear, GLfloat zFar);
  void frustumf (GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat zNear, GLfloat zFar);
  
  void color4f (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
  GLfloat* color();
  
    //Substitutes for glFogfv and glFogf. RGB channels go into the first three elements, and density is in the alpha channel.
  void fogColor3f (GLfloat red, GLfloat green, GLfloat blue);
  void fogDensity (GLfloat density);
  GLfloat* fog();
  
  void normal3f (GLfloat nx, GLfloat ny, GLfloat nz);
  GLfloat* normals();
  
  bool useFFP; //Flag indicating whether classic OpenGL operations should be performed as well.
  
private:
  MatrixStack(){useFFP=1; activeMode=MS_MODELVIEW; modelviewIndex=projectionIndex=textureIndex=0;};  // Private so that it can not be called
  MatrixStack(MatrixStack const&){};             // copy constructor is private
  MatrixStack& operator=(MatrixStack const&){};  // assignment operator is private
  static MatrixStack* m_pInstance;
  
  int activeMode;
  int modelviewIndex;
  int projectionIndex;
  int textureIndex;

  glm::mat4 modelviewStack[STACK_MAX];
  glm::mat4 projectionStack[STACK_MAX];
  glm::mat4 textureStack[STACK_MAX];
  GLfloat vertexColor[4];
  GLfloat fogColor[4];
  GLfloat normalArray[MAX_NORMAL_ELEMENTS];
};



#endif /* MatrixStack_hpp */
