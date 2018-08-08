#ifndef _OGL_SHADER_
#define _OGL_SHADER_
/*
 OGL_SHADER.H
 
 Copyright (C) 2009 by Clemens Unterkofler and the Aleph One developers
 
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
 
 Implements OpenGL vertex/fragment shader class
 */

#include <string>
#include <map>
#include "OGL_Headers.h"
#include "FileHandler.h"


class Shader {

friend class XML_ShaderParser;
friend class Shader_MML_Parser;
public:
	enum UniformName {
		U_Texture0,
		U_Texture1,
		U_Texture2,
		U_Texture3,
		U_Time,
		U_Pulsate,
		U_Wobble,
		U_Flare,
		U_BloomScale,
		U_BloomShift,
		U_Repeat,
		U_OffsetX,
		U_OffsetY,
		U_Pass,
		U_UseStatic,
		U_UseFog,
		U_Visibility,
		U_Depth,
		U_StrictDepthMode,
		U_Glow,
		U_LandscapeInverseMatrix,
		U_ScaleX,
		U_ScaleY,
		U_Yaw,
		U_Pitch,
		U_SelfLuminosity,
		U_GammaAdjust,
    //DCW below are compatibiliy uniforms to replace the FFT ones.
    U_MS_ModelViewProjectionMatrix,
    U_MS_ModelViewMatrix,
    U_MS_ModelViewMatrixInverse,
    U_MS_TextureMatrix,
    U_MS_Color,
    U_MS_FogColor,
    U_TexCoords4,
    U_ClipPlane0,
    U_ClipPlane1,
    U_ClipPlane2,
    U_ClipPlane3,
    U_ClipPlane4,
    U_ClipPlane5,
    U_MediaPlane6,
		NUMBER_OF_UNIFORM_LOCATIONS
	};

	enum ShaderType {
		S_Blur,
		S_Bloom,
		S_Landscape,
		S_LandscapeBloom,
		S_Sprite,
		S_SpriteBloom,
		S_Invincible,
		S_InvincibleBloom,
		S_Invisible,
		S_InvisibleBloom,
		S_Wall,
		S_WallBloom,
		S_Bump,
		S_BumpBloom,
		S_Gamma,
    S_Debug,
    S_Rect,
		NUMBER_OF_SHADER_TYPES
	};
  
  // DCW attribute index
  enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORDS,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
  };
  
private:

	GLuint _programObj;
	std::string _vert;
	std::string _frag;
	int16 _passes;
	bool _loaded;
  int nameIndex; //DCW

	static const char* _shader_names[NUMBER_OF_SHADER_TYPES];
	static std::vector<Shader> _shaders;

	static const char* _uniform_names[NUMBER_OF_UNIFORM_LOCATIONS];
	GLint _uniform_locations[NUMBER_OF_UNIFORM_LOCATIONS];
	float _cached_floats[NUMBER_OF_UNIFORM_LOCATIONS];

	GLint getUniformLocation(UniformName name) { 
		if (_uniform_locations[name] == -1) {
			_uniform_locations[name] = glGetUniformLocation(_programObj, _uniform_names[name]); //DCW no ARB in ios
		}
		return _uniform_locations[name];
	}
	
public:

	static Shader* get(ShaderType type) { return &_shaders[type]; }
	static void loadAll();
	static void unloadAll();
	
	Shader() : _programObj(0), _passes(-1), _loaded(false) {}
	Shader(const std::string& name);
	Shader(const std::string& name, FileSpecifier& vert, FileSpecifier& frag, int16& passes);
	~Shader();

	void load();
	void init();
	void enable();
	void unload();
	void setFloat(UniformName name, float); // shader must be enabled
	void setMatrix4(UniformName name, float *f);
  void setVec4(UniformName name, float *f);

	int16 passes();

	static void disable();
  static void drawDebugRect(); //DCW draws a debugging rect to middle of current binding.
};


class InfoTree;
void parse_mml_opengl_shader(const InfoTree& root);
void reset_mml_opengl_shader();

Shader* lastEnabledShader();

#endif
