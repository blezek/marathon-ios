/*
 *  Rasterizer_Shader.cpp
 *  Created by Clemens Unterkofler on 1/20/09.
 *  for Aleph One
 *
 *  http://www.gnu.org/licenses/gpl.html
 */

#include "OGL_Headers.h"

#include <iostream>

#include "Rasterizer_Shader.h"

#include "lightsource.h"
#include "media.h"
#include "player.h"
#include "weapons.h"
#include "AnimatedTextures.h"
#include "OGL_Faders.h"
#include "OGL_FBO.h"
#include "OGL_Textures.h"
#include "OGL_Shader.h"
#include "ChaseCam.h"
#include "preferences.h"
#include "fades.h"
#include "screen.h"

#include "MatrixStack.hpp"
#include "AlephOneHelper.h"

#define MAXIMUM_VERTICES_PER_WORLD_POLYGON (MAXIMUM_VERTICES_PER_POLYGON+4)

const GLfloat kViewBaseMatrix[16] = {
	0,	0,	-1,	0,
	1,	0,	0,	0,
	0,	1,	0,	0,
	0,	0,	0,	1
};

const GLfloat kViewBaseMatrixInverse[16] = {
	0,	1,	0,	0,
	0,	0,	1,	0,
	-1,	0,	0,	0,
	0,	0,	0,	1
};

void Rasterizer_Shader_Class::SetView(view_data& view) {
	OGL_SetView(view);

	if (view.screen_width != view_width || view.screen_height != view_height) {
		view_width = view.screen_width;
		view_height = view.screen_height;
		swapper.reset();
		swapper.reset(new FBOSwapper(view_width * MainScreenPixelScale(), view_height * MainScreenPixelScale(), false));
	}
  
	float aspect = view.screen_width / float(view.screen_height);
	float deg2rad = 8.0 * atan(1.0) / 360.0;
	float xtan, ytan;
	if (View_FOV_FixHorizontalNotVertical()) {
		xtan = tan(view.field_of_view * deg2rad / 2.0);
		ytan = xtan / aspect;
	} else {
		ytan = tan(view.field_of_view * deg2rad / 2.0) / 2.0;
		xtan = ytan * aspect;
	}
	
	// Adjust for view distortion during teleport effect
	ytan *= view.real_world_to_screen_y / double(view.world_to_screen_y);
	xtan *= view.real_world_to_screen_x / double(view.world_to_screen_x);

	if (!useShaderRenderer()) glMatrixMode(GL_PROJECTION);
  MatrixStack::Instance()->matrixMode(MS_PROJECTION);
	if (!useShaderRenderer()) glLoadIdentity();
  MatrixStack::Instance()->loadIdentity();
	float nearVal = 64.0;
	float farVal = 128.0 * 1024.0;
	float x = xtan * nearVal;
	float y = ytan * nearVal;
	if (!useShaderRenderer()) glFrustumf(-x, x, -y, y, nearVal, farVal);
  MatrixStack::Instance()->frustumf(-x, x, -y, y, nearVal, farVal);
  
	if (!useShaderRenderer()) glMatrixMode(GL_MODELVIEW);
  MatrixStack::Instance()->matrixMode(GL_MODELVIEW);
	double yaw = view.yaw * 360.0 / float(NUMBER_OF_ANGLES);
	double pitch = view.pitch * 360.0 / float(NUMBER_OF_ANGLES);
	pitch = (pitch > 180.0 ? pitch -360.0 : pitch);

	// setup a rotation matrix for the landscape texture shader
	// this aligns the landscapes to the center of the screen for standard
	// pitch ranges, so that they don't need to be stretched

	if (!useShaderRenderer()) glLoadIdentity();
  MatrixStack::Instance()->loadIdentity();
	if (!useShaderRenderer()) glTranslatef(view.origin.x, view.origin.y, view.origin.z);
  MatrixStack::Instance()->translatef(view.origin.x, view.origin.y, view.origin.z);
	if (!useShaderRenderer()) glRotatef(yaw, 0.0, 0.0, 1.0);
  MatrixStack::Instance()->rotatef(yaw, 0.0, 0.0, 1.0);
	if (!useShaderRenderer()) glRotatef(-pitch, 0.0, 1.0, 0.0);
  MatrixStack::Instance()->rotatef(-pitch, 0.0, 1.0, 0.0);
	if (!useShaderRenderer()) glMultMatrixf(kViewBaseMatrixInverse);
  MatrixStack::Instance()->multMatrixf(kViewBaseMatrixInverse);
  
	GLfloat landscapeInverseMatrix[16];
//	glGetFloatv(GL_MODELVIEW_MATRIX, landscapeInverseMatrix);
  MatrixStack::Instance()->getFloatv(MS_MODELVIEW_MATRIX, landscapeInverseMatrix);
  
	Shader *s;

	s = Shader::get(Shader::S_Landscape);
	s->enable();
	s->setMatrix4(Shader::U_LandscapeInverseMatrix, landscapeInverseMatrix);

	s = Shader::get(Shader::S_LandscapeBloom);
	s->enable();
	s->setMatrix4(Shader::U_LandscapeInverseMatrix, landscapeInverseMatrix);

	Shader::disable();

	// setup the normal view matrix

	if (!useShaderRenderer()) glLoadMatrixf(kViewBaseMatrix);
  MatrixStack::Instance()->loadMatrixf(kViewBaseMatrix);
	if (!useShaderRenderer()) glRotatef(pitch, 0.0, 1.0, 0.0);
  MatrixStack::Instance()->rotatef(pitch, 0.0, 1.0, 0.0);
//	apperently 'roll' is not what i think it is
//	rubicon sets it to some strange value
//	double roll = view.roll * 360.0 / float(NUMBER_OF_ANGLES);
//	glRotated(roll, 1.0, 0.0, 0.0);
	if (!useShaderRenderer()) glRotatef(-yaw, 0.0, 0.0, 1.0);
  MatrixStack::Instance()->rotatef(-yaw, 0.0, 0.0, 1.0);
	if (!useShaderRenderer()) glTranslatef(-view.origin.x, -view.origin.y, -view.origin.z);
  MatrixStack::Instance()->translatef(-view.origin.x, -view.origin.y, -view.origin.z);
}

