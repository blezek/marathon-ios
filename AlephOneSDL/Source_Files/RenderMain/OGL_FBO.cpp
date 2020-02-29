/*

	Copyright (C) 2015 and beyond by Jeremiah Morris
	and the "Aleph One" developers.
 
	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	This license is contained in the file "COPYING",
	which is included with this source code; it is available online at
	http://www.gnu.org/licenses/gpl.html
	
	Framebuffer Object utilities
*/

#include "cseries.h"
#include "OGL_FBO.h"

#ifdef HAVE_OPENGL

#include "OGL_Setup.h"
#include "OGL_Render.h"

//DCW
#include "AlephOneHelper.h"
#include "AlephOneAcceleration.hpp"
#include "MatrixStack.hpp"
#include "esUtil.h"
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>
#include "OGL_Shader.h"

std::vector<FBO *> FBO::active_chain;

FBO::FBO(GLuint w, GLuint h, bool srgb) : _h(h), _w(w), _srgb(srgb) {
  setup(w, h, srgb);
}

void FBO::setup(GLuint w, GLuint h, bool srgb) {
  
  _h = h; _w = w; _srgb = srgb;
  
  //DCW do nothing if not valid size. Call again later to initialize.
  if( w == 0 && h == 0) {
    return;
  }
  
  //DCW try to clear the shitstorm of errors from all the preceding  glEnableClientState() calls in ES 2.0 mode
  glGetError();
  glGetError();
  glGetError();
  glPushGroupMarkerEXT(0, "FBO Setup");
  
  glGenFramebuffers(1, &_fbo);
  glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
  
  //Create texture and attach it to framebuffer's color attachment point
  AOA::genTextures(1, &texID);
  AOA::bindTexture(GL_TEXTURE_2D, texID); //DCW was GL_TEXTURE_RECTANGE
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);  //DCW
  // glTexImage2D(GL_TEXTURE_2D, 0, srgb ? GL_SRGB : GL_RGB8, _w, _h, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);//DCW was GL_TEXTURE_RECTANGLE
  //DCW srgb support is completely untested by me
  AOA::texImage2D(GL_TEXTURE_2D, 0, srgb ? GL_SRGB : GL_RGBA, _w, _h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);//DCW was GL_TEXTURE_RECTANGLE, changed GL_RGB to GL_RGBA
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texID, 0); //DCW was GL_TEXTURE_RECTANGLE
  
  //Generate depth buffer
  glGenRenderbuffers(1, &_depthBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _w, _h);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
  //glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer); printGLError(__PRETTY_FUNCTION__);
  
  //dcw shit test bgfx sssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
  
  //glBindFramebuffer(GL_FRAMEBUFFER, 0);
  bindDrawable();
  
  glPopGroupMarkerEXT();
}

void FBO::activate(bool clear) {
	if (!active_chain.size() || active_chain.back() != this) {
		active_chain.push_back(this);
    
    glGetError();
    glBindFramebuffer(GL_FRAMEBUFFER, _fbo); printGLError(__PRETTY_FUNCTION__); //DCW test moving this here, otherwise this function appears to not work.

    AOA::bindTexture(GL_TEXTURE_2D, texID);  printGLError(__PRETTY_FUNCTION__);//DCW was GL_TEXTURE_RECTANGE
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);   printGLError(__PRETTY_FUNCTION__);//Apple advice
    AOA::texImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _w, _h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL); printGLError(__PRETTY_FUNCTION__);//DCW was GL_TEXTURE_RECTANGLE
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texID, 0);  printGLError(__PRETTY_FUNCTION__);//DCW was GL_TEXTURE_RECTANGLE
    
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);  printGLError(__PRETTY_FUNCTION__);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _w, _h);  printGLError(__PRETTY_FUNCTION__);//DCW was GL_DEPTH_COMPONENT
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
    //glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
    
    //glActiveTexture(GL_TEXTURE0);//DCW test
    //glBindFramebuffer(GL_FRAMEBUFFER, _fbo); printGLError(__PRETTY_FUNCTION__); //DCW This seems to be the wrong place for this.
    
		// DJB OpenGL glPushAttrib(GL_VIEWPORT_BIT);
    
    //DCW Track active frame and render buffers for debugging
    /*GLint lastFramebuffer, lastRenderbuffer, texture;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &lastFramebuffer);
    glGetIntegerv(GL_RENDERBUFFER_BINDING, &lastRenderbuffer);
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &texture);*/
    
		glViewport(0, 0, _w, _h);
		if (_srgb)
			glEnable(GL_FRAMEBUFFER_SRGB);
		else
			glDisable(GL_FRAMEBUFFER_SRGB);
		if (clear)
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //DCW shit test
    //glClearColor(0,0,1, .5);
    //if (texID !=102 ) glClearColor(0,0,1, .5);
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}
}

