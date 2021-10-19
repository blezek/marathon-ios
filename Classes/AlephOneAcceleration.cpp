//
//  AlephOneAcceleration.cpp
//  AlephOne
//
//  Created by Dustin Wenz on 2/17/20.
//  Copyright © 2020 SDG Productions. All rights reserved.
//

#include "AlephOneAcceleration.hpp"

#include "MatrixStack.hpp"
#include "AlephOneHelper.h"

#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>

#include "OGL_Shader.h"

#define AOA_MAX_FRAMEBUFFERS 64
#define AOA_MAX_TEXTURES 8192
//AOA_TEXTURE_UNITS **MUST** corelate with the number of sampler uniforms in the name list (texture0, texture1, etc).
#define AOA_TEXTURE_UNITS 4

typedef struct texture_slot {
  bool reserved;
  bool initialized;
  //bgfx::TextureHandle bgfxHandle;
} texture_slot;
texture_slot texture_slots[AOA_MAX_TEXTURES];
AOAint boundTextureSlotIndex; //Needed??
AOAint nextTextureSlotIndex;

typedef struct texture_unit {
  AOAuint textureID;
  //bgfx::TextureHandle *alternateTexture; //Use this handle (probably a fremabuffer texture) instead of textureID if set.
} texture_unit;
texture_unit texture_units[AOA_TEXTURE_UNITS];
AOAint activeTextureUnit;


typedef struct framebuffer_slot {
  //bgfx::FrameBufferHandle bgfxHandle;
  //bgfx::TextureHandle textures[2]; //Color and depth texture.
  bool initialized;
  
  AOAuint w, h;
  
  AOAuint OGLFBID; //Only used in OpenGL Mode
  AOAuint OGLTextureID; //Only used in OpenGL Mode
  AOAuint OGLRenderBufferID; //Only used in OpenGL Mode
} framebuffer_slot;
framebuffer_slot framebuffers[AOA_MAX_FRAMEBUFFERS];
AOAint boundFrameBuffer;

bool frameBufferReadyToDraw;
AOAint frameBufferToDraw = -1;

int drawsThisFrame;

float portX, portY, portW, portH;

bool uniformCreated[Shader::NUMBER_OF_UNIFORM_LOCATIONS];
bool uniformSet[Shader::NUMBER_OF_UNIFORM_LOCATIONS];

int activeProgram = -1; //-1 indicates no active program.

bool quad_inited, shaders_inited;

const void *texturePointer, *vertexPointer, *normalPointer;
int vertexPointerSize;
int vertexType;
int vertexStride;



AOA* AOA::m_pInstance = NULL;

AOA* AOA::Instance()
{
  if (!m_pInstance) {
    m_pInstance = new AOA;
    
  }
  return m_pInstance;
}

bool AOA::OGLIrrelevant(){
  return 0;//AOA::useBGFX();
}

void AOA::pushGroupMarker(AOAsizei length, const char *marker)
{
  glPushGroupMarkerEXT(length, marker);
}

void AOA::popGroupMarker(void)
{
    glPopGroupMarkerEXT();
}

void  AOA::clearColor (AOAfloat red, AOAfloat green, AOAfloat blue, AOAfloat alpha)
{
  glClearColor(red, green, blue, alpha);
}

void AOA::clear (uint32_t maskField)
{
  glClear(maskField);
}




