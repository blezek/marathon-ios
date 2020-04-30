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

#include <bx/bx.h>
#include <bx/math.h>
#include <bgfx/bgfx.h>
#include <bgfx/platform.h>

#include "OGL_Shader.h"

#include "metal_quad_vs.h"
#include "metal_quad_fs.h"
#include "metal_wall_vs.h"
#include "metal_wall_fs.h"


#define AOA_MAX_FRAMEBUFFERS 64
#define AOA_MAX_TEXTURES 8192
//AOA_TEXTURE_UNITS **MUST** corelate with the number of sampler uniforms in the name list (texture0, texture1, etc).
#define AOA_TEXTURE_UNITS 4

typedef struct texture_slot {
  bool reserved;
  bool initialized;
  bgfx::TextureHandle bgfxHandle;
} texture_slot;
texture_slot texture_slots[AOA_MAX_TEXTURES];
AOAint boundTextureSlotIndex; //Needed??
AOAint nextTextureSlotIndex;

typedef struct texture_unit {
  AOAuint textureID;
  bgfx::TextureHandle *alternateTexture; //Use this handle (probably a fremabuffer texture) instead of textureID if set.
} texture_unit;
texture_unit texture_units[AOA_TEXTURE_UNITS];
AOAint activeTextureUnit;


