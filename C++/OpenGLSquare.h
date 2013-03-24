//
// Created by shawn on 3/22/13.
//
// OpenGL Square header files
//



#ifndef __OpenGLSquare_H_
#define __OpenGLSquare_H_

#include <iostream>
#include <string>
#ifdef __ANDROID__
  #include <GLES2/gl2.h>
#elif __IPHONE_OS_VERSION_MIN_REQUIRED
#include <OpenGLES/ES2/gl.h>
#elif __WIN32
#include "pch.h"
#elif __WIN64
#include "pch.h"
#else
  #include <GL/glew.h>
#endif


class OpenGLSquare {
public:
    void init(int width, int height, char* vShader, char* fShader);
    void step();
};


#endif //__OpenGLSquare_H_