void FBO::deactivate() {
	if (active_chain.size() && active_chain.back() == this) {
		active_chain.pop_back();
		// DJB OpenGL glPopAttrib();
		
		GLuint prev_fbo = 0;
		bool prev_srgb = Using_sRGB;
		if (active_chain.size()) {
			prev_fbo = active_chain.back()->_fbo;
			prev_srgb = active_chain.back()->_srgb;
		}
		glBindFramebuffer(GL_FRAMEBUFFER, prev_fbo);
    
    //DCW binding to framebuffer 0 doesn't switch to the on-screen buffer on mobile.
    //Instead, call this convneience function to do something more likely to work.
    if (prev_fbo == 0) {
      bindDrawable();
    }
    
		if (prev_srgb && !useShaderRenderer())
			glEnable(GL_FRAMEBUFFER_SRGB);
		else
			glDisable(GL_FRAMEBUFFER_SRGB);
	}
}

void FBO::draw() {
  glPushGroupMarkerEXT(0, "FBO Binding texture");
  
	AOA::bindTexture(GL_TEXTURE_2D, texID);
  glPopGroupMarkerEXT();
  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glPushGroupMarkerEXT(0, "Shader render draw texture to screen test");
	//Deprecated glEnable(GL_TEXTURE_2D);

  //OGL_RenderTexturedRect(0, 0, _w, _h, 0, _h, _w, 0);
  
    //DCW if there is a shader already active, draw the quad using that. Otherwise, draw with the default shader.
  if (lastEnabledShader()) {
    DrawQuadWithActiveShader(0, 0, _w, _h, 0, _h, _w, 0);
  } else {
    OGL_RenderTexturedRect(0, 0, _w, _h, 0, 1.0, 1.0, 0); //DCW; uses normalized texture coordinates
  }
	//Deprecated glDisable(GL_TEXTURE_2D); //DCW was GL_TEXTURE_RECTANGLE
  glPopGroupMarkerEXT();
}

void FBO::DrawQuadWithActiveShader(float x, float y, float w, float h, float tleft, float ttop, float tright, float tbottom)
{
  GLfloat modelMatrix[16], modelProjection[16], modelMatrixInverse[16], textureMatrix[16], media6[4];
  
  Shader *theShader = lastEnabledShader();
  
  MatrixStack::Instance()->getFloatv(MS_MODELVIEW, modelMatrix);
  MatrixStack::Instance()->getFloatvInverse(MS_MODELVIEW, modelMatrixInverse);
  MatrixStack::Instance()->getFloatv(MS_TEXTURE, textureMatrix);
  MatrixStack::Instance()->getFloatvModelviewProjection(modelProjection);
  
  theShader->setMatrix4(Shader::U_MS_ModelViewMatrix, modelMatrix);
  theShader->setMatrix4(Shader::U_MS_ModelViewProjectionMatrix, modelProjection);
  theShader->setMatrix4(Shader::U_MS_ModelViewMatrixInverse, modelMatrixInverse);
  theShader->setMatrix4(Shader::U_MS_TextureMatrix, textureMatrix);
  theShader->setVec4(Shader::U_MS_Color, MatrixStack::Instance()->color());
  
  GLfloat vVertices[12] = { x, y, 0,
    x + w, y, 0,
    x + w, y + h, 0,
    x, y + h, 0};
  
  GLfloat texCoords[8] = { tleft, ttop, tright, ttop, tright, tbottom, tleft, tbottom };
  
  GLubyte indices[] =   {0,1,2,
    0,2,3};
  
  glVertexAttribPointer(Shader::ATTRIB_TEXCOORDS, 2, GL_FLOAT, 0, 0, texCoords);
  glEnableVertexAttribArray(Shader::ATTRIB_TEXCOORDS);
  
  glVertexAttribPointer(Shader::ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, vVertices);
  glEnableVertexAttribArray(Shader::ATTRIB_VERTEX);
  
  glPushGroupMarkerEXT(0, "DrawQuadWithActiveShader");
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, indices);
  glPopGroupMarkerEXT();
  
  glDisableVertexAttribArray(0);
}

