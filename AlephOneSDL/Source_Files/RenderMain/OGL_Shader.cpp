/*
 OGL_SHADER.CPP
 
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

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

#include <algorithm>
#include <iostream>

#include "OGL_Shader.h"
#include "FileHandler.h"
#include "OGL_Setup.h"
#include "InfoTree.h"

#include "AlephOneHelper.h"


// gl_ClipVertex workaround
// In Mac OS X 10.4 and Mesa, setting gl_ClipVertex causes a black screen.
// Unfortunately, it's required for proper 5-D space on other
// systems. This workaround comments out its use under 10.4 or Mesa.
#if (defined(__APPLE__) && defined(__MACH__))
#include <sys/utsname.h>

// On Tiger, uname -r starts with "8."
inline bool DisableClipVertex() {
	struct utsname uinfo;
	uname(&uinfo);
	if (uinfo.release[0] == '8' && uinfo.release[1] == '.')
		return true;
	return false;
}
#else
inline bool DisableClipVertex() { 
	const GLubyte* renderer = glGetString(GL_RENDERER);
	return (renderer && strncmp(reinterpret_cast<const char*>(renderer), "Mesa", 4) == 0);
}
#endif

//Global pointer to the last shader object enabled. May be NULL. extern is redundant, but included for clarity.
Shader* lastEnabledShaderRef;
Shader* lastEnabledShader() {
  return lastEnabledShaderRef;
}
void setLastEnabledShader(Shader* theShader) {
  lastEnabledShaderRef = theShader;
}


static std::map<std::string, std::string> defaultVertexPrograms;
static std::map<std::string, std::string> defaultFragmentPrograms;
void initDefaultPrograms();

std::vector<Shader> Shader::_shaders;

const char* Shader::_uniform_names[NUMBER_OF_UNIFORM_LOCATIONS] = 
{
	"texture0",
	"texture1",
	"texture2",
	"texture3",
	"time",
	"pulsate",
	"wobble",
	"flare",
	"bloomScale",
	"bloomShift",
	"repeat",
	"offsetx",
	"offsety",
	"pass",
	"usestatic",
	"usefog",
	"visibility",
	"depth",
	"strictDepthMode",
	"glow",
	"landscapeInverseMatrix",
	"scalex",
	"scaley",
	"yaw",
	"pitch",
	"selfLuminosity",
	"gammaAdjust",
  "MS_ModelViewProjectionMatrix",
  "MS_ModelViewMatrix",
  "MS_ModelViewMatrixInverse",
  "MS_TextureMatrix",
  "vColor",
  "vFogColor",
  "vTexCoord4",
  "clipPlane0",
  "clipPlane1",
  "clipPlane2",
  "clipPlane3",
  "clipPlane4",
  "clipPlane5",
  "mediaPlane",
};

const char* Shader::_shader_names[NUMBER_OF_SHADER_TYPES] = 
{
	"blur",
	"bloom",
	"landscape",
	"landscape_bloom",
	"sprite",
	"sprite_bloom",
	"invincible",
	"invincible_bloom",
	"invisible",
	"invisible_bloom",
	"wall",
	"wall_bloom",
	"bump",
	"bump_bloom",
	"gamma",
  "debug",
  "rect"
};


class Shader_MML_Parser {
public:
	static void reset();
	static void parse(const InfoTree& root);
};

void Shader_MML_Parser::reset()
{
	Shader::_shaders.clear();
}

void Shader_MML_Parser::parse(const InfoTree& root)
{
	std::string name;
	if (!root.read_attr("name", name))
		return;
	
	for (int i = 0; i < Shader::NUMBER_OF_SHADER_TYPES; ++i) {
		if (name == Shader::_shader_names[i]) {
			initDefaultPrograms();
			Shader::loadAll();
			
			FileSpecifier vert, frag;
			root.read_path("vert", vert);
			root.read_path("frag", frag);
			int16 passes;
			root.read_attr("passes", passes);
			
			Shader::_shaders[i] = Shader(name, vert, frag, passes);
			break;
		}
	}
}

void reset_mml_opengl_shader()
{
	Shader_MML_Parser::reset();
}

void parse_mml_opengl_shader(const InfoTree& root)
{
	Shader_MML_Parser::parse(root);
}

void parseFile(FileSpecifier& fileSpec, std::string& s) {

	s.clear();

	if (fileSpec == FileSpecifier() || !fileSpec.Exists()) {
		return;
	}

	OpenedFile file;
	if (!fileSpec.Open(file))
	{
		fprintf(stderr, "%s not found\n", fileSpec.GetPath());
		return;
	}

	int32 length;
	file.GetLength(length);

	s.resize(length);
	file.Read(length, &s[0]);
}


GLuint parseShader(const GLcharARB* str, GLenum shaderType) {

	GLint status;
	GLuint shader = glCreateShader(shaderType); //DCW no ARB in ios

	std::vector<const GLcharARB*> source;

	if (DisableClipVertex())
	{
		source.push_back("#define DISABLE_CLIP_VERTEX\n");
	}
	if (Wanting_sRGB)
	{
		source.push_back("#define GAMMA_CORRECTED_BLENDING\n");
	}
	if (Bloom_sRGB)
	{
		source.push_back("#define BLOOM_SRGB_FRAMEBUFFER\n");
	}
	source.push_back(str);

	glShaderSource(shader, source.size(), &source[0], NULL); //DCW no ARB in ios

	glCompileShader(shader);//DCW no ARB in ios
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
  
	if(status) {
		return shader;
	} else {
   
      //DCW We could really use some feedback here when the shader won't compile.
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
}

void Shader::loadAll() {
	initDefaultPrograms();
	if (!_shaders.size()) 
	{
		_shaders.reserve(NUMBER_OF_SHADER_TYPES);
		for (int i = 0; i < NUMBER_OF_SHADER_TYPES; ++i) 
		{
			_shaders.push_back(Shader(_shader_names[i]));
		}
	}
}

void Shader::unloadAll() {
	for (int i = 0; i < _shaders.size(); ++i) 
	{
		_shaders[i].unload();
	}
}

Shader::Shader(const std::string& name) : _programObj(0), _passes(-1), _loaded(false) {
  nameIndex = -1;
  initDefaultPrograms();
  
    //DCW track name index.
  for (int i = 0; i < Shader::NUMBER_OF_SHADER_TYPES; ++i) {
    if (name == Shader::_shader_names[i]) {
      nameIndex = i;
    }
  }
  
    if (defaultVertexPrograms.count(name) > 0) {
	    _vert = defaultVertexPrograms[name];
    }
    if (defaultFragmentPrograms.count(name) > 0) {
	    _frag = defaultFragmentPrograms[name];
    }
}    

Shader::Shader(const std::string& name, FileSpecifier& vert, FileSpecifier& frag, int16& passes) : _programObj(0), _passes(passes), _loaded(false) {
  nameIndex = -1;
  initDefaultPrograms();
	
	parseFile(vert,  _vert);
	if (_vert.empty() && defaultVertexPrograms.count(name) > 0) 
	{
		_vert = defaultVertexPrograms[name];
	}
	
	parseFile(frag, _frag);
	if (_frag.empty() && defaultFragmentPrograms.count(name) > 0) 
	{
		_frag = defaultFragmentPrograms[name];
	}
}

void Shader::init() {
	std::fill_n(_uniform_locations, static_cast<int>(NUMBER_OF_UNIFORM_LOCATIONS), -1);
	std::fill_n(_cached_floats, static_cast<int>(NUMBER_OF_UNIFORM_LOCATIONS), 0.0);
  GLint linked;
  
	_loaded = true;
  
  _programObj = glCreateProgram();//DCW

	assert(!_vert.empty());
	GLuint vertexShader = parseShader(_vert.c_str(), GL_VERTEX_SHADER);
	assert(vertexShader);
	glAttachShader(_programObj, vertexShader);
	glDeleteShader(vertexShader);

	assert(!_frag.empty());
	GLuint fragmentShader = parseShader(_frag.c_str(), GL_FRAGMENT_SHADER);
	assert(fragmentShader);
	glAttachShader(_programObj, fragmentShader);
	glDeleteShader(fragmentShader);
  
  // DCW Bind enum attributes to program
  glBindAttribLocation(_programObj, Shader::ATTRIB_VERTEX, "vPosition");
  glBindAttribLocation(_programObj, Shader::ATTRIB_TEXCOORDS, "vTexCoord");
  glBindAttribLocation(_programObj, Shader::ATTRIB_NORMAL, "vNormal");
  
  glLinkProgram(_programObj);   printGLError(__PRETTY_FUNCTION__); //DCW no ARB in ios
  
  glGetProgramiv(_programObj, GL_LINK_STATUS, &linked);
  
  if(!linked)
  {
    GLint infoLen = 0;
    glGetProgramiv(_programObj, GL_INFO_LOG_LENGTH, &infoLen);
    if(infoLen > 1)
    {
      char* infoLog = (char*) malloc(sizeof(char) * infoLen);
      glGetProgramInfoLog(_programObj, infoLen, NULL, infoLog);
      printf("Error linking program:\n%s\n", infoLog);
      free(infoLog);
    }
    glDeleteProgram(_programObj);
  }

  
	assert(_programObj);

  glUseProgram(_programObj);

	glUniform1i(getUniformLocation(U_Texture0), 0);
	glUniform1i(getUniformLocation(U_Texture1), 1);
	glUniform1i(getUniformLocation(U_Texture2), 2);
	glUniform1i(getUniformLocation(U_Texture3), 3);

	glUseProgram(0); // no ARB on ios

//	assert(glGetError() == GL_NO_ERROR);
}

void Shader::setFloat(UniformName name, float f) {

	if (_cached_floats[name] != f) {
		_cached_floats[name] = f;
		glUniform1f(getUniformLocation(name), f); //DCW no ARB on ios
	}
}

void Shader::setMatrix4(UniformName name, float *f) {
	glUniformMatrix4fv(getUniformLocation(name), 1, false, f); //DCW no ARB in ios
}

void Shader::setVec4(UniformName name, float *f) {
  glUniform4f(getUniformLocation(name), f[0], f[1], f[2], f[3]);
}

Shader::~Shader() {
	unload();
}

void Shader::enable() {
	if(!_loaded) { init(); }
  //glGetError();
  if(nameIndex >=0){ glPushGroupMarkerEXT(0, _shader_names[nameIndex]);} else {
    glPushGroupMarkerEXT(0, "non-default shader");
  }
	glUseProgram(_programObj); //DCW no ARB in ios
  setLastEnabledShader(this);
  glPopGroupMarkerEXT();
}

void Shader::disable() {
	glUseProgram(0);//DCW no ARB in ios
  Shader *enabledShader = lastEnabledShader();
  setLastEnabledShader(NULL);
}

void Shader::drawDebugRect() {
  Shader *s = Shader::get(Shader::S_Debug);
  s->enable();
  /*GLfloat vVertices[12] = { -.5, .5, 0,
    .5, .5, 0,
    .5, -.5, 0,
    -.5, -.5, 0};*/
  GLfloat vVertices[12] = { -1, 1, 0,
    1, 1, 0,
    1, -1, 0,
    -1, -1, 0};
  
  GLubyte indices[] =   {0,1,2,
    0,2,3};
  glVertexAttribPointer(Shader::ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, vVertices);
  glEnableVertexAttribArray(Shader::ATTRIB_VERTEX);
  glPushGroupMarkerEXT(0, "Draw Debug Rect");
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, indices);
  glPopGroupMarkerEXT();
  Shader::disable();
}

