//
//  RZXBase.h
//
//  Created by Rob Visentin on 1/14/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#ifndef _RZXBase_h
#define _RZXBase_h

#import <OpenGLES/gltypes.h>
#import <RazeCore/RZXRenderable.h>

typedef enum _RZXVertexAttrib {
    kRZXVertexAttribPosition,
    kRZXVertexAttribTexCoord,
    kRZXVertexAttribNormal
} RZXVertexAttrib;

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

#endif
