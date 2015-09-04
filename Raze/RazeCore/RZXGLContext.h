//
//  RZXGLContext.h
//
//  Created by Rob Visentin on 2/18/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <OpenGLES/EAGLDrawable.h>
#import <CoreGraphics/CGColor.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <CoreVideo/CVOpenGLESTextureCache.h>
#import <RazeCore/RZXBase.h>

@class RZXCache;

/**
 *  Manager for a EAGLContex. It wraps common context settings to eliminate redundant state calls. It also owns the cache used for RZXObjects
 */
@interface RZXGLContext : NSObject

@property (nonatomic, readonly) EAGLRenderingAPI apiVersion;

@property (nonatomic, readonly) BOOL isCurrentContext;

// Managed OpenGL States
@property (assign, nonatomic) CGRect viewport;
@property (assign, nonatomic) CGColorRef clearColor; // default nil (opaque black)
@property (assign, nonatomic, getter=isDepthTestEnabled) BOOL depthTestEnabled; // default NO
@property (assign, nonatomic, getter=isStencilTestEnabled) BOOL stencilTestEnabled; // default NO
@property (assign, nonatomic) GLenum cullFace; // default GL_BACK
@property (assign, nonatomic) GLenum activeTexture; // default GL_TEXTURE0

// Singleton version of this class. In most applications only one context is needed.
+ (instancetype)defaultContext;

+ (RZXGLContext *)currentContext;

- (instancetype)initWithSharedContext:(RZXGLContext *)sharedContext NS_DESIGNATED_INITIALIZER;

- (RZXCache *)cacheForClass:(Class)objectClass;

- (BOOL)renderbufferStorage:(NSUInteger)target fromDrawable:(id<EAGLDrawable>)drawable;
- (BOOL)presentRenderbuffer:(NSUInteger)target;

- (void)bindVertexArray:(GLuint)vao;
- (void)useProgram:(GLuint)program;

// Generate Core Video Texture from context
- (CVOpenGLESTextureRef)textureWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;

// Helpers to run code blocks: If the context is the current context, then the block will be performed immediately, if not, then the block will be performed after switching the context to the current context. If the wait parameter is NO, then the block is executed asychronously.
- (void)runBlock:(void(^)(RZXGLContext *context))block wait:(BOOL)wait;

// Convenience method: calls runBlock with wait set to YES
- (void)runBlock:(void(^)(RZXGLContext *context))block;

@end

/**
 *  Fields OpenGL API specific calls (currently either 2.0 or 3.0)
 */
@interface RZXGLContext (RZXAPIBridging)

- (void)genVertexArrays:(GLuint *)arrays count:(GLsizei)n;
- (void)deleteVertexArrays:(const GLuint *)arrays count:(GLsizei)n;

- (void)resolveFramebuffer:(GLuint)framebuffer multisampleFramebuffer:(GLuint)msFramebuffer size:(CGSize)framebufferSize;

- (void)invalidateFramebufferAttachments:(const GLenum *)attachments count:(GLsizei)n;

@end
