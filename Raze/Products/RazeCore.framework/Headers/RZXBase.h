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
#import <RazeCore/RZXRenderable.h>

#if TARGET_OS_IPHONE
#define RZXColor UIColor
#define RZXFont  UIFont
#else
#define RZXColor NSColor
#define RZXFont  NSFont
#endif

typedef enum _RZXVertexAttrib {
    kRZXVertexAttribPosition,
    kRZXVertexAttribTexCoord,
    kRZXVertexAttribNormal
} RZXVertexAttrib;

#endif
