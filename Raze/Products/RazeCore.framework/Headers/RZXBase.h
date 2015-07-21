//
//  RZXBase.h
//
//  Created by Rob Visentin on 1/14/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#ifndef _RZXBase_h
#define _RZXBase_h

#import <TargetConditionals.h>

#import <OpenGLES/gltypes.h>
#import <GLKit/GLKMath.h>

#if TARGET_OS_IPHONE
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES3/glext.h>
#define RZXColor UIColor
#define RZXFont  UIFont
#else
#include <OpenGL/gl3ext.h>
#define RZXColor NSColor
#define RZXFont  NSFont
#endif

typedef enum _RZXVertexAttrib {
    kRZXVertexAttribPosition,
    kRZXVertexAttribTexCoord,
    kRZXVertexAttribNormal
} RZXVertexAttrib;

#if DEBUG
#define RZXLog NSLog
#else
#define RZXLog(...)
#endif

/**
 *  Convenience macros for creating keypaths. An invalid keypath will throw a compile-time error when compiling in debug mode.
 *
 *  The first parameter of these macros is used only for compile-time validation of the keypath.
 *
 *  @return An NSString containing the keypath.
 *
 *  @example RZX_KP(NSObject, description.length) -> @"description.length"
 *           RZX_KP_OBJ(transform, scale)         -> @"scale"
 *           RZX_KP_SELF(transform, scale.x)      -> @"scale.x"
 */
#if DEBUG
#define RZX_KP(Classname, keypath) ({\
Classname *_rzdb_keypath_obj; \
__unused __typeof(_rzdb_keypath_obj.keypath) _rzdb_keypath_prop; \
@#keypath; \
})

#define RZX_KP_OBJ(object, keypath) ({\
__typeof(object) _rzdb_keypath_obj; \
__unused __typeof(_rzdb_keypath_obj.keypath) _rzdb_keypath_prop; \
@#keypath; \
})
#else
#define RZX_KP(Classname, keypath) (@#keypath)
#define RZX_KP_OBJ(self, keypath) (@#keypath)
#endif

/**
 *  @note This macro will implicitly retain self from within blocks while running in debug mode.
 *  The safe way to generate a keypath on self from  within a block
 *  is to define a weak reference to self outside the block, and then use RZX_KP_OBJ(weakSelf, keypath).
 */
#define RZX_KP_SELF(keypath) RZX_KP_OBJ(self, keypath)


/**
 *  Function to flush (and print in DEBUG mode) the current OpenGL error.
 */
CF_INLINE GLenum RZXGLError()
{
    GLenum errCode = glGetError();

#if DEBUG
    const GLchar *errString = NULL;

    switch( errCode ) {
        case GL_NO_ERROR:
            break;

        case GL_INVALID_ENUM:
            errString = "GL_INVALID_ENUM";
            break;

        case GL_INVALID_VALUE:
            errString = "GL_INVALID_VALUE";
            break;

        case GL_INVALID_OPERATION:
            errString = "GL_INVALID_OPERATION";
            break;

        case GL_INVALID_FRAMEBUFFER_OPERATION:
            errString = "GL_INVALID_FRAMEBUFFER_OPERATION";
            break;

        default:
            errString = "UNKNOWN GL ERROR";
    }

    if ( errString != NULL ) {
        fprintf(stderr, "GL Error: %s\n", errString);
    }
#endif
    
    return errCode;
}

#endif
