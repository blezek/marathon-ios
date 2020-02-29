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

#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>

#include <bx/bx.h>
#include <bx/math.h>
#include <bgfx/bgfx.h>
#include <bgfx/platform.h>

#include "quad_vs.h"
#include "quad_fs.h"


#define AOA_MAX_TEXTURES 8192

typedef struct texture_slot {
  bool reserved;
  bool initialized;
  bgfx::TextureHandle bgfxHandle;
} texture_slot;

float portX, portY, portW, portH;

texture_slot texture_slots[AOA_MAX_TEXTURES];
AOAint boundTextureSlotIndex;
AOAint nextTextureSlotIndex;

bgfx::ShaderHandle quad_vert;
bgfx::ShaderHandle quad_frag;
bgfx::ProgramHandle quad_program;

bool quad_inited;

struct QuadVertexLayout
{
  float m_x;
  float m_y;
  float m_z;
  float m_u;
  float m_v;

  static void init()
  {
    ms_layout
      .begin()
      .add(bgfx::Attrib::Position,  3, bgfx::AttribType::Float)
      .add(bgfx::Attrib::TexCoord0, 2, bgfx::AttribType::Float)
      .end();
  }

  static bgfx::VertexLayout ms_layout;
};

bgfx::VertexLayout QuadVertexLayout::ms_layout;

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
  if ( useBGFX() ) {
    int foundTextures = 0;
    
    for (; ; ++nextTextureSlotIndex) {
      if (nextTextureSlotIndex >= AOA_MAX_TEXTURES ) { //This is a ring buffer. If everything is reserved, it will be an infinite loop. :(
        nextTextureSlotIndex = 0;
      }
      
      if (foundTextures >= n) {
        return;
      }
      
      if( !texture_slots[nextTextureSlotIndex].reserved ) {
        texture_slots[nextTextureSlotIndex].reserved = 1;
        texture_slots[nextTextureSlotIndex].initialized = 0;
        textures[foundTextures] = nextTextureSlotIndex;
        
        printf("Reserved texture %d as %d of %d\n", nextTextureSlotIndex, foundTextures+1, n);
        
        foundTextures++;
      }
    }
 
    printf("Out of texture slots!\n");
    
  } else {
    glGenTextures(n, textures);
  }
}

void AOA::bindTexture (AOAenum target, AOAuint texture)
{
  if( useBGFX() ) {
    
    AOA::Instance();//make sure we are initialized.
    
    if( texture < 0 || texture >= AOA_MAX_TEXTURES) {
        printf("Cannot bind texture slot: %d out of range!\n", (int)texture);
        return;
      }
    
    if( texture_slots[texture].reserved) {
      boundTextureSlotIndex = texture;
      
      /*if (texture_slots[boundTextureSlotIndex].initialized) {
        bgfx::setTexture(0, s_texColor,  texture_slots[texture].bgfxHandle); //Really needed here?
      }*/
     
    } else {
      printf("Cannot bind texture slot: %d not reserved!\n", (int)texture);
    }
    
  } else {
    glBindTexture(target, texture);
  }
}