void Rasterizer_Shader_Class::setupGL()
{
	view_width = 0;
	view_height = 0;
	swapper.reset();
	
	smear_the_void = false;
	OGL_ConfigureData& ConfigureData = Get_OGL_ConfigureData();
	if (!TEST_FLAG(ConfigureData.Flags,OGL_Flag_VoidColor))
		smear_the_void = true;
}

void Rasterizer_Shader_Class::Begin()
{
	Rasterizer_OGL_Class::Begin();
	swapper->activate();

  if (smear_the_void)
		swapper->current_contents().draw_full();
}

void Rasterizer_Shader_Class::End()
{
	swapper->deactivate();
	swapper->swap();

    //DCW shit test. To do this test, comment out the gamma filter below
  /*
  glPushGroupMarkerEXT(0, "Shader render texture test");
  GLuint framebuffer;
  GLuint texID = swapper->current_contents().texID;
  GLuint _w = swapper->current_contents()._w;
  GLuint _h = swapper->current_contents()._h;
  //Setup FBO
  printGLError(__PRETTY_FUNCTION__);
  glGenFramebuffers(1, &framebuffer);  printGLError(__PRETTY_FUNCTION__);
  glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);  printGLError(__PRETTY_FUNCTION__);
  
  //Setup texture target
  GLuint texture;
  glGenTextures(1, &texture);  printGLError(__PRETTY_FUNCTION__);
  //glBindTexture(GL_TEXTURE_2D, texture);  printGLError(__PRETTY_FUNCTION__);
  //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);  printGLError(__PRETTY_FUNCTION__);
  //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  _w, _h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);  printGLError(__PRETTY_FUNCTION__);
  //glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
  
  //Setup depth buffer
  GLuint depthRenderbuffer;
  glGenRenderbuffers(1, &depthRenderbuffer);   printGLError(__PRETTY_FUNCTION__);
  glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);  printGLError(__PRETTY_FUNCTION__);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _w, _h);  printGLError(__PRETTY_FUNCTION__);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer); printGLError(__PRETTY_FUNCTION__);
  GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
  if(status != GL_FRAMEBUFFER_COMPLETE) {
   
  }
  
    //DCW this chunk is similar to FBO::activate. Some calls are the same as above.
  glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);  printGLError(__PRETTY_FUNCTION__);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _w, _h);  printGLError(__PRETTY_FUNCTION__);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer); printGLError(__PRETTY_FUNCTION__);
  glBindTexture(GL_TEXTURE_2D, texture);  printGLError(__PRETTY_FUNCTION__);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);  printGLError(__PRETTY_FUNCTION__);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  _w, _h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);  printGLError(__PRETTY_FUNCTION__);
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
  glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);  printGLError(__PRETTY_FUNCTION__);
  
  glClearColor(0,0,1, .5);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
   printGLError(__PRETTY_FUNCTION__);
  Shader::drawDebugRect();printGLError(__PRETTY_FUNCTION__);
    //Re-bind texture to draw to screen. Maybe not needed.
  glBindTexture(GL_TEXTURE_2D, texture);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glPushGroupMarkerEXT(0, "Shader render draw texture to screen test");
  glEnable(GL_TEXTURE_2D);
  OGL_RenderTexturedRect(0, 0, _w, _h, 0, _h, _w, 0);
  glDisable(GL_TEXTURE_2D);
  glPopGroupMarkerEXT();
  glPopGroupMarkerEXT();
   */

  //DCW shit test
  float gamma_adj = get_actual_gamma_adjust(graphics_preferences->screen_mode.gamma_level);
	if (gamma_adj < 0.99f || gamma_adj > 1.01f) {
		Shader *s = Shader::get(Shader::S_Gamma);
		s->enable();
		s->setFloat(Shader::U_GammaAdjust, gamma_adj);
	}
  
	swapper->draw();
	Shader::disable();
  
  //dcw shit test
  //bindDrawable();
  
	SetForeground();
	SglColor3f(0, 0, 0); //DCW
  OGL_RenderFrame(0, 0, view_width, view_height, 1);
	
	Rasterizer_OGL_Class::End();
}

int Rasterizer_Shader_Class::Height()
{
  return view_height;
}

int Rasterizer_Shader_Class::Width()
{
  return view_width;
}
