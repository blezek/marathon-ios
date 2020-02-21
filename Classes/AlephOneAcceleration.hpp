//
//  AlephOneAcceleration.hpp
//  AlephOne
//
//  Created by Dustin Wenz on 2/17/20.
//  Copyright © 2020 SDG Productions. All rights reserved.
//

#include "SDL.h"

#ifndef AlephOneAcceleration_hpp
#define AlephOneAcceleration_hpp

// Cribbed from OpenGL ClearBufferMask
#define AOA_DEPTH_BUFFER_BIT                              0x00000100
#define AOA_STENCIL_BUFFER_BIT                            0x00000400
#define AOA_COLOR_BUFFER_BIT                              0x00004000

// Cribbed from glext.h
#define AOA_FRAGMENT_SHADER                0x8B30
#define AOA_VERTEX_SHADER                  0x8B31
#define AOA_DELETE_STATUS                  0x8B80
#define AOA_COMPILE_STATUS                 0x8B81
#define AOA_LINK_STATUS                    0x8B82
#define AOA_VALIDATE_STATUS                0x8B83
#define AOA_INFO_LOG_LENGTH                0x8B84
#define AOA_GENERATE_MIPMAP_SGIS           0x8191
#define AOA_GENERATE_MIPMAP                0x8191
#define AOA_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG                     0x8C02
#define AOA_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG                     0x8C03
#define AOA_COMPRESSED_RGBA_S3TC_DXT1_EXT  0x83F1
#define AOA_COMPRESSED_RGBA_S3TC_DXT3_EXT  0x83F2
#define AOA_COMPRESSED_RGBA_S3TC_DXT5_EXT  0x83F3
#define AOA_COMPRESSED_SRGB_S3TC_DXT1_EXT  0x8C4C
#define AOA_COMPRESSED_RGB_S3TC_DXT1_EXT   0x83F0
#define AOA_COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT 0x8C4E
#define AOA_COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT 0x8C4F
#define AOA_TEXTURE_MAX_ANISOTROPY_EXT                           0x84FE
#define AOA_MAX_TEXTURE_MAX_ANISOTROPY_EXT                       0x84FF
#define AOA_CLAMP_TO_EDGE                  0x812F

// Cribbed from gl.h
#define AOA_BYTE                                          0x1400
#define AOA_UNSIGNED_BYTE                                 0x1401
#define AOA_SHORT                                         0x1402
#define AOA_UNSIGNED_SHORT                                0x1403
#define AOA_INT                                           0x1404
#define AOA_UNSIGNED_INT                                  0x1405
#define AOA_FLOAT                                         0x1406
#define AOA_FIXED                                         0x140C
#define AOA_FALSE                                         0
#define AOA_TRUE                                          1
#define AOA_POINTS                                        0x0000
#define AOA_LINES                                         0x0001
#define AOA_LINE_LOOP                                     0x0002
#define AOA_LINE_STRIP                                    0x0003
#define AOA_TRIANGLES                                     0x0004
#define AOA_TRIANGLE_STRIP                                0x0005
#define AOA_TRIANGLE_FAN                                  0x0006
#define AOA_TEXTURE_2D                                    0x0DE1
#define AOA_CULL_FACE                                     0x0B44
#define AOA_BLEND                                         0x0BE2
#define AOA_DITHER                                        0x0BD0
#define AOA_STENCIL_TEST                                  0x0B90
#define AOA_DEPTH_TEST                                    0x0B71
#define AOA_TEXTURE_MAG_FILTER                            0x2800
#define AOA_TEXTURE_MIN_FILTER                            0x2801
#define AOA_TEXTURE_WRAP_S                                0x2802
#define AOA_TEXTURE_WRAP_T                                0x2803
#define AOA_NEAREST                                       0x2600
#define AOA_LINEAR                                        0x2601
#define AOA_NEAREST_MIPMAP_NEAREST                        0x2700
#define AOA_LINEAR_MIPMAP_NEAREST                         0x2701
#define AOA_NEAREST_MIPMAP_LINEAR                         0x2702
#define AOA_LINEAR_MIPMAP_LINEAR                          0x2703
#define AOA_RGBA8                                         0x8058
#define AOA_DEPTH_COMPONENT                               0x1902
#define AOA_ALPHA                                         0x1906
#define AOA_RGB                                           0x1907
#define AOA_RGBA                                          0x1908
#define AOA_RGBA4                                         0x8056
#define AOA_RGB5_A1                                       0x8057
#define AOA_SRGB                                          0x8C40
#define AOA_LUMINANCE                                     0x1909
#define AOA_LUMINANCE_ALPHA                               0x190A
#define AOA_TEXTURE_MAG_FILTER                            0x2800
#define AOA_TEXTURE_MIN_FILTER                            0x2801
#define AOA_TEXTURE_WRAP_S                                0x2802
#define AOA_TEXTURE_WRAP_T                                0x2803
#define AOA_TEXTURE                                       0x1702
#define AOA_MAX_TEXTURE_SIZE                              0x0D33
#define AOA_TEXTURE_ENV                                   0x2300
#define AOA_TEXTURE_ENV_MODE               0x2200
#define AOA_MODULATE                       0x2100
#define AOA_REPEAT                                        0x2901
#define AOA_CLAMP_TO_EDGE                                 0x812F
#define AOA_MIRRORED_REPEAT                               0x8370


