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
@property (assign, nonatomic, getter=isBlendEnabled) BOOL blendEnabled; // default NO
@property (assign, nonatomic) GLenum cullFace; // default GL_BACK
@property (assign, nonatomic) GLenum activeTexture; // default GL_TEXTURE0

/**
 *  Singleton version of this class. In most applications only one context is needed.
 *
 *  @note Currently objects can't be shared between RZXOpenGLContexts
 */
+ (instancetype)defaultContext;

/**
 *  Returns the current RZXGLContext when the method is called, or nil if no context is current.
 */
+ (RZXGLContext *)currentContext;

/**
 *  Create a new RZXGLContext that optionally shares resources with an existing context.
 *
 *  @param sharedContext An existing context that the new context should share resources with.
 *
 * @note Currently objects can't be shared between RZXOpenGLContexts
 */
- (instancetype)initWithSharedContext:(RZXGLContext *)sharedContext NS_DESIGNATED_INITIALIZER;

/**
 *  Returns the cache of resources of a given class.
 *  This cache is used internally.
 */
- (RZXCache *)cacheForClass:(Class)objectClass;

/**
 *  Binds the given vertex array object if it is not currently bound.
 */
- (void)bindVertexArray:(GLuint)vao;

/**
 *  Binds the given program if it is not currently bound.
 */
- (void)useProgram:(GLuint)program;

/**
 *  Returns an OpenGL texture for use with Core Video pixel buffers.
 */
- (CVOpenGLESTextureRef)textureWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/**
 *  Convenience method. Calls runBlock:wait: with wait set to YES.
 */
- (void)runBlock:(void(^)(RZXGLContext *context))block;

// Helpers to run code blocks: If the context is the current context, then the block will be performed immediately, if not, then the block will be performed after switching the context to the current context. If the wait parameter is NO, then the block is executed asychronously.
/**
 *  Invokes a given block in an environment where the receiver is the current context.
 *  The invocation occurs on a background thread.
 *
 *  @param block The block to run. It will be invoked with the receiver as the context parameter.
 *  @param wait  Whether to block the current queue until the background execution of the block completes.
 */
- (void)runBlock:(void(^)(RZXGLContext *context))block wait:(BOOL)wait;

@end

/**
 *  Fields OpenGL API specific calls (currently either 2.0 or 3.0).
 *  These methods should be used instead of the similarly named OpenGL equivalents to support both APIs.
 */
@interface RZXGLContext (RZXAPIBridging)

- (void)genVertexArrays:(GLuint *)arrays count:(GLsizei)n;
- (void)deleteVertexArrays:(const GLuint *)arrays count:(GLsizei)n;

- (void)resolveFramebuffer:(GLuint)framebuffer multisampleFramebuffer:(GLuint)msFramebuffer size:(CGSize)framebufferSize;

- (void)invalidateFramebufferAttachments:(const GLenum *)attachments count:(GLsizei)n;

@end

@interface RZXGLContext (RZXDrawing)

/**
 *  Create the backing storage for an EAGLDrawable object.
 *  This method is called when EAGLLayers are configured.
 *
 *  @return YES if storage allocation succeeded, NO otherwise.
 */
- (BOOL)renderbufferStorage:(NSUInteger)target fromDrawable:(id<EAGLDrawable>)drawable;

/**
 *  Present the contents of the given renderbuffer to the screen.
 *  This method should not be called from outside the context of an RZXGLView render loop.
 *
 *  @return YES if the presentation succeeded, NO otherwise.
 */
- (BOOL)presentRenderbuffer:(NSUInteger)target;

@end