void AOA::programFromNameIndex (AOAuint *_programObj, AOAuint nameIndex, Shader *shader)
{
  
    GLint linked;
    
    *_programObj = glCreateProgram();//DCW
    
    assert(!shader->_vert.empty());
      GLuint vertexShader = parseShader(shader->_vert.c_str(), GL_VERTEX_SHADER);
      assert(vertexShader);
      glAttachShader(*_programObj, vertexShader);
      glDeleteShader(vertexShader);

      assert(!shader->_frag.empty());
      GLuint fragmentShader = parseShader(shader->_frag.c_str(), GL_FRAGMENT_SHADER);
      assert(fragmentShader);
      glAttachShader(*_programObj, fragmentShader);
      glDeleteShader(fragmentShader);
      
      // DCW Bind enum attributes to program
      glBindAttribLocation(*_programObj, Shader::ATTRIB_VERTEX, "vPosition");
      glBindAttribLocation(*_programObj, Shader::ATTRIB_TEXCOORDS, "vTexCoord");
      glBindAttribLocation(*_programObj, Shader::ATTRIB_NORMAL, "vNormal");
      glBindAttribLocation(*_programObj, Shader::ATTRIB_COLOR, "vColor");
      glBindAttribLocation(*_programObj, Shader::ATTRIB_TEXCOORDS4, "vTexCoords4");
      glBindAttribLocation(*_programObj, Shader::ATTRIB_CLIPPLANE0, "vClipPlane0");
      glBindAttribLocation(*_programObj, Shader::ATTRIB_CLIPPLANE1, "vClipPlane1");
      glBindAttribLocation(*_programObj, Shader::ATTRIB_CLIPPLANE5, "vClipPlane5");
      glBindAttribLocation(*_programObj, Shader::ATTRIB_SxOxSyOy, "vSxOxSyOy");
      glBindAttribLocation(*_programObj, Shader::ATTRIB_BsBtFlSl, "vBsBtFlSl");
      glBindAttribLocation(*_programObj, Shader::ATTRIB_PuWoDeGl, "vPuWoDeGl");

      glLinkProgram(*_programObj);   printGLError(__PRETTY_FUNCTION__); //DCW no ARB in ios
      glGetProgramiv(*_programObj, GL_LINK_STATUS, &linked);
      
      if(!linked)
      {
        GLint infoLen = 0;
        glGetProgramiv(*_programObj, GL_INFO_LOG_LENGTH, &infoLen);
        if(infoLen > 1)
        {
          char* infoLog = (char*) malloc(sizeof(char) * infoLen);
          glGetProgramInfoLog(*_programObj, infoLen, NULL, infoLog);
          printf("Error linking program:\n%s\n", infoLog);
          free(infoLog);
        }
        glDeleteProgram(*_programObj);
      }
      assert(_programObj);

      glUseProgram(*_programObj);

      glUniform1i(shader->getUniformLocation(Shader::U_Texture0), 0);
      glUniform1i(shader->getUniformLocation(Shader::U_Texture1), 1);
      glUniform1i(shader->getUniformLocation(Shader::U_Texture2), 2);
      glUniform1i(shader->getUniformLocation(Shader::U_Texture3), 3);
  
      glUseProgram(0); // no ARB on ios
    
}

AOAuint AOA::createProgram (void)
{
  return glCreateProgram();
}

AOAuint AOA::createShader (AOAenum type)
{
  return glCreateShader(type);
}

void AOA::linkProgram (AOAuint program)
{
  glLinkProgram(program);
}
void AOA::shaderSource (AOAuint shader, AOAsizei count, const AOAchar *const*string, const AOAint *length)
{
  glShaderSource(shader, count, string, length);
}
void AOA::useProgram (AOAuint program)
{
    glUseProgram(program);
}

void AOA::disuseProgram ()
{
  glUseProgram(0);
}

void AOA::compileShader (AOAuint shader)
{
  glCompileShader(shader);
}

void AOA::attachShader (AOAuint program, AOAuint shader)
{
  glAttachShader(program, shader);
}

void AOA::deleteShader (AOAuint shader)
{
  glDeleteShader(shader);
}

void AOA::bindAttribLocation (AOAuint program, AOAuint index, const AOAchar *name)
{
  glBindAttribLocation(program, index, name);
}

void AOA::getProgramiv (AOAuint program, AOAenum pname, AOAint *params)
{
  glGetProgramiv(program, pname, params);
}

void AOA::getProgramInfoLog (AOAuint program, AOAsizei bufSize, AOAsizei *length, AOAchar *infoLog)
{
  glGetProgramInfoLog(program, bufSize, length, infoLog);
}

void AOA::deleteProgram (AOAuint program)
{
  glDeleteProgram(program);
}

AOAint AOA::getUniformLocation (AOAuint program, const AOAchar *name)
{
  return glGetUniformLocation(program, name);
}