void FBO::prepare_drawing_mode(bool blend) {
  /*glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();*/
	
  MatrixStack::Instance()->matrixMode(MS_PROJECTION);
  MatrixStack::Instance()->pushMatrix();
  MatrixStack::Instance()->loadIdentity();
  MatrixStack::Instance()->matrixMode(MS_MODELVIEW);
  MatrixStack::Instance()->pushMatrix();
  MatrixStack::Instance()->loadIdentity();
  
	glDisable(GL_DEPTH_TEST);
	if (!blend)
		glDisable(GL_BLEND);
	
  //DCW
  /*glOrthof(0, _w, _h, 0, -1, 1);
	//glOrtho(0, _w, _h, 0, -1, 1);
	glColor4f(1.0, 1.0, 1.0, 1.0);*/
  MatrixStack::Instance()->orthof(0, _w, _h, 0, -1, 1);
  MatrixStack::Instance()->color4f(1.0, 1.0, 1.0, 1.0);
}

void FBO::reset_drawing_mode() {
	glEnable(GL_BLEND);
	glEnable(GL_DEPTH_TEST);
	/*glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();*/
  MatrixStack::Instance()->matrixMode(MS_MODELVIEW);
  MatrixStack::Instance()->popMatrix();
  MatrixStack::Instance()->matrixMode(MS_PROJECTION);
  MatrixStack::Instance()->popMatrix();
}

void FBO::draw_full(bool blend) {
  glPushGroupMarkerEXT(0, "FBO Draw");
	prepare_drawing_mode(blend);
	draw();
	reset_drawing_mode();
  glPopGroupMarkerEXT();
}

FBO::~FBO() {
	glDeleteFramebuffers(1, &_fbo);
	glDeleteRenderbuffers(1, &_depthBuffer);
}


void FBOSwapper::activate() {
	if (active)
		return;

	if (draw_to_first)
		first.activate(clear_on_activate);
	else
		second.activate(clear_on_activate);
	active = true;
	clear_on_activate = false;
}

void FBOSwapper::deactivate() {
	if (!active)
		return;
	if (draw_to_first)
		first.deactivate();
	else
		second.deactivate();
	active = false;
}

void FBOSwapper::swap() {
	deactivate();
	draw_to_first = !draw_to_first;
	clear_on_activate = true;
}

void FBOSwapper::draw(bool blend) {
	current_contents().draw_full(blend);
}

void FBOSwapper::filter(bool blend) {
	activate();
	draw(blend);
	swap();
}

void FBOSwapper::copy(FBO& other, bool srgb) {
	clear_on_activate = true;
	activate();
	other.draw_full(false);
	swap();
}

void FBOSwapper::blend(FBO& other, bool srgb) {
	activate();
	if (!srgb)
		glDisable(GL_FRAMEBUFFER_SRGB);
	else
		glEnable(GL_FRAMEBUFFER_SRGB);
	other.draw_full(true);
	deactivate();
}

void FBOSwapper::blend_multisample(FBO& other) {
	swap();
	activate();
	
	// set up FBO passed in as texture #1
	glActiveTexture(GL_TEXTURE1);
	AOA::bindTexture(GL_TEXTURE_2D, other.texID); //DCW was GL_TEXTURE_RECTANGLE
  
	//Deprecated glEnable(GL_TEXTURE_2D); //DCW was GL_TEXTURE_RECTANGLE
	glActiveTexture(GL_TEXTURE0);
	
	//Deprecated glClientActiveTexture(GL_TEXTURE1);
	//Deprecated glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  GLint multi_coordinates[8] = { 0, static_cast<GLint>(other._h), static_cast<GLint>(other._w), static_cast<GLint>(other._h), static_cast<GLint>(other._w), 0, 0, 0 };
  glTexCoordPointer(2, GL_INT, 0, multi_coordinates);
	//Deprecated glClientActiveTexture(GL_TEXTURE0);
	
	draw(true);
	
	// tear down multitexture stuff
	glActiveTexture(GL_TEXTURE1);
	//Deprecated glDisable(GL_TEXTURE_2D); //DCW was GL_TEXTURE_RECTANGLE
	glActiveTexture(GL_TEXTURE0);
	
	//Deprecated glClientActiveTexture(GL_TEXTURE1);
	//Deprecated glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	//Deprecated glClientActiveTexture(GL_TEXTURE0);
	
	deactivate();
}

#endif