void AOA::deleteTextures (AOAsizei n, const AOAuint* textures)
{
  if ( useBGFX() ) {
    
     for (int i = 0; i < n; ++i) {
       
       AOAuint index = textures[i];
       
       texture_slots[index].reserved = 0;
       if(texture_slots[index].initialized) {
         texture_slots[index].initialized = 0;
         bgfx::destroy(texture_slots[index].bgfxHandle);
         printf("Deleted texture %d \n", index);         
       } else {
         printf("Unreserved uninitialized texture %d \n", index);
       }
     }
   } else {
     glDeleteTextures(n, textures);
   }
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
  if( useBGFX() ) {
    
    if( boundTextureSlotIndex < 0 || boundTextureSlotIndex >= AOA_MAX_TEXTURES) {
      printf("Texture slot %d out of range!\n", (int)boundTextureSlotIndex);
      return;
    }
    //printf("Looking for texture slot %d...\n", (int)boundTextureSlotIndex);
    
    if( texture_slots[boundTextureSlotIndex].reserved) {
      if( !texture_slots[boundTextureSlotIndex].initialized) {
        
        //printf("Creating texture: %d\n", boundTextureSlotIndex);
        
        AOAuint elementSize = 4; //Only true for 8 bit channel 4 component textures, like RGBA8, otherwise might crash
        bgfx::TextureFormat::Enum bgfxFormat = bgfx::TextureFormat::RGBA8; //default
        
        if(format == AOA_RGBA || format == AOA_RGBA8) { //Not sure if this will work yet...
          bgfxFormat = bgfx::TextureFormat::RGBA8;
          elementSize = 4;
        } else if (format == AOA_LUMINANCE_ALPHA){
          elementSize = 2;
          bgfxFormat = bgfx::TextureFormat::RG8;
           //printf("yepper\n");
            //return;
          
        } else {
          printf("Unsupported texture format!!!!!\n");
        }
        
        copyData = 1;
        
        texture_slots[boundTextureSlotIndex].bgfxHandle = bgfx::createTexture2D((uint16_t)width, (uint16_t)height, 0, (uint16_t)1, bgfxFormat, (uint16_t)0
                              | BGFX_TEXTURE_RT
                              | BGFX_SAMPLER_MIN_POINT
                              | BGFX_SAMPLER_MAG_POINT
                              | BGFX_SAMPLER_MIP_POINT
                              | BGFX_SAMPLER_U_CLAMP
                              | BGFX_SAMPLER_V_CLAMP
                              , pixels ? bgfx::copy(pixels, elementSize * width * height) : bgfx::alloc( elementSize * width * height)  );
        
                        //bgfx::makeRef(pixels, 4 * width * height));
        texture_slots[boundTextureSlotIndex].initialized = 1;
        
        printf("Created texture at slot %d\n", (int)boundTextureSlotIndex);
        
        //bgfx::setViewClear(0, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH, 0xFF3355FF, 1.0f, 0);
        //bgfx::touch(0);
        //bgfx::frame();
        //printf("BLAM!!!!\n");
        
      } else {
        printf("Texture slot %d is already initialized!\n", (int)boundTextureSlotIndex);
        return;
      }
    } else {
      printf("Texture slot %d not reserved!\n", (int)boundTextureSlotIndex);
      return;
    }
  } else {
    glTexImage2D(target, level, internalformat, width, height, border, format, type, pixels);
  }
}

void AOA::compressedTexImage2D (AOAenum target, AOAint level, AOAenum internalformat, AOAsizei width, AOAsizei height, AOAint border, AOAsizei imageSize, const void *data)
{
   if( useBGFX() ) {
     printf("compressedTexImage2D unsupported in bgfx!\n");
   } else {
     glCompressedTexImage2D(target, level, internalformat, width, height, border, imageSize, data);
   }
}

void AOA::getIntegerv (AOAenum pname, AOAint* params)
{
  glGetIntegerv(pname, params);
}

void AOA::getGetFloatv (AOAenum pname, AOAfloat* params)
{
  glGetFloatv(pname, params);
}

void AOA::swapWindow(SDL_Window *window)
{
  if( useBGFX() ) {
    //bgfx::setDebug(true ? BGFX_DEBUG_STATS : BGFX_DEBUG_TEXT);
    
    bgfx::touch(0);
    
    bgfx::frame();
  } else {
    SDL_GL_SwapWindow(window);
  }
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
  
  printf("SETTUBG bgfx view %f %f %f %f\n", portX, portY, portW, portH);
}