void AOA::resetUniforms ()
{
  for(int i = 0; i < Shader::NUMBER_OF_UNIFORM_LOCATIONS; ++i ) {
    uniformSet[i] = 0;
  }
}

void AOA::uniform4f (AOAint name, Shader *shader, AOAfloat v0, AOAfloat v1, AOAfloat v2, AOAfloat v3)
{
    glUniform4f(shader->getUniformLocation((Shader::UniformName)name), v0, v1, v2, v3);
}

void AOA::uniform1i (AOAint name, Shader *shader, AOAint v0, void* alternateTextureHandle)
{
    glUniform1f(shader->getUniformLocation((Shader::UniformName)name), v0);
}

void AOA::uniform1f(AOAint name, Shader *shader, AOAfloat v0)
{
    glUniform1f(shader->getUniformLocation((Shader::UniformName)name), v0);
}

void AOA::uniformMatrix4fv (AOAint name, Shader *shader, AOAsizei count, AOAboolean transpose, const AOAfloat *value)
{
    glUniformMatrix4fv(shader->getUniformLocation((Shader::UniformName)name), count, transpose, value);
}

void AOA::vertexAttribPointer (AOAuint index, AOAint size, AOAenum type, AOAboolean normalized, AOAsizei stride, const void *pointer)
{
    glVertexAttribPointer(index, size, type, normalized, stride, pointer);
}

void AOA::enableVertexAttribArray (AOAuint index)
{
    glEnableVertexAttribArray(index);
}

void AOA::drawElements (AOAenum mode, AOAsizei count, AOAenum type, const AOAvoid* indices)
{
  glDrawElements(mode, count, type, indices);
}

void AOA::genTextures (AOAsizei n, AOAuint* textures)
{
    glGenTextures(n, textures);
}

void AOA::activeTexture (AOAuint unit)
{
  switch (unit) {
      case(AOA_TEXTURE0):
        glActiveTexture(GL_TEXTURE0);
        break;
      case(AOA_TEXTURE1):
        glActiveTexture(GL_TEXTURE1);
        break;
      case(AOA_TEXTURE2):
        glActiveTexture(GL_TEXTURE2);
        break;
      case(AOA_TEXTURE3):
        glActiveTexture(GL_TEXTURE3);
        break;
      default:
        glActiveTexture(GL_TEXTURE0);
        break;
     }
}

void AOA::bindTexture (AOAenum target, AOAuint texture, void* alternateTextureHandle, bool dontSetUniform)
{
    glBindTexture(target, texture);
}

void AOA::deleteTextures (AOAsizei n, const AOAuint* textures)
{
     glDeleteTextures(n, textures);
}

void AOA::texEnvi (AOAenum target, AOAenum pname, AOAint param)
{
  //NOOP?
}

void AOA::texParameteri (AOAenum target, AOAenum pname, AOAint param)
{
  glTexParameteri(target, pname, param);
}

void AOA::texImage2D (AOAenum target, AOAint level, AOAint internalformat, AOAsizei width, AOAsizei height, AOAint border, AOAenum format, AOAenum type, const AOAvoid* pixels)
{
  AOA::texImage2DCopy(target, level, internalformat, width, height, border, format, type, pixels, 0);
}
void AOA::texImage2DCopy (AOAenum target, AOAint level, AOAint internalformat, AOAsizei width, AOAsizei height, AOAint border, AOAenum format, AOAenum type, const AOAvoid* pixels, bool copyData)
{
    glTexImage2D(target, level, internalformat, width, height, border, format, type, pixels);
}

void AOA::compressedTexImage2D (AOAenum target, AOAint level, AOAenum internalformat, AOAsizei width, AOAsizei height, AOAint border, AOAsizei imageSize, const void *data)
{
     glCompressedTexImage2D(target, level, internalformat, width, height, border, imageSize, data);
}

void AOA::getIntegerv (AOAenum pname, AOAint* params)
{
    glGetIntegerv(pname, params);
}

void AOA::getFloatv (AOAenum pname, AOAfloat* params)
{
  glGetFloatv(pname, params);
}

