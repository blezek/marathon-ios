//
//  AlephOneAcceleration.cpp
//  AlephOne
//
//  Created by Dustin Wenz on 2/17/20.
//  Copyright © 2020 SDG Productions. All rights reserved.
//

#include "AlephOneAcceleration.hpp"

#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>

AOA* AOA::m_pInstance = NULL;

AOA* AOA::Instance()
{
  if (!m_pInstance) {
    m_pInstance = new AOA;
  }
  return m_pInstance;
}

bool AOA::useBGFX()
{
  return 0;
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

void AOA::uniform4f (AOAint location, AOAfloat v0, AOAfloat v1, AOAfloat v2, AOAfloat v3)
{
  glUniform4f(location, v0, v1, v2, v3);
}

void AOA::uniform1i (AOAint location, AOAint v0)
{
  glUniform1f(location, v0);
}

AOAint AOA::getUniformLocation (AOAuint program, const AOAchar *name)
{
  return glGetUniformLocation(program, name);
}

void AOA::uniformMatrix4fv (AOAint location, AOAsizei count, AOAboolean transpose, const AOAfloat *value)
{
  glUniformMatrix4fv(location, count, transpose, value);
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

void AOA::bindTexture (AOAenum target, AOAuint texture)
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

void AOA::getGetFloatv (AOAenum pname, AOAfloat* params)
{
  glGetFloatv(pname, params);
}
