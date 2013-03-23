//
// Created by shawn on 3/22/13.
//
// To change the template use AppCode | Preferences | File Templates.
//



#ifndef __OpenGLSquare_H_
#define __OpenGLSquare_H_

#include <iostream>
#ifdef ANDROID
  #include <GLES2/gl2.h>
#elif __IPHONE_OS_VERSION_MIN_REQUIRED
#include <OpenGLES/ES2/gl.h>
#else
  #include <GL/glew.h>
#endif


class OpenGLSquare {


};


#endif //__OpenGLSquare_H_