AOAuint AOA::generateFrameBuffer(AOAint width, AOAint height)
{
  //Find an open framebuffer slot to use...
  int fb;
  for(fb = 0; fb < AOA_MAX_FRAMEBUFFERS; ++fb) {
    if( !framebuffers[fb].initialized ) {
      framebuffers[fb].initialized = 1;
      framebuffers[fb].w = width;
      framebuffers[fb].h = height;
      break;
    }
  }
  if(fb >= AOA_MAX_FRAMEBUFFERS) {
    printf("Out of frame buffer slots!\n");
    return 0;
  }
  
    glGenFramebuffers(1, &(framebuffers[fb].OGLFBID));
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffers[fb].OGLFBID);
    
    printf("Creating OpenGL framebuffer (%d, %d) AOA Index %d (OGL ID %d)\n", width,  height, fb, framebuffers[fb].OGLFBID);
    
    //Create texture and attach it to framebuffer's color attachment point
    AOA::genTextures(1, &(framebuffers[fb].OGLTextureID));
    AOA::bindTexture(GL_TEXTURE_2D, framebuffers[fb].OGLTextureID, NULL, 0); //DCW was GL_TEXTURE_RECTANGE
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);  //DCW
    AOA::texImage2D(GL_TEXTURE_2D, 0, /*srgb ? GL_SRGB :*/ GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, framebuffers[fb].OGLTextureID, 0);
    
    //Generate depth buffer
    glGenRenderbuffers(1, &(framebuffers[fb].OGLRenderBufferID));
    glBindRenderbuffer(GL_RENDERBUFFER, framebuffers[fb].OGLRenderBufferID);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, framebuffers[fb].OGLRenderBufferID);
  
  return fb;
}

void AOA::bindFramebuffer(AOAuint frameBuffer)
{
     glBindFramebuffer(GL_FRAMEBUFFER, framebuffers[frameBuffer].OGLFBID);
}

void AOA::prepareToDrawFramebuffer(AOAuint frameBuffer)
{
    AOA::pushGroupMarker(0, "FBO Binding texture");
    
    glBindTexture(GL_TEXTURE_2D, framebuffers[frameBuffer].OGLTextureID);
    glPopGroupMarkerEXT();
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

void AOA::drawFramebuffer(AOAuint frameBuffer)
{
  AOA::pushGroupMarker(0, "drawFramebuffer");
  AOA::drawTriangleFan(GL_TRIANGLE_FAN, 0, 4);
}

void AOA::deleteFramebuffer(AOAuint frameBuffer)
{
  if( frameBuffer < 0 || frameBuffer >= AOA_MAX_FRAMEBUFFERS) {
    printf("FrameBuffer slot %d out of range!\n", (int)frameBuffer);
    return;
  }
  
  glDeleteFramebuffers(1, &(framebuffers[frameBuffer].OGLFBID));
  glDeleteRenderbuffers(1, &(framebuffers[frameBuffer].OGLRenderBufferID));
  
  framebuffers[frameBuffer].initialized = 0;
  framebuffers[frameBuffer].w = 0;
  framebuffers[frameBuffer].h = 0;
}


void AOA::swapWindow(SDL_Window *window)
{
     SDL_GL_SwapWindow(window);
}

void AOA::fillAndCenterViewPort(float w, float h)
{
  float voffsetX = 0;
  float voffsetY = 0;
  float vratio = w / h;
  float vheight = helperShortScreenDimension()*helperScreenScale();
  float vwidth = vheight * vratio;
  voffsetX = ((helperLongScreenDimension()*helperScreenScale()) / 2) - (vwidth / 2);
    
  AOA::setPreferredViewPort(voffsetX, voffsetY, vwidth, vheight);
}


void AOA::setPreferredViewPort(float x, float y, float w, float h)
{
  portX = x;
  portY = y;
  portW = w;
  portH = h;
  
  printf("SETTING bgfx view %f %f %f %f\n", portX, portY, portW, portH);
}


void AOA::drawTriangleFan(GLenum mode, GLint first, GLsizei count)
{
    glDrawArrays(mode, first, count);
}