typedef struct framebuffer_slot {
  bgfx::FrameBufferHandle bgfxHandle;
  bgfx::TextureHandle textures[2]; //Color and depth texture.
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

bgfx::ProgramHandle bgfxPrograms[Shader::NUMBER_OF_SHADER_TYPES];
bgfx::ShaderHandle bgfxVertexShaders[Shader::NUMBER_OF_SHADER_TYPES];
bgfx::ShaderHandle bgfxFragmentShaders[Shader::NUMBER_OF_SHADER_TYPES];
bgfx::UniformHandle bgfxUniforms[Shader::NUMBER_OF_UNIFORM_LOCATIONS];
bool uniformCreated[Shader::NUMBER_OF_UNIFORM_LOCATIONS];
bool uniformSet[Shader::NUMBER_OF_UNIFORM_LOCATIONS];

int activeProgram = -1; //-1 indicates no active program.

bgfx::ShaderHandle quad_vert;
bgfx::ShaderHandle quad_frag;
bgfx::ProgramHandle quad_program;

bool quad_inited, shaders_inited;

const void *texturePointer, *vertexPointer, *normalPointer;
int vertexPointerSize;
int vertexType;
int vertexStride;

struct V3N3T2VertexLayout
{
  float m_x; float m_y; float m_z; float m_normal[3]; float m_u; float m_v;
  static void init()
  {
    ms_layout
      .begin()
      .add(bgfx::Attrib::Position,  3, bgfx::AttribType::Float)
      .add(bgfx::Attrib::Normal,   3, bgfx::AttribType::Float)
      .add(bgfx::Attrib::TexCoord0, 2, bgfx::AttribType::Float)
      .end();
  }
  static bgfx::VertexLayout ms_layout;
};
bgfx::VertexLayout V3N3T2VertexLayout::ms_layout;

struct V3T2VertexLayout
{
  float m_x; float m_y; float m_z; float m_u; float m_v;
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
bgfx::VertexLayout V3T2VertexLayout::ms_layout;
  
struct V2T2VertexLayout
{
  float m_x; float m_y; float m_u; float m_v;
  static void init()
  {
    ms_layout
      .begin()
      .add(bgfx::Attrib::Position,  2, bgfx::AttribType::Float)
      .add(bgfx::Attrib::TexCoord0, 2, bgfx::AttribType::Float)
      .end();
  }
  static bgfx::VertexLayout ms_layout;
};
bgfx::VertexLayout V2T2VertexLayout::ms_layout;

struct V3sT2VertexLayout
{
  int16 m_x; int16 m_y; int16 m_z; float m_u; float m_v;
  static void init()
  {
    ms_layout
      .begin()
      .add(bgfx::Attrib::Position,  3, bgfx::AttribType::Int16)
      .add(bgfx::Attrib::TexCoord0, 2, bgfx::AttribType::Float)
      .end();
  }
  static bgfx::VertexLayout ms_layout;
};
bgfx::VertexLayout V3sT2VertexLayout::ms_layout;
  
struct V2sT2VertexLayout
{
  int16 m_x; int16 m_y; float m_u; float m_v;
  static void init()
  {
    ms_layout
      .begin()
      .add(bgfx::Attrib::Position,  2, bgfx::AttribType::Int16)
      .add(bgfx::Attrib::TexCoord0, 2, bgfx::AttribType::Float)
      .end();
  }
  static bgfx::VertexLayout ms_layout;
};
bgfx::VertexLayout V2sT2VertexLayout::ms_layout;


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

bool AOA::OGLIrrelevant(){
  return AOA::useBGFX();
}

void AOA::pushGroupMarker(AOAsizei length, const char *marker)
{
  if ( useBGFX() ) {
    bgfx::setMarker(marker);
  } else {
    glPushGroupMarkerEXT(length, marker);
  }
}

void AOA::popGroupMarker(void)
{
  
  if ( useBGFX() ) {
    //NOOP?
  } else {
    glPopGroupMarkerEXT();
  }
}

void  AOA::clearColor (AOAfloat red, AOAfloat green, AOAfloat blue, AOAfloat alpha)
{
  glClearColor(red, green, blue, alpha);
}

void AOA::clear (uint32_t maskField)
{
  glClear(maskField);
}

void AOA::initAllShaders() {

  if(shaders_inited) return;
  
  //Init layouts:
  V3N3T2VertexLayout::init();
  V3T2VertexLayout::init();
  V2T2VertexLayout::init();
  V3sT2VertexLayout::init();
  V2sT2VertexLayout::init();


  activeProgram = -1;
  
  for( int i = 0; i < Shader::NUMBER_OF_SHADER_TYPES; ++i) {
    
    bgfxPrograms[i] = BGFX_INVALID_HANDLE;
    bgfxVertexShaders[i] = BGFX_INVALID_HANDLE;
    bgfxFragmentShaders[i] = BGFX_INVALID_HANDLE;
    
    const bgfx::Memory *vs_mem;
    const bgfx::Memory *fs_mem;
    
      //Map the OGL shader types to the BGFX Shaders.
    if (i == Shader::S_Wall || i == Shader::S_WallBloom) {
      vs_mem = bgfx::makeRef(metal_wall_vs, sizeof(metal_wall_vs));
      fs_mem = bgfx::makeRef(metal_wall_fs, sizeof(metal_wall_fs));
      
      bgfxVertexShaders[i] = bgfx::createShader(vs_mem);
      bgfxFragmentShaders[i] = bgfx::createShader(fs_mem);

      bgfx::setName(bgfxVertexShaders[i], Shader::_shader_names[i] );
      bgfx::setName(bgfxFragmentShaders[i], Shader::_shader_names[i] );

      bgfxPrograms[i] = bgfx::createProgram(bgfxVertexShaders[i], bgfxFragmentShaders[i]);
      
      if( bgfx::isValid(bgfxPrograms[i]) ) {
        printf("Created program for %s!\n", Shader::_shader_names[i] );
      } else {
        printf("Program for %s is invalid!\n", Shader::_shader_names[i] );
      }
    }
  }
  
   //Lets initialize uniforms on-demand.
  //for( int i = 0; i < Shader::NUMBER_OF_UNIFORM_LOCATIONS; ++i) {
  //  bgfxUniforms[i] = BGFX_INVALID_HANDLE;
  //}
  
  shaders_inited = 1;
}


void AOA::programFromNameIndex (AOAuint *_programObj, AOAuint nameIndex, Shader *shader)
{
  if ( AOA::useBGFX() ) {
    
    if(!shaders_inited) {
      AOA::initAllShaders();
    }
    
    *_programObj = nameIndex;
  } else {
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
  if ( AOA::useBGFX() ) {
    //printf ("Using program %d\n", program);
    if(program==4) {
      printf ("!!Using program %d\n", program);
    }
    
    activeProgram = program;
   } else {
     glUseProgram(program);
   }
}

void AOA::disuseProgram ()
{
  if ( AOA::useBGFX() ) {
    activeProgram=-1;
  } else {
    glUseProgram(0);
  }
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
  if(AOA::useBGFX()){
    if( !uniformSet[name] ) {
      if ( !uniformCreated[name] ) {
        printf("Creating Vec4 uniform %s\n", Shader::_uniform_names[name]);
        bgfxUniforms[name] = bgfx::createUniform(Shader::_uniform_names[name], bgfx::UniformType::Vec4);
        uniformCreated[name] = 1;
        if( !bgfx::isValid(bgfxUniforms[name]) ) {
          printf("Unable to create valid uniform %s!\n", Shader::_uniform_names[name]);
        }
      }
      
      AOAfloat v[4]; v[0]=v0; v[1]=v1; v[2]=v2; v[3]=v3;
      bgfx::setUniform(bgfxUniforms[name], &v, 1); //Jeez, I hope this sets all 4 values...
      uniformSet[name] = 1;
    }
  } else {
    glUniform4f(shader->getUniformLocation((Shader::UniformName)name), v0, v1, v2, v3);
  }
}

void AOA::uniform1i (AOAint name, Shader *shader, AOAint v0, void* alternateTextureHandle)
{
  if(AOA::useBGFX()){
    if( !uniformSet[name] ) {
      if ( !uniformCreated[name] ) {
        printf("Creating sampler uniform %s\n", Shader::_uniform_names[name]);
        bgfxUniforms[name] = bgfx::createUniform(Shader::_uniform_names[name], bgfx::UniformType::Sampler);
        uniformCreated[name] = 1;
        if( !bgfx::isValid(bgfxUniforms[name]) ) {
          printf("Unable to create uniform %s\n", Shader::_uniform_names[name]);
        }
      }
      
      if( alternateTextureHandle != NULL ) {
        printf("Setting alternate texture with unit: %d\n", name);
        bgfx::setTexture(0, bgfxUniforms[name], *(bgfx::TextureHandle*)alternateTextureHandle);
        if ( !bgfx::isValid(*(bgfx::TextureHandle*)alternateTextureHandle) ) {
          printf("Alternate texture invalid!\n");
        }
      } else {
        //printf("Setting texture slot %d with unit: %d\n", v0, name);
        bgfx::setTexture(0, bgfxUniforms[name], texture_slots[v0].bgfxHandle);
        if ( !bgfx::isValid(texture_slots[v0].bgfxHandle) ) {
          printf("Texture invalid at slot %d!\n", v0);
        }

      }
      uniformSet[name] = 1;
    }
  } else {
    glUniform1f(shader->getUniformLocation((Shader::UniformName)name), v0);
  }
}

void AOA::uniform1f(AOAint name, Shader *shader, AOAfloat v0)
{
  if(AOA::useBGFX()){
    if( !uniformSet[name] ) {
      if ( !uniformCreated[name] ) {
        printf("Creating float uniform %s\n", Shader::_uniform_names[name]);
        bgfxUniforms[name] = bgfx::createUniform(Shader::_uniform_names[name], bgfx::UniformType::Vec4);
        uniformCreated[name] = 1;
        if( !bgfx::isValid(bgfxUniforms[name]) ) {
          printf("Unable to create uniform %s\n", Shader::_uniform_names[name]);
        }
      }
      printf("setting float uniform %s\n", Shader::_uniform_names[name]);
      bgfx::setUniform(bgfxUniforms[name], &v0, 1);
      uniformSet[name] = 1;
    }
  } else {
    glUniform1f(shader->getUniformLocation((Shader::UniformName)name), v0);
  }
}

void AOA::uniformMatrix4fv (AOAint name, Shader *shader, AOAsizei count, AOAboolean transpose, const AOAfloat *value)
{
  if(AOA::useBGFX()){
    if( !uniformSet[name] ) {
      if ( !uniformCreated[name] ) {
        printf("Creating mat4 uniform %s\n", Shader::_uniform_names[name]);
        bgfxUniforms[name] = bgfx::createUniform(Shader::_uniform_names[name], bgfx::UniformType::Mat4);
        uniformCreated[name] = 1;
        if( !bgfx::isValid(bgfxUniforms[name]) ) {
          printf("Unable to create uniform %s\n", Shader::_uniform_names[name]);
        }
      }
      
      bgfx::setUniform(bgfxUniforms[name], value, 1);
      uniformSet[name] = 1;
    }
  } else {
    glUniformMatrix4fv(shader->getUniformLocation((Shader::UniformName)name), count, transpose, value);
  }
}

void AOA::vertexAttribPointer (AOAuint index, AOAint size, AOAenum type, AOAboolean normalized, AOAsizei stride, const void *pointer)
{
  if(AOA::useBGFX()){
    //Textures are always size 2, vertex are 2 or 3, and normal are always 3.
    //Type for textures is always float, vertex either float or short,
    //Normalized are always false

    switch (index) {
      case Shader::ATTRIB_TEXCOORDS:
        texturePointer=pointer;
        break;
        
      case Shader::ATTRIB_VERTEX:
        vertexPointerSize=size;
        vertexPointer=pointer;
        vertexType=type;
        vertexStride=stride;
        break;
      case Shader::ATTRIB_NORMAL:
        normalPointer=pointer;
        break;
        
      default:
        break;
    }
       
    
  } else {
    glVertexAttribPointer(index, size, type, normalized, stride, pointer);
  }
}

void AOA::enableVertexAttribArray (AOAuint index)
{
  if(AOA::useBGFX()){
    //Could be Shader::ATTRIB_TEXCOORDS or Shader::ATTRIB_VERTEX or Shader::ATTRIB_NORMAL
  } else {
    glEnableVertexAttribArray(index);
  }
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

void AOA::activeTexture (AOAuint unit)
{
  if( AOA::useBGFX() ) {
    activeTextureUnit = unit;
    //printf("Setting texture unit: %d\n", (int)unit);
  } else {
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
}

void AOA::bindTexture (AOAenum target, AOAuint texture, void* alternateTextureHandle, bool dontSetUniform)
{
  if( useBGFX() ) {
    
    AOA::Instance();//make sure we are initialized.
    
    if( texture < 0 || texture >= AOA_MAX_TEXTURES) {
        printf("Cannot bind texture slot: %d out of range!\n", (int)texture);
        return;
      }
    
    if( texture_slots[texture].reserved) {
      boundTextureSlotIndex = texture;
      
      frameBufferReadyToDraw = false;
        
      //if( !dontSetUniform ) {
      //  AOA::uniform1i (activeTextureUnit, NULL, texture, alternateTextureHandle);
      //}
      
      texture_units[activeTextureUnit].textureID=texture;
      texture_units[activeTextureUnit].alternateTexture= (bgfx::TextureHandle*)alternateTextureHandle;
      
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
  if( useBGFX() ) {
    switch (pname) {
      case AOA_MAX_TEXTURE_SIZE:
        *params = bgfx::getCaps()->limits.maxTextureSize;
        break;
        
      default:
        printf("Unsupported getIntegerv type!\n");
        break;
    }
  } else {
    glGetIntegerv(pname, params);
  }
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
  
  if( useBGFX() ) {
    printf("Creating framebuffer (%d, %d)\n", width,  height);

      //Color texture
    framebuffers[fb].textures[0] = bgfx::createTexture2D(width, height, false, 1, bgfx::TextureFormat::RGBA8, (uint16_t)0
                                                                                                                  | BGFX_TEXTURE_RT
                                                                                                                  | BGFX_SAMPLER_MIN_POINT
                                                                                                                  | BGFX_SAMPLER_MAG_POINT
                                                                                                                  | BGFX_SAMPLER_MIP_POINT
                                                                                                                  | BGFX_SAMPLER_U_CLAMP
                                                                                                                  | BGFX_SAMPLER_V_CLAMP);
      //Depth texture
    framebuffers[fb].textures[1] = bgfx::createTexture2D(width, height, false, 1, bgfx::TextureFormat::D16, BGFX_TEXTURE_RT_WRITE_ONLY);
    if (!bgfx::isValid(framebuffers[fb].textures[1])) {
      printf("Couldn't create frame buffer depth texture!");
    }
    
    
    framebuffers[fb].bgfxHandle = bgfx::createFrameBuffer(2, framebuffers[fb].textures, true);
    //framebuffers[fb].bgfxHandle = bgfx::createFrameBuffer(width, height, bgfx::TextureFormat::RGBA8, BGFX_SAMPLER_U_MIRROR | BGFX_SAMPLER_MAG_ANISOTROPIC);
    
    if ( !bgfx::isValid(framebuffers[fb].bgfxHandle) ) {
      printf("Framebuffer could not be created!\n");
      framebuffers[fb].bgfxHandle = BGFX_INVALID_HANDLE;
      framebuffers[fb].initialized = 0;
      framebuffers[fb].w = 0;
      framebuffers[fb].h = 0;
    } else {
      bgfx::setViewFrameBuffer(2, framebuffers[fb].bgfxHandle);
      bgfx::setViewClear(2, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH, 0x00FFFFFF, 1.0f, 0);
      bgfx::setViewRect(2, 0,0, width, height); //Maybe this should be full screen...
      bgfx::touch(2);
    }
    
  } else {
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
  }
  
  return fb;
}

void AOA::bindFramebuffer(AOAuint frameBuffer)
{
  if( useBGFX() ) {
    //I think the viewport needs to be set the same as the framebuffer for setViewFrameBuffer to work.
    //If we don't check, this is the error you will see: -[MTLDebugRenderCommandEncoder setScissorRect:]:2702: failed assertion `(rect.x(0) + rect.width(2436))(2436) must be <= render pass width(640)'
    if (framebuffers[frameBuffer].w == (int)portW && framebuffers[frameBuffer].h == (int)portH){
      bgfx::setViewMode(2);
      bgfx::setViewFrameBuffer(2, framebuffers[frameBuffer].bgfxHandle);
      boundFrameBuffer=frameBuffer;
    } else {
      printf("Framebuffer (%d, %d) does not match viewport size (%d, %d)\n", framebuffers[frameBuffer].w, framebuffers[frameBuffer].h, (int)portW, (int)portH);
    }
    
   } else {
     glBindFramebuffer(GL_FRAMEBUFFER, framebuffers[frameBuffer].OGLFBID);
   }
}

void AOA::prepareToDrawFramebuffer(AOAuint frameBuffer)
{
  if( useBGFX() ) {
    //DCW SHIT TEST. This will break until I fix it!  frameBufferReadyToDraw = true;
    frameBufferToDraw = frameBuffer;
  } else {
    AOA::pushGroupMarker(0, "FBO Binding texture");
    
    glBindTexture(GL_TEXTURE_2D, framebuffers[frameBuffer].OGLTextureID);
    glPopGroupMarkerEXT();
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  }

}

void AOA::drawFramebuffer(AOAuint frameBuffer)
{
  AOA::pushGroupMarker(0, "drawFramebuffer");
    
  if( useBGFX()) {
    //bgfx::TextureHandle theTexture = bgfx::getTexture(framebuffers[frameBuffer].bgfxHandle, 0);
    bgfx::TextureHandle theTexture = framebuffers[frameBuffer].textures[0];
    
    AOA::DrawQuadUsingTexture(0, 0, framebuffers[frameBuffer].w, framebuffers[frameBuffer].h , 0, 0, 1, 1, &theTexture, 0);
  } else {
    AOA::drawTriangleFan(GL_TRIANGLE_FAN, 0, 4);
  }
}

void AOA::deleteFramebuffer(AOAuint frameBuffer)
{
  if( frameBuffer < 0 || frameBuffer >= AOA_MAX_FRAMEBUFFERS) {
    printf("FrameBuffer slot %d out of range!\n", (int)frameBuffer);
    return;
  }
  
  if( useBGFX() ) {
    if (bgfx::isValid(framebuffers[frameBuffer].bgfxHandle) )
    {
      bgfx::destroy(framebuffers[frameBuffer].bgfxHandle);
      framebuffers[frameBuffer].bgfxHandle = BGFX_INVALID_HANDLE;
    }
  } else {
    glDeleteFramebuffers(1, &(framebuffers[frameBuffer].OGLFBID));
    glDeleteRenderbuffers(1, &(framebuffers[frameBuffer].OGLRenderBufferID));
  }
  
  framebuffers[frameBuffer].initialized = 0;
  framebuffers[frameBuffer].w = 0;
  framebuffers[frameBuffer].h = 0;
}


void AOA::swapWindow(SDL_Window *window)
{
  if( useBGFX() ) {
    bgfx::setDebug(false ? BGFX_DEBUG_STATS : BGFX_DEBUG_TEXT);
    
    printf("bgfx swap frame with draws %d!\n", drawsThisFrame);
    bgfx::touch(0);
    bgfx::touch(1);
    bgfx::touch(2);
    if( drawsThisFrame > 0 ) {
      bgfx::frame();
    }
    drawsThisFrame=0;
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
  
  printf("SETTING bgfx view %f %f %f %f\n", portX, portY, portW, portH);
}

void AOA::DrawQuadUsingTexture(float x, float y, float w, float h, float tleft, float ttop, float tright, float tbottom, void* theTextureHandle, uint viewID)
{
  /*if(frameBufferReadyToDraw) {
    AOA::pushGroupMarker(0, "FrameBuffer needs drawing");
    frameBufferReadyToDraw = false;
    AOA::drawFramebuffer(frameBufferToDraw);
  }*/
  
  AOA::pushGroupMarker(0, "DrawQuadUsingTexture");
  
  bgfx::setViewRect(viewID, portX, portY, portW, portH); //This might need to get moved to DrawQuad...
  //bgfx::setViewRect(1, portX, portY, portW, portH);
  //bgfx::setViewRect(2, portX, portY, portW, portH);

     //Initialize if needed
  if( !quad_inited ){
    V3T2VertexLayout::init();
    
    const bgfx::Memory *quad_vs_mem = bgfx::makeRef(metal_quad_vs, sizeof(metal_quad_vs));
    const bgfx::Memory *quad_fs_mem = bgfx::makeRef(metal_quad_fs, sizeof(metal_quad_fs));

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

  int numTVM = bgfx::getAvailTransientVertexBuffer(4, V3T2VertexLayout::ms_layout);
  int numTIM = bgfx::getAvailTransientIndexBuffer(6);
  
  if (bgfx::allocTransientBuffers(&tvb, V3T2VertexLayout::ms_layout, 4, &tib, 6) ) {
    V3T2VertexLayout* vertex = (V3T2VertexLayout*)tvb.data;
    
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
    
    
    bgfx::setIndexBuffer(&tib);
    bgfx::setVertexBuffer(0, &tvb);
    
    bgfx::setState( 0
                   | BGFX_STATE_WRITE_RGB
                   | BGFX_STATE_WRITE_A
                   | BGFX_STATE_WRITE_Z
                   | BGFX_STATE_DEPTH_TEST_ALWAYS
                   | BGFX_STATE_BLEND_ALPHA
                   //| BGFX_STATE_CULL_CW
                   //| BGFX_STATE_MSAA
                   
                   );

    
    //dcw shit test. This will bresk the UI until we fix it!
    /*bgfx::UniformHandle s_texColor; //Standard texture0
    s_texColor = bgfx::createUniform("s_texColor", bgfx::UniformType::Sampler);
    
    if (texture_slots[boundTextureSlotIndex].initialized) {
      bgfx::setTexture(0, s_texColor, *(bgfx::TextureHandle*)theTextureHandle);
    }*/
    
    AOA::uniform1i (activeTextureUnit, NULL, texture_units[activeTextureUnit].textureID, texture_units[activeTextureUnit].alternateTexture);
    
    //printf("Submit quad with viewid %d!\n", viewID);
    
    bgfx::submit(viewID, quad_program);
    drawsThisFrame++;
    AOA::resetUniforms();
  }
}

void AOA::DrawQuad(float x, float y, float w, float h, float tleft, float ttop, float tright, float tbottom)
{
  AOA::pushGroupMarker(0, "DrawQuad");
  //printf("DrawQuad!\n");

  if (texture_slots[boundTextureSlotIndex].initialized) {
    AOA::DrawQuadUsingTexture(x, y, w, h, tleft, ttop, tright, tbottom, &(texture_slots[boundTextureSlotIndex].bgfxHandle), 0);
  }
}



void AOA::drawTriangleFan(GLenum mode, GLint first, GLsizei count)
{
  if( useBGFX() ) {
    
    AOA::pushGroupMarker(0, "drawTriangleFan");
    
    Shader* lastShader = lastEnabledShader();
    
    if(!lastShader) {
      printf("No shader enabled for drawTriangleFan!\n");
      return;
    }
    
    if( count != 4 ) {
      printf("Sorry, only 4 vertices supported for drawTriangleFan!\n");
      return;
    }
    
    if( !texturePointer || !vertexPointer || vertexPointerSize != 3 || vertexType != GL_FLOAT) {
      printf("Sorry, format not supported for drawTriangleFan!\n");
      return;
    }
    
    bgfx::TransientVertexBuffer tvb;
    bgfx::TransientIndexBuffer tib;
    
    int numTVM = bgfx::getAvailTransientVertexBuffer(4, V3T2VertexLayout::ms_layout);
    int numTIM = bgfx::getAvailTransientIndexBuffer(6);
    
    if (bgfx::allocTransientBuffers(&tvb, V3T2VertexLayout::ms_layout, 4, &tib, 6) ) {
      V3T2VertexLayout* vertex = (V3T2VertexLayout*)tvb.data;
      
      float *vertices = (float*)vertexPointer;
      float *texCoords = (float*)texturePointer;
      int stride = 0;
      vertex[0].m_x = vertices[0];
      vertex[0].m_y = vertices[1];
      vertex[0].m_z = vertices[2];
      vertex[0].m_u = texCoords[0];
      vertex[0].m_v = texCoords[1];

      stride = vertexStride;
      vertex[1].m_x = vertices[stride+ 3];
      vertex[1].m_y = vertices[stride+ 4];
      vertex[1].m_z = vertices[stride+ 5];
      vertex[1].m_u = texCoords[2];
      vertex[1].m_v = texCoords[3];

      stride = 2*vertexStride;
      vertex[2].m_x = vertices[stride+ 6];
      vertex[2].m_y = vertices[stride+ 7];
      vertex[2].m_z = vertices[stride+ 8];
      vertex[2].m_u = texCoords[4];
      vertex[2].m_v = texCoords[5];
      
      stride = 3*vertexStride;
      vertex[3].m_x = vertices[stride+ 9];
      vertex[3].m_y = vertices[stride+ 10];
      vertex[3].m_z = vertices[stride+ 11];
      vertex[3].m_u = texCoords[6];
      vertex[3].m_v = texCoords[7];

      uint16_t* indices = (uint16_t*)tib.data;

      indices[0] = 0;
      indices[1] = 2;
      indices[2] = 1;
      indices[3] = 0;
      indices[4] = 3;
      indices[5] = 2;
      
      
      bgfx::setIndexBuffer(&tib);
      bgfx::setVertexBuffer(0, &tvb);
      
      bgfx::setState( 0
                     | BGFX_STATE_WRITE_RGB
                     | BGFX_STATE_WRITE_A
                     | BGFX_STATE_WRITE_Z
                     | BGFX_STATE_DEPTH_TEST_ALWAYS
                     | BGFX_STATE_BLEND_ALPHA
                     );
      
      AOA::uniform1i (activeTextureUnit, NULL, texture_units[activeTextureUnit].textureID, texture_units[activeTextureUnit].alternateTexture);
      
      bgfx::submit(0, bgfxPrograms[lastShader->getNameIndex()]);
      drawsThisFrame++;
      AOA::resetUniforms();
    }
    
  } else {
    glDrawArrays(mode, first, count);
  }
  
}