void AOA::DrawQuad(float x, float y, float w, float h, float tleft, float ttop, float tright, float tbottom)
{
  bgfx::setViewRect(0, portX, portY, portW, portH);
  bgfx::setViewRect(1, portX, portY, portW, portH);

  
  
   //Initialize if needed
  if( !quad_inited ){
    QuadVertexLayout::init();
    
    const bgfx::Memory *quad_vs_mem = bgfx::makeRef(quad_vs, sizeof(quad_vs));
    const bgfx::Memory *quad_fs_mem = bgfx::makeRef(quad_fs, sizeof(quad_fs));

    quad_vert = bgfx::createShader(quad_vs_mem);
    quad_frag = bgfx::createShader(quad_fs_mem);
    
    bgfx::setName(quad_vert, "quad_vert");
    bgfx::setName(quad_frag, "quad_frag");

    quad_program = bgfx::createProgram(quad_vert, quad_frag);
    quad_inited = 1;
  }
    
  //printf("Drawing Quad. x:%f, y:%f  w:%f, h:%f\n", x,y,w,h);
  //GLint viewport[4];
  //glGetIntegerv( GL_VIEWPORT, viewport );
  
  //printf("Drawing quad!\nr");
  GLfloat vVertices[12] = { x, y, 0,
                            x + w, y, 0,
                            x + w, y + h, 0,
                            x, y + h, 0};
 
  MatrixStack::Instance()->transformVertex(vVertices[0], vVertices[1], vVertices[2]);
  MatrixStack::Instance()->transformVertex(vVertices[3], vVertices[4], vVertices[5]);
  MatrixStack::Instance()->transformVertex(vVertices[6], vVertices[7], vVertices[8]);
  MatrixStack::Instance()->transformVertex(vVertices[9], vVertices[10], vVertices[11]);
  
    
  GLfloat texCoords[8] = { tleft, ttop, tright, ttop, tright, tbottom, tleft, tbottom };

  GLubyte indices[] =   {0,1,2,
                        0,2,3};
  
  //bgfx::VertexBufferHandle vbh = bgfx::createVertexBuffer(bgfx::copy(texCoords, sizeof(texCoords)), pcvDecl, BGFX_BUFFER_NONE);
  //bgfx::IndexBufferHandle ibh = bgfx::createIndexBuffer(bgfx::makeRef(cubeTriList, sizeof(cubeTriList)));

  float ortho[16];
  bx::mtxOrtho(ortho, 0.0f, 2436 , 1135 , 0.0f, 0.0f, 100.0f, 0.0, bgfx::getCaps()->homogeneousDepth);
   // Set view and projection matrix for view 0.
  //bgfx::setViewTransform(0, NULL, ortho);
  
  float *color = MatrixStack::Instance()->color();
  
  //glUniform4f(uniforms[COLOR], color[0], color[1], color[2], color[3]);

  //glVertexAttribPointer(ATTRIB_TEXCOORDS, 2, GL_FLOAT, 0, 0, texCoords);
  //glEnableVertexAttribArray(ATTRIB_TEXCOORDS);

  
  // Load the vertex data
  //glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, vVertices);
  //glEnableVertexAttribArray(ATTRIB_VERTEX);
  
  //inspired by renderScreenSpaceQuad in raymarch.cpp
  bgfx::TransientVertexBuffer tvb;
  bgfx::TransientIndexBuffer tib;

  int numTVM = bgfx::getAvailTransientVertexBuffer(4, QuadVertexLayout::ms_layout);
  int numTIM = bgfx::getAvailTransientIndexBuffer(6);
  
  if (bgfx::allocTransientBuffers(&tvb, QuadVertexLayout::ms_layout, 4, &tib, 6) ) {
    QuadVertexLayout* vertex = (QuadVertexLayout*)tvb.data;
    
    vertex[0].m_x = vVertices[0];
    vertex[0].m_y = vVertices[1];
    vertex[0].m_z = vVertices[2];
    vertex[0].m_u = texCoords[0];
    vertex[0].m_v = texCoords[1];

    vertex[1].m_x = vVertices[3];
    vertex[1].m_y = vVertices[4];
    vertex[1].m_z = vVertices[5];
    vertex[1].m_u = texCoords[2];
    vertex[1].m_v = texCoords[3];

    vertex[2].m_x = vVertices[6];
    vertex[2].m_y = vVertices[7];
    vertex[2].m_z = vVertices[8];
    vertex[2].m_u = texCoords[4];
    vertex[2].m_v = texCoords[5];

    vertex[3].m_x = vVertices[9];
    vertex[3].m_y = vVertices[10];
    vertex[3].m_z = vVertices[11];
    vertex[3].m_u = texCoords[6];
    vertex[3].m_v = texCoords[7];

    uint16_t* indices = (uint16_t*)tib.data;

    indices[0] = 0;
    indices[1] = 2;
    indices[2] = 1;
    indices[3] = 0;
    indices[4] = 3;
    indices[5] = 2;
    
    /*indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 0;
    indices[4] = 2;
    indices[5] = 3;*/

    bgfx::setState( 0
                   | BGFX_STATE_WRITE_RGB
                   | BGFX_STATE_WRITE_A
                   | BGFX_STATE_WRITE_Z
                   | BGFX_STATE_DEPTH_TEST_ALWAYS
                   | BGFX_STATE_BLEND_ALPHA
                   //| BGFX_STATE_CULL_CW
                   //| BGFX_STATE_MSAA
                   
                   );
    
    bgfx::setIndexBuffer(&tib);
    bgfx::setVertexBuffer(0, &tvb);
    
    bgfx::UniformHandle s_texColor; //Standard texture0
    s_texColor = bgfx::createUniform("s_texColor", bgfx::UniformType::Sampler);
    
    if (texture_slots[boundTextureSlotIndex].initialized) {
      bgfx::setTexture(0, s_texColor,  texture_slots[boundTextureSlotIndex].bgfxHandle);
    }
        
    bgfx::submit(1, quad_program);
  }
}