void Shader::unload() {
	if(_programObj) {
		//glDeleteObjectARB(_programObj);//DCW no ARB in ios
    glDeleteProgram(_programObj); //DCW maybe this needs to be a createshader()?
		_programObj = 0;
		_loaded = false;
     if(lastEnabledShader() == this) {
       setLastEnabledShader(NULL);
       
       Shader *enablementTest = lastEnabledShader();
     }
	}
}

int16 Shader::passes() {
	return _passes;
}

void initDefaultPrograms() {
    if (defaultVertexPrograms.size() > 0)
        return;

    defaultVertexPrograms["rect"] = ""
    "#version 300 es  \n"
    "uniform mat4 MS_ModelViewProjectionMatrix;\n"
    "uniform mat4 MS_TextureMatrix;\n"
    "uniform vec4 vColor;\n"
    "uniform float useStatic;\n"
    "in vec4 vPosition;   \n"
    "in vec2 vTexCoord;   \n"
    "out vec2 textureUV;   \n"
    "out vec4 vertexColor;\n"
    "void main()                 \n"
    "{                           \n"
    "  vec4 UV4 = vec4(vTexCoord.x, vTexCoord.y, 0.0, 1.0);\n"
    "  textureUV = (MS_TextureMatrix * UV4).xy;\n"
    "  vertexColor = vColor;\n"
    "  gl_Position = MS_ModelViewProjectionMatrix * vPosition;  \n"
    "} \n";
  
    defaultFragmentPrograms["rect"] = ""
    "#version 300 es  \n"
    "precision highp float;\n"
    "uniform float time;\n"
    "uniform float usestatic;\n"
    "in highp vec2 textureUV; \n"
    "in vec4 vertexColor;\n"
    "uniform highp sampler2D texture0;\n"
    "out vec4 fragmentColor;\n"
    "float rand(vec2 co){ \n"
    "highp float a = 12.9898; \n"
    "highp float b = 78.233; \n"
    "highp float c = 43758.5453; \n"
    "highp float dt= dot(co.xy ,vec2(a,b)); \n"
    "highp float sn= mod(dt,3.14); \n"
    "return fract(sin(sn) * c); \n"
    "} \n"
    "void main()                                \n"
    "{                                          \n"
  "  fragmentColor = texture(texture0, textureUV.xy) * vertexColor;\n"
    "  if (usestatic != 0.0 ) { \n"
    "    vec2 entropy = vec2 (time,time); \n"
    "    if (usestatic > 0.0) { entropy *= round(gl_FragCoord.xy / 4.0); } \n"
    "    fragmentColor.r = rand(entropy); fragmentColor.g =  rand(entropy*fragmentColor.r); fragmentColor.b =  rand(entropy*fragmentColor.g); \n"
    "  } \n"
    "} \n";

    defaultVertexPrograms["debug"] = ""
    "#version 300 es  \n"
    "in vec4 vPosition;   \n"
    "void main()                 \n"
    "{                           \n"
    "  gl_Position = vPosition;  \n"
    "}                           \n";
    defaultFragmentPrograms["debug"] = ""
    "#version 300 es  \n"
    "out vec4 fragmentColor;\n"
    "void main()                                \n"
    "{                                          \n"
    "  fragmentColor = vec4(0.0, 1.0, 0.0, .25); \n"
    "}                                          \n";
    
	defaultVertexPrograms["gamma"] = ""
  "#version 300 es  \n"
  "uniform mat4 MS_ModelViewProjectionMatrix;\n"
  "uniform mat4 MS_ModelViewMatrix;\n"
  "in vec4 vPosition;\n"
  "uniform vec4 vColor;\n"
  "uniform vec4 vFogColor;\n"
  "in vec2 vTexCoord;   \n"
  "out vec2 textureUV;   \n"
  "out vec4 fogColor;\n"
	"out vec4 vertexColor;\n"
	"void main(void) {\n"
	"	textureUV = vTexCoord;\n"
	"	gl_Position = MS_ModelViewProjectionMatrix * vPosition;\n"
	"	vertexColor = vColor;\n"
	"}\n";
	defaultFragmentPrograms["gamma"] = ""
  "#version 300 es  \n"
  "precision highp float;\n"
  "in highp vec2 textureUV; \n"
	"uniform highp sampler2DRect texture0;\n"
	"uniform float gammaAdjust;\n"
  "out vec4 fragmentColor;\n"
	"void main (void) {\n"
	"	vec4 color0 = textureRect(texture0, textureUV.xy);\n"
	"	fragmentColor = vec4(pow(color0.r, gammaAdjust), pow(color0.g, gammaAdjust), pow(color0.b, gammaAdjust), 1.0);\n"
	"}\n";
	
    defaultVertexPrograms["blur"] = ""
        "#version 300 es  \n"
        "uniform mat4 MS_ModelViewProjectionMatrix;\n"
        "uniform mat4 MS_ModelViewMatrix;\n"
        "in vec4 vPosition;\n"
        "uniform vec4 vColor;\n"
        "uniform vec4 vFogColor;\n"
        "in vec2 vTexCoord;   \n"
        "out vec2 textureUV;   \n"
        "out vec4 fogColor;\n"
        "out vec4 vertexColor;\n"
        "void main(void) {\n"
        "	textureUV = vTexCoord;\n"
        "	gl_Position = MS_ModelViewProjectionMatrix * vPosition;\n"
        "	vertexColor = vColor;\n"
        "}\n";
    defaultFragmentPrograms["blur"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec2 textureUV; \n"
        "uniform highp sampler2D texture0;\n"
        "uniform float offsetx;\n"
        "uniform float offsety;\n"
        "uniform float pass;\n"
        "in vec4 vertexColor;\n"
        "out vec4 fragmentColor;\n"
        "const float f0 = 0.14012035;\n"
        "const float f1 = 0.24122258;\n"
        "const float o1 = 1.45387071;\n"
        "const float f2 = 0.13265595;\n"
        "const float o2 = 3.39370426;\n"
        "const float f3 = 0.04518872;\n"
        "const float o3 = 5.33659787;\n"
        "#ifdef BLOOM_SRGB_FRAMEBUFFER\n"
        "vec3 s2l(vec3 srgb) { return srgb; }\n"
        "vec3 l2s(vec3 linear) { return linear; }\n"
        "#else\n"
        "vec3 s2l(vec3 srgb) { return srgb * srgb; }\n"
        "vec3 l2s(vec3 linear) { return sqrt(linear); }\n"
        "#endif\n"
        " vec2 normalizeRectUV(vec2 rectUV, sampler2D theSampler) { \n "
        " vec2 textureSize = vec2(textureSize(theSampler ,0));\n"
        " return vec2((rectUV.x)/textureSize.x, (rectUV.y)/textureSize.y); }\n"
        "void main (void) {\n"
        "	vec2 s = vec2(offsetx, offsety);\n"
        "	// Thanks to Renaud Bedard - http://theinstructionlimit.com/?p=43\n"
        "	vec3 c = s2l(texture(texture0, normalizeRectUV(textureUV.xy, texture0)).rgb);\n"
        "	vec3 t = f0 * c;\n"
        "	t += f1 * s2l(texture(texture0, normalizeRectUV(textureUV.xy - o1*s, texture0) ).rgb);\n"
        "	t += f1 * s2l(texture(texture0, normalizeRectUV(textureUV.xy + o1*s, texture0) ).rgb);\n"
        "	t += f2 * s2l(texture(texture0, normalizeRectUV(textureUV.xy - o2*s, texture0) ).rgb);\n"
        "	t += f2 * s2l(texture(texture0, normalizeRectUV(textureUV.xy + o2*s, texture0) ).rgb);\n"
        "	t += f3 * s2l(texture(texture0, normalizeRectUV(textureUV.xy - o3*s, texture0) ).rgb);\n"
        "	t += f3 * s2l(texture(texture0, normalizeRectUV(textureUV.xy + o3*s, texture0) ).rgb);\n"
        "	fragmentColor = vec4(l2s(t), 1.0) * vertexColor;\n"
         "}\n";
    
    defaultVertexPrograms["bloom"] = ""
        "#version 300 es  \n"
        "uniform mat4 MS_ModelViewProjectionMatrix;\n"
        "uniform mat4 MS_ModelViewMatrix;\n"
        "in vec4 vPosition;\n"
        "uniform vec4 vColor;\n"
        "uniform vec4 vFogColor;\n"
        "in vec2 vTexCoord;   \n"
        "uniform vec4 vTexCoord4;   \n"
        "out vec2 textureUV;   \n"
        "out vec2 textureUV2;   \n"
        "out vec4 fogColor;\n"
        "out vec4 vertexColor;\n"
        "void main(void) {\n"
        "	textureUV = vTexCoord;\n"
        "	textureUV2 = vTexCoord4.xy;\n"
        "	gl_Position = MS_ModelViewProjectionMatrix * vPosition;\n"
        "	vertexColor = vColor;\n"
        "}\n";
    defaultFragmentPrograms["bloom"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec2 textureUV; \n"
        "in highp vec2 textureUV2; \n"
        "uniform highp sampler2D texture0;\n"
        "uniform highp sampler2D texture1;\n"
        "uniform float pass;\n"
        "in vec4 vertexColor;\n"
        "out vec4 fragmentColor;\n"
        "vec3 s2l(vec3 srgb) { return srgb * srgb; }\n"
        "vec3 l2s(vec3 linear) { return sqrt(linear); }\n"
		"#ifndef BLOOM_SRGB_FRAMEBUFFER\n"
	    "vec3 b2l(vec3 bloom) { return bloom * bloom; }\n"
		"#else\n"
		"vec3 b2l(vec3 bloom) { return bloom; }\n"
        "#endif\n"
        " vec2 normalizeRectUV(vec2 rectUV, sampler2D theSampler) { \n "
        " vec2 textureSize = vec2(textureSize(theSampler ,0));\n"
        " return vec2((rectUV.x)/textureSize.x, (rectUV.y)/textureSize.y); }\n"

        "void main (void) {\n"
        " vec2 normalizedUV = normalizeRectUV(textureUV.xy, texture0);\n"
        "	vec4 color0 = texture(texture0, normalizedUV);\n"
        "	vec4 color1 = texture(texture1, normalizedUV);\n"
        "	vec3 color = l2s(s2l(color0.rgb) + b2l(color1.rgb));\n"
        "	fragmentColor = vec4(color, 1.0);\n"
        "}\n";
    
    defaultVertexPrograms["landscape"] = ""
        "#version 300 es  \n"
        "uniform mat4 MS_ModelViewProjectionMatrix;\n"
        "uniform mat4 MS_ModelViewMatrix;\n"
        "in vec4 vPosition;\n"
        "uniform vec4 vColor;\n"
        "uniform vec4 vFogColor;\n"
        "out vec4 fogColor;\n"
        "uniform mat4 landscapeInverseMatrix;\n"
        "out vec3 relDir;\n"
        "out vec4 vertexColor;\n"
        "void main(void) {\n"
        "	gl_Position = MS_ModelViewProjectionMatrix * vPosition;\n"
        "#ifndef DISABLE_CLIP_VERTEX\n"
//        "	gl_ClipVertex = MS_ModelViewMatrix * vPosition;\n"
        "#endif\n"
        "	relDir = (MS_ModelViewMatrix * vPosition).xyz;\n"
        "	vertexColor = vColor;\n"
        " fogColor = vFogColor;\n"
        "}\n";
    defaultFragmentPrograms["landscape"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec4 fogColor; \n"
        "uniform sampler2D texture0;\n"
        "uniform float usefog;\n"
        "uniform float scalex;\n"
        "uniform float scaley;\n"
        "uniform float offsetx;\n"
        "uniform float offsety;\n"
        "uniform float yaw;\n"
        "uniform float pitch;\n"
        "in vec3 relDir;\n"
        "in vec4 vertexColor;\n"
        "const float zoom = 1.2;\n"
        "const float pitch_adjust = 0.96;\n"
        "out vec4 fragmentColor;\n"
        "void main(void) {\n"
        "	vec3 facev = vec3(cos(yaw), sin(yaw), sin(pitch));\n"
        "	vec3 relv  = (relDir);\n"
        "	float x = relv.x / (relv.z * zoom) + atan(facev.x, facev.y);\n"
        "	float y = relv.y / (relv.z * zoom) - (facev.z * pitch_adjust);\n"
        "	vec4 color = texture(texture0, vec2(offsetx - x * scalex, offsety - y * scaley));\n"
        "	vec3 intensity = color.rgb;\n"
        "	if (usefog > 0.0) {\n"
        "		intensity = fogColor.rgb;\n"
        "	}\n"
        "	fragmentColor = vec4(intensity, 1.0);\n"
        "}\n";
    defaultVertexPrograms["landscape_bloom"] = defaultVertexPrograms["landscape"];
    defaultFragmentPrograms["landscape_bloom"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec4 fogColor; \n"
        "uniform mat4 MS_ModelViewProjectionMatrix;\n"
        "uniform mat4 MS_ModelViewMatrix;\n"
        "uniform sampler2D texture0;\n"
        "uniform float usefog;\n"
        "uniform float scalex;\n"
        "uniform float scaley;\n"
        "uniform float offsetx;\n"
        "uniform float offsety;\n"	
        "uniform float yaw;\n"
        "uniform float pitch;\n"
        "uniform float bloomScale;\n"
        "in vec3 relDir;\n"
        "in vec4 vertexColor;\n"
        "const float zoom = 1.205;\n"
        "const float pitch_adjust = 0.955;\n"
        "out vec4 fragmentColor;\n"
        "void main(void) {\n"
        "	vec3 facev = vec3(cos(yaw), sin(yaw), sin(pitch));\n"
        "	vec3 relv  = normalize(relDir);\n"
        "	float x = relv.x / (relv.z * zoom) + atan(facev.x, facev.y);\n"
        "	float y = relv.y / (relv.z * zoom) - (facev.z * pitch_adjust);\n"
        "	vec4 color = texture(texture0, vec2(offsetx - x * scalex, offsety - y * scaley));\n"
        "	float intensity = clamp(bloomScale, 0.0, 1.0);\n"
        "	if (usefog > 0.0) {\n"
        "		intensity = 0.0;\n"
        "	}\n"
        "#ifdef GAMMA_CORRECTED_BLENDING\n"
        "	//intensity = intensity * intensity;\n"
        "	color.rgb = (color.rgb - 0.01) * 1.01;\n"
        "#else\n"
        "	color.rgb = (color.rgb - 0.1) * 1.11;\n"
        "#endif\n"
        "	fragmentColor = vec4(color.rgb * intensity, 1.0);\n"
        "}\n";
	
    defaultVertexPrograms["sprite"] = ""
        "#version 300 es  \n"
        "uniform mat4 MS_ModelViewProjectionMatrix;\n"
        "uniform mat4 MS_ModelViewMatrix;\n"
        "uniform mat4 MS_ModelViewMatrixInverse;\n"
        "uniform mat4 MS_TextureMatrix;\n"
        "in vec4 vPosition;\n"
        "uniform vec4 vColor;\n"
        "uniform vec4 vFogColor;\n"
        "in vec2 vTexCoord;   \n"
        "out vec2 textureUV;   \n"
        "out vec4 fogColor;\n"
  
        "uniform float depth;\n"
        "uniform float strictDepthMode;\n"
        "out vec3 viewDir;\n"
        "out vec4 vertexColor;\n"
        "out float FDxLOG2E;\n"
        "out float classicDepth;\n"
        "out vec4 vPosition_eyespace;\n"
  
        "void main(void) {\n"
        " vPosition_eyespace = MS_ModelViewMatrix * vPosition;\n"
        "	gl_Position = MS_ModelViewProjectionMatrix * vPosition;\n"
        "	classicDepth = gl_Position.z / 8192.0;\n"
        "#ifndef DISABLE_CLIP_VERTEX\n"
//        "	gl_ClipVertex = MS_ModelViewMatrix * vPosition;\n"
        "#endif\n"
        "	vec4 v = MS_ModelViewMatrixInverse * vec4(0.0, 0.0, 0.0, 1.0);\n"
        "	viewDir = (vPosition - v).xyz;\n"
        " vec4 UV4 = vec4(vTexCoord.x, vTexCoord.y, 0.0, 1.0);\n"           //DCW shitty attempt to stuff texUV into a vec4
        "	textureUV = (MS_TextureMatrix * UV4).xy;\n"
        "	vertexColor = vColor;\n"
        "	FDxLOG2E = -vFogColor.a * 1.442695;\n"
        " fogColor = vFogColor;\n" //DCW maybe unused.
        "}\n";    
    defaultFragmentPrograms["sprite"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec4 fogColor; \n"
        "in highp vec2 textureUV; \n"
        "uniform sampler2D texture0;\n"
        "uniform float glow;\n"
        "uniform float flare;\n"
        "uniform float selfLuminosity;\n"
        "uniform vec4 clipPlane0;"
        "uniform vec4 clipPlane1;"
        "uniform vec4 clipPlane5;"
        "uniform vec4 mediaPlane;"
        "in vec3 viewDir;\n"
        "in vec4 vertexColor;\n"
        "in float FDxLOG2E;\n"
        "in float classicDepth;\n"
        "in vec4 vPosition_eyespace;\n"
        "out vec4 fragmentColor;\n"

        "void main (void) {\n"
        " if( dot( vPosition_eyespace, clipPlane0) < 0.0 ) {discard;}\n"
        " if( dot( vPosition_eyespace, clipPlane1) < 0.0 ) {discard;}\n"
        " if( dot( vPosition_eyespace, clipPlane5) < 0.0 ) {discard;}\n"

        "	float mlFactor = clamp(selfLuminosity + flare - classicDepth, 0.0, 1.0);\n"
        "	// more realistic: replace classicDepth with (length(viewDir)/8192.0)\n"
        "	vec3 intensity;\n"
        "	if (vertexColor.r > mlFactor) {\n"
        "		intensity = vertexColor.rgb + (mlFactor * 0.5); }\n"
        "	else {\n"
        "		intensity = (vertexColor.rgb * 0.5) + mlFactor; }\n"
        "	intensity = clamp(intensity, glow, 1.0);\n"
        "#ifdef GAMMA_CORRECTED_BLENDING\n"
        "	intensity = intensity * intensity; // approximation of pow(intensity, 2.2)\n"
        "#endif\n"
        "	vec4 color = texture(texture0, textureUV.xy);\n"
        "	float fogFactor = clamp(exp2(FDxLOG2E * length(viewDir)), 0.0, 1.0);\n"
        " fragmentColor = vec4(mix(fogColor.rgb, color.rgb * intensity, fogFactor), vertexColor.a * color.a);\n"
        " if ( fragmentColor.a == 0.0 ) {discard;} //discard transparent fragments so they don't write on the depth buffer \n "
        " vec4 mediaTint = vec4(0.0, 0.6, 1.0, 1.0);"
        " if( dot( vPosition_eyespace, mediaPlane) < 0.0 ) {\n"
        " fragmentColor.rgb -= 0.2 * (vec3(1.0) - mediaTint.rgb);\n"
        "   fragmentColor.rgb = mix(fragmentColor.rgb, mediaTint.rgb,  pow(gl_FragCoord.z, 100.0)); }\n"
         "}\n";
    defaultVertexPrograms["sprite_bloom"] = defaultVertexPrograms["sprite"];
    defaultFragmentPrograms["sprite_bloom"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec4 fogColor; \n"
        "in highp vec2 textureUV; \n"
        "uniform sampler2D texture0;\n"
        "uniform float glow;\n"
        "uniform float bloomScale;\n"
        "uniform float bloomShift;\n"
        "uniform vec4 clipPlane0;"
        "uniform vec4 clipPlane1;"
        "uniform vec4 clipPlane5;"
        "uniform vec4 mediaPlane;"
        "in vec3 viewDir;\n"
        "in vec4 vertexColor;\n"
        "in float FDxLOG2E;\n"
        "in float classicDepth;\n"
        "in vec4 vPosition_eyespace;\n"
        "out vec4 fragmentColor;\n"
        "void main (void) {\n"
        " if( dot( vPosition_eyespace, clipPlane0) < 0.0 ) {discard;}\n"
        " if( dot( vPosition_eyespace, clipPlane1) < 0.0 ) {discard;}\n"
        " if( dot( vPosition_eyespace, clipPlane5) < 0.0 ) {discard;}\n"

        "	vec4 color = texture(texture0, textureUV.xy);\n"
        "	vec3 intensity = clamp(vertexColor.rgb, glow, 1.0);\n"
        "	//intensity = intensity * clamp(2.0 - length(viewDir)/8192.0, 0.0, 1.0);\n"
        "	intensity = clamp(intensity * bloomScale + bloomShift, 0.0, 1.0);\n"
        "#ifdef GAMMA_CORRECTED_BLENDING\n"
        "	intensity = intensity * intensity;  // approximation of pow(intensity, 2.2)\n"
        "	color.rgb = (color.rgb - 0.06) * 1.02;\n"
        "#else\n"
        "  color.rgb = (color.rgb - 0.2) * 1.25;\n"
        "#endif\n"
        "	float fogFactor = clamp(exp2(FDxLOG2E * length(viewDir)), 0.0, 1.0);\n"
        "	fragmentColor = vec4(mix(vec3(0.0, 0.0, 0.0), color.rgb * intensity, fogFactor), vertexColor.a * color.a);\n"
        " if ( fragmentColor.a == 0.0 ) {discard;} //discard transparent fragments so they don't write on the depth buffer \n "
        " if( dot( vPosition_eyespace, mediaPlane) < 0.0 ) {fragmentColor.g-=pow(gl_FragCoord.z, 100.0); fragmentColor.r-=pow(gl_FragCoord.z, 100.0);}\n"
        "}\n";
    
    defaultVertexPrograms["invincible"] = defaultVertexPrograms["sprite"];
    defaultFragmentPrograms["invincible"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec4 fogColor; \n"
        "in highp vec2 textureUV; \n"
        "uniform sampler2D texture0;\n"
        "uniform float time;\n"
        "uniform float usestatic;\n"
        "in vec3 viewDir;\n"
        "in vec4 vertexColor;\n"
        "in float FDxLOG2E;\n"
        "out vec4 fragmentColor;\n"
        "void main(void) {\n"
        "	float a = fract(sin(usestatic*(textureUV.x * 133.0 + textureUV.y * 471.0) + time * 7.0) * 43757.0); \n"
        "	float b = fract(sin(usestatic*(textureUV.x * 2331.0 + textureUV.y * 63.0) + time * 3.0) * 32451.0); \n"
        "	float c = fract(sin(usestatic*(textureUV.x * 41.0 + textureUV.y * 12911.0) + time * 31.0) * 34563.0);\n"
        "	vec4 color = texture(texture0, textureUV.xy);\n"
        "	vec3 intensity = vec3(a, b, c);\n"
        "#ifdef GAMMA_CORRECTED_BLENDING\n"
        "	intensity = intensity * intensity;  // approximation of pow(intensity, 2.2)\n"
        "#endif\n"
        "	float fogFactor = clamp(exp2(FDxLOG2E * length(viewDir)), 0.0, 1.0);\n"
        "	fragmentColor = vec4(mix(fogColor.rgb, intensity, fogFactor), vertexColor.a * color.a);\n"
        "}\n";
    defaultVertexPrograms["invincible_bloom"] = defaultVertexPrograms["invincible"];
    defaultFragmentPrograms["invincible_bloom"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec4 fogColor; \n"
        "in highp vec2 textureUV; \n"
        "uniform sampler2D texture0;\n"
        "uniform float time;\n"
        "uniform float usestatic;\n"
        "uniform float bloomScale;\n"
        "uniform float bloomShift;\n"
        "in vec3 viewDir;\n"
        "in vec4 vertexColor;\n"
        "in float FDxLOG2E;\n"
        "out vec4 fragmentColor;\n"
        "void main(void) {\n"
        "	vec4 color = texture(texture0, textureUV.xy);\n"
        "	vec3 intensity = vec3(0.0, 0.0, 0.0);\n"
        "	float fogFactor = exp2(FDxLOG2E * length(viewDir));\n"
        "	fragmentColor = vec4(mix(vec3(0.0, 0.0, 0.0), intensity, fogFactor), vertexColor.a * color.a);\n"
        "}\n";
    
    defaultVertexPrograms["invisible"] = defaultVertexPrograms["sprite"];
    defaultFragmentPrograms["invisible"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec4 fogColor; \n"
        "in highp vec2 textureUV; \n"
        "uniform sampler2D texture0;\n"
        "uniform float visibility;\n"
        "in vec3 viewDir;\n"
        "in vec4 vertexColor;\n"
        "in float FDxLOG2E;\n"
        "out vec4 fragmentColor;\n"
        "void main(void) {\n"
        "	vec4 color = texture(texture0, textureUV.xy);\n"
        "   vec3 intensity = vec3(0.0, 0.0, 0.0);\n"
        "	float fogFactor = clamp(exp2(FDxLOG2E * length(viewDir)), 0.0, 1.0);\n"
        "	fragmentColor = vec4(mix(fogColor.rgb, intensity, fogFactor), vertexColor.a * color.a * visibility);\n"
        "}\n";
    defaultVertexPrograms["invisible_bloom"] = defaultVertexPrograms["invisible"];
    defaultFragmentPrograms["invisible_bloom"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec2 textureUV; \n"
        "uniform sampler2D texture0;\n"
        "uniform float visibility;\n"
        "in vec3 viewDir;\n"
        "in vec4 vertexColor;\n"
        "in float FDxLOG2E;\n"
        "out vec4 fragmentColor;\n"
        "void main(void) {\n"
        "	vec4 color = texture(texture0, textureUV.xy);\n"
        "   vec3 intensity = vec3(0.0, 0.0, 0.0);\n"
        "	float fogFactor = clamp(exp2(FDxLOG2E * length(viewDir)), 0.0, 1.0);\n"
        "	fragmentColor = vec4(mix(vec3(0.0, 0.0, 0.0), intensity, fogFactor), vertexColor.a * color.a * visibility);\n"
        "}\n";
	
    defaultVertexPrograms["wall"] = ""
        "#version 300 es  \n"
        "uniform mat4 MS_ModelViewProjectionMatrix;\n"
        "uniform mat4 MS_ModelViewMatrix;\n"
        "uniform mat4 MS_ModelViewMatrixInverse;\n"
        "uniform mat4 MS_TextureMatrix;\n"
        "in vec4 vPosition;\n"
        "uniform vec4 vColor;\n"
        "uniform vec4 vFogColor;\n"
        "in vec2 vTexCoord;   \n"
        "in vec3 vNormal;   \n"
        "uniform vec4 vTexCoord4;   \n"
        "out vec2 textureUV2;   \n"
        "out vec2 textureUV;   \n"
        "out vec4 fogColor;\n"
        "out vec3 normal;\n"
        "uniform float depth;\n"
        "out vec3 viewXY;\n"
        "out vec3 viewDir;\n"
        "out vec4 vertexColor;\n"
        "out float FDxLOG2E;\n"
        "out float classicDepth;\n"
        "out vec4 vPosition_eyespace;\n"
        "void main(void) {\n"
        " vPosition_eyespace = MS_ModelViewMatrix * vPosition;\n"
        "	gl_Position  = MS_ModelViewProjectionMatrix * vPosition;\n"
        "	gl_Position.z = gl_Position.z + depth*gl_Position.z/65536.0;\n"
        "	classicDepth = gl_Position.z / 8192.0;\n"
        "#ifndef DISABLE_CLIP_VERTEX\n"
//        "	gl_ClipVertex = MS_ModelViewMatrix * vPosition;\n"
        "#endif\n"
        " vec4 UV4 = vec4(vTexCoord.x, vTexCoord.y, 0.0, 1.0);\n"           //DCW shitty attempt to stuff texUV into a vec4
        " mat3 normalMatrix = mat3(transpose(MS_ModelViewMatrixInverse));\n"           //DCW shitty replacement for gl_NormalMatrix
        "  textureUV = (MS_TextureMatrix * UV4).xy;\n"
        "	/* SETUP TBN MATRIX in normal matrix coords, vTexCoord4 = tangent vector */\n"
        "	vec3 n = normalize(normalMatrix * vNormal);\n"
        "	vec3 t = normalize(normalMatrix * vTexCoord4.xyz);\n"
        "	vec3 b = normalize(cross(n, t) * vTexCoord4.w);\n"
        "	/* (column wise) */\n"
        "	mat3 tbnMatrix = mat3(t.x, b.x, n.x, t.y, b.y, n.y, t.z, b.z, n.z);\n"
        "	\n"
        "	/* SETUP VIEW DIRECTION in unprojected local coords */\n"
        "	viewDir = tbnMatrix * (MS_ModelViewMatrix * vPosition).xyz;\n"
        "	viewXY = -(MS_TextureMatrix * vec4(viewDir.xyz, 1.0)).xyz;\n"
        "	viewDir = -viewDir;\n"
        "	vertexColor = vColor;\n"
        "	FDxLOG2E = -(1.0-vFogColor.a) * 1.442695;\n" //dcw that 1- may be wrong.
        " fogColor = vFogColor;"
        "}\n";
    defaultFragmentPrograms["wall"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec4 fogColor; \n"
        "in highp vec2 textureUV; \n"
        "uniform sampler2D texture0;\n"
        "uniform float pulsate;\n"
        "uniform float wobble;\n"
        "uniform float glow;\n"
        "uniform float flare;\n"
        "uniform float selfLuminosity;\n"
        "uniform vec4 mediaPlane;"
        "in vec3 viewXY;\n"
        "in vec3 viewDir;\n"
        "in vec4 vertexColor;\n"
        "in float FDxLOG2E;\n"
        "in float classicDepth;\n"
        "in vec4 vPosition_eyespace;\n"
        "out vec4 fragmentColor;\n"
        "void main (void) {\n"
        "	vec3 texCoords = vec3(textureUV.xy, 0.0);\n"
        "	vec3 normXY = normalize(viewXY);\n"
        "	texCoords += vec3(normXY.y * -pulsate, normXY.x * pulsate, 0.0);\n"
        "	texCoords += vec3(normXY.y * -wobble * texCoords.y, wobble * texCoords.y, 0.0);\n"
        "	float mlFactor = clamp(selfLuminosity + flare - classicDepth, 0.0, 1.0);\n"
        "	// more realistic: replace classicDepth with (length(viewDir)/8192.0)\n"
        "	vec3 intensity;\n"
        "	if (vertexColor.r > mlFactor) {\n"
        "		intensity = vertexColor.rgb + (mlFactor * 0.5); }\n"
        "	else {\n"
        "		intensity = (vertexColor.rgb * 0.5) + mlFactor; }\n"
        "	intensity = clamp(intensity, glow, 1.0);\n"
        "#ifdef GAMMA_CORRECTED_BLENDING\n"
        "	intensity = intensity * intensity; // approximation of pow(intensity, 2.2)\n"
        "#endif\n"
        "	vec4 color = texture(texture0, texCoords.xy);\n"
        "	float fogFactor = clamp(exp2(FDxLOG2E * length(viewDir)), 0.0, 1.0);\n"
        "fogFactor=clamp( length(viewDir), 0.0, 1.0);\n" //dcw shit test
        "	fragmentColor = vec4(mix(fogColor.rgb, color.rgb * intensity, fogFactor), vertexColor.a * color.a);\n"
  
  //dcw shit test
        " vec4 mediaTint = vec4(0.0, 0.6, 1.0, 1.0);"
        " if( dot( vPosition_eyespace, mediaPlane) < 0.0 ) {\n"
        "   fragmentColor.rgb -= 0.2 * (vec3(1.0) - mediaTint.rgb);\n"
        "   fragmentColor= mix(fragmentColor, mediaTint,  pow(gl_FragCoord.z, 100.0)); }\n"
        "}\n";
    defaultVertexPrograms["wall_bloom"] = defaultVertexPrograms["wall"];
    defaultFragmentPrograms["wall_bloom"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec2 textureUV; \n"
        "uniform sampler2D texture0;\n"
        "uniform float pulsate;\n"
        "uniform float wobble;\n"
        "uniform float glow;\n"
        "uniform float flare;\n"
        "uniform float bloomScale;\n"
        "uniform float bloomShift;\n"
        "in vec3 viewXY;\n"
        "in vec3 viewDir;\n"
        "in vec4 vertexColor;\n"
        "in float FDxLOG2E;\n"
        "out vec4 fragmentColor;\n"
        "void main (void) {\n"
        "	vec3 texCoords = vec3(textureUV.xy, 0.0);\n"
        "	vec3 normXY = normalize(viewXY);\n"
        "	texCoords += vec3(normXY.y * -pulsate, normXY.x * pulsate, 0.0);\n"
        "	texCoords += vec3(normXY.y * -wobble * texCoords.y, wobble * texCoords.y, 0.0);\n"
        "	vec4 color = texture(texture0, texCoords.xy);\n"
        "	vec3 intensity = clamp(vertexColor.rgb, glow, 1.0);\n"
        "	float diffuse = abs(dot(vec3(0.0, 0.0, 1.0), normalize(viewDir)));\n"
        "	intensity = clamp(intensity * bloomScale + bloomShift, 0.0, 1.0);\n"
        "#ifdef GAMMA_CORRECTED_BLENDING\n"
        "	intensity = intensity * intensity; // approximation of pow(intensity, 2.2)\n"
        "#endif\n"
        "	float fogFactor = clamp(exp2(FDxLOG2E * length(viewDir)), 0.0, 1.0);\n"
        "	fragmentColor = vec4(mix(vec3(0.0, 0.0, 0.0), color.rgb * intensity, fogFactor), vertexColor.a * color.a);\n"
  //dcw shit test
  "  fragmentColor = vec4(mix(vec3(0.0, 0.0, 0.0), color.rgb * intensity, 1.0), vertexColor.a * color.a);\n"

        "}\n";
    
    defaultVertexPrograms["bump"] = defaultVertexPrograms["wall"];
    defaultFragmentPrograms["bump"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec4 fogColor; \n"
        "in highp vec2 textureUV; \n"
        "uniform sampler2D texture0;\n"
        "uniform sampler2D texture1;\n"
        "uniform float pulsate;\n"
        "uniform float wobble;\n"
        "uniform float glow;\n"
        "uniform float flare;\n"
        "uniform float selfLuminosity;\n"
        "in vec3 viewXY;\n"
        "in vec3 viewDir;\n"
        "in vec4 vertexColor;\n"
        "in float FDxLOG2E;\n"
        "out vec4 fragmentColor;\n"
        "void main (void) {\n"
        "	vec3 texCoords = vec3(textureUV.xy, 0.0);\n"
        "	vec3 normXY = normalize(viewXY);\n"
        "	texCoords += vec3(normXY.y * -pulsate, normXY.x * pulsate, 0.0);\n"
        "	texCoords += vec3(normXY.y * -wobble * texCoords.y, wobble * texCoords.y, 0.0);\n"
        "	float mlFactor = clamp(selfLuminosity + flare - (length(viewDir)/8192.0), 0.0, 1.0);\n"
        "	vec3 intensity;\n"
        "	if (vertexColor.r > mlFactor) {\n"
        "		intensity = vertexColor.rgb + (mlFactor * 0.5); }\n"
        "	else {\n"
        "		intensity = (vertexColor.rgb * 0.5) + mlFactor; }\n"
        "	vec3 viewv = normalize(viewDir);\n"
        "	// iterative parallax mapping\n"
        "	float scale = 0.010;\n"
        "	float bias = -0.005;\n"
        "	for(int i = 0; i < 4; ++i) {\n"
        "		vec4 normal = texture(texture1, texCoords.xy);\n"
        "		float h = normal.a * scale + bias;\n"
        "		texCoords.x += h * viewv.x;\n"
        "		texCoords.y -= h * viewv.y;\n"
        "	}\n"
        "	vec3 norm = (texture(texture1, texCoords.xy).rgb - 0.5) * 2.0;\n"
        "	float diffuse = 0.5 + abs(dot(norm, viewv))*0.5;\n"
        "   if (glow > 0.001) {\n"
        "       diffuse = 1.0;\n"
        "   }\n"
        "	vec4 color = texture(texture0, texCoords.xy);\n"
        "	intensity = clamp(intensity * diffuse, glow, 1.0);\n"
        "#ifdef GAMMA_CORRECTED_BLENDING\n"
        "	intensity = intensity * intensity; // approximation of pow(intensity, 2.2)\n"
        "#endif\n"
        "	float fogFactor = clamp(exp2(FDxLOG2E * length(viewDir)), 0.0, 1.0);\n"
        "	fragmentColor = vec4(mix(fogColor.rgb, color.rgb * intensity, fogFactor), vertexColor.a * color.a);\n"
        "}\n";
    defaultVertexPrograms["bump_bloom"] = defaultVertexPrograms["bump"];
    defaultFragmentPrograms["bump_bloom"] = ""
        "#version 300 es  \n"
        "precision highp float;\n"
        "in highp vec2 textureUV; \n"
        "uniform sampler2D texture0;\n"
        "uniform sampler2D texture1;\n"
        "uniform float pulsate;\n"
        "uniform float wobble;\n"
        "uniform float glow;\n"
        "uniform float flare;\n"
        "uniform float bloomScale;\n"
        "uniform float bloomShift;\n"
        "in vec3 viewXY;\n"
        "in vec3 viewDir;\n"
        "in vec4 vertexColor;\n"
        "in float FDxLOG2E;\n"
        "out vec4 fragmentColor;\n"
        "void main (void) {\n"
        "	vec3 texCoords = vec3(textureUV.xy, 0.0);\n"
        "	vec3 normXY = normalize(viewXY);\n"
        "	texCoords += vec3(normXY.y * -pulsate, normXY.x * pulsate, 0.0);\n"
        "	texCoords += vec3(normXY.y * -wobble * texCoords.y, wobble * texCoords.y, 0.0);\n"
        "	vec3 viewv = normalize(viewDir);\n"
        "	// iterative parallax mapping\n"
        "	float scale = 0.010;\n"
        "	float bias = -0.005;\n"
        "	for(int i = 0; i < 4; ++i) {\n"
        "		vec4 normal = texture(texture1, texCoords.xy);\n"
        "		float h = normal.a * scale + bias;\n"
        "		texCoords.x += h * viewv.x;\n"
        "		texCoords.y -= h * viewv.y;\n"
        "	}\n"
        "	vec3 norm = (texture(texture1, texCoords.xy).rgb - 0.5) * 2.0;\n"
        "	float diffuse = 0.5 + abs(dot(norm, viewv))*0.5;\n"
        "   if (glow > 0.001) {\n"
        "       diffuse = 1.0;\n"
        "   }\n"
        "	vec4 color = texture(texture0, texCoords.xy);\n"
        "	vec3 intensity = clamp(vertexColor.rgb, glow, 1.0);\n"
        "	intensity = clamp(intensity * bloomScale + bloomShift, 0.0, 1.0);\n"
        "#ifdef GAMMA_CORRECTED_BLENDING\n"
        "	intensity = intensity * intensity; // approximation of pow(intensity, 2.2)\n"
        "#endif\n"
        "	float fogFactor = clamp(exp2(FDxLOG2E * length(viewDir)), 0.0, 1.0);\n"
        "	fragmentColor = vec4(mix(vec3(0.0, 0.0, 0.0), color.rgb * intensity, fogFactor), vertexColor.a * color.a);\n"
        "}\n";
}
    