typedef char      AOAcharARB;
typedef char      AOAchar;
typedef uint32_t  AOAbitfield;
typedef uint8_t   AOAboolean;
typedef int8_t    AOAbyte;
typedef float     AOAclampf;
typedef uint32_t  AOAenum;
typedef float     AOAfloat;
typedef int32_t   AOAint;
typedef int16_t   AOAshort;
typedef int32_t   AOAsizei;
typedef uint8_t   AOAubyte;
typedef uint32_t  AOAuint;
typedef uint16_t  AOAushort;
typedef void      AOAvoid;

#include <stdio.h>

class AOA{
public:
  static AOA* Instance();
  
  static bool useBGFX();
  static void pushGroupMarker(AOAsizei length, const char *marker);
  static void popGroupMarker(void);
  static void clearColor (AOAfloat red, AOAfloat green, AOAfloat blue, AOAfloat alpha);
  static void clear (uint32_t maskField);
  static AOAuint createProgram (void);
  static AOAuint createShader (AOAenum type);
  static void linkProgram (AOAuint program);
  static void shaderSource (AOAuint shader, AOAsizei count, const AOAchar *const*string, const AOAint *length);
  static void useProgram (AOAuint program);
  static void compileShader (AOAuint shader);
  static void attachShader (AOAuint program, AOAuint shader);
  static void deleteShader (AOAuint shader);
  static void bindAttribLocation (AOAuint program, AOAuint index, const AOAchar *name);
  static void getProgramiv (AOAuint program, AOAenum pname, AOAint *params);
  static void getProgramInfoLog (AOAuint program, AOAsizei bufSize, AOAsizei *length, AOAchar *infoLog);
  static void deleteProgram (AOAuint program);
  static void uniform4f (AOAint location, AOAfloat v0, AOAfloat v1, AOAfloat v2, AOAfloat v3);
  static void uniform1i (AOAint location, AOAint v0);
  static AOAint getUniformLocation (AOAuint program, const AOAchar *name);
  static void uniformMatrix4fv (AOAint location, AOAsizei count, AOAboolean transpose, const AOAfloat *value);
  static void vertexAttribPointer (AOAuint index, AOAint size, AOAenum type, AOAboolean normalized, AOAsizei stride, const void *pointer);
  static void enableVertexAttribArray (AOAuint index);
  static void drawElements (AOAenum mode, AOAsizei count, AOAenum type, const AOAvoid* indices);
  static void genTextures (AOAsizei n, AOAuint* textures);
  static void bindTexture (AOAenum target, AOAuint texture);
  static void deleteTextures (AOAsizei n, const AOAuint* textures);
  static void texEnvi (AOAenum target, AOAenum pname, AOAint param);
  static void texParameteri (AOAenum target, AOAenum pname, AOAint param);
  static void texImage2D (AOAenum target, AOAint level, AOAint internalformat, AOAsizei width, AOAsizei height, AOAint border, AOAenum format, AOAenum type, const AOAvoid* pixels);
  static void compressedTexImage2D (AOAenum target, AOAint level, AOAenum internalformat, AOAsizei width, AOAsizei height, AOAint border, AOAsizei imageSize, const void *data);
  static void getIntegerv (AOAenum pname, AOAint* params);
  static void getGetFloatv (AOAenum pname, AOAfloat* params);
  
  
private:
  AOA(){
    //INIT
    
  };
  
  AOA(AOA const&){};
  AOA& operator=(AOA const&){};
  static AOA* m_pInstance;
  
};

#endif /* AlephOneAcceleration_hpp */
