//
//  esUtil.h
//  AlephOne
//
//  Created by Dustin Wenz on 2/20/18.
//  Copyright © 2018 SDG Productions. All rights reserved.
//


//
// Book:      OpenGL(R) ES 2.0 Programming Guide
// Authors:   Aaftab Munshi, Dan Ginsburg, Dave Shreiner
// ISBN-10:   0321502795
// ISBN-13:   9780321502797
// Publisher: Addison-Wesley Professional
// URLs:      http://safari.informit.com/9780321563835
//            http://www.opengles-book.com
// Additional contributions copyright (c) 2011 Research In Motion Limited

// esUtil.h
//
//    A utility library for OpenGL ES.  This library provides a
//    basic common framework for the example applications in the
//    OpenGL ES 2.0 Programming Guide.
//
#ifndef ESUTIL_H
#define ESUTIL_H

///
//  Includes
//
#include <stdio.h>
#include <string.h>
//#include <GLES2/gl2.h>
//#include <EGL/egl.h>

#include <stdlib.h>
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>

#ifdef __cplusplus

extern "C" {
#endif
  

//Initializes shader programs. Should be called once prior to drawing.
int InitES2Quads();

//Intended as a shader-based worklalike for OGL_RenderTexturedRect.
//Stuff like clearing the context, setting matrix state (via MatrixStack), and buffer swap should be handled outside of this drawing function.
//Note: no texture transformations are done here, so you must do that prior to calling, if needed.
void DrawQuad(float x, float y, float w, float h, float tleft, float ttop, float tright, float tbottom);
  
//Bind to on-screen drawable framebuffer
void bindDrawable();
  
#ifdef __cplusplus
}
#endif

#endif // ESUTIL_H
