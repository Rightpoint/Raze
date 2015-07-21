//
//  RZXGLContext.m
//
//  Created by Rob Visentin on 2/18/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <objc/runtime.h>
#import <RazeCore/RZXCache.h>
#import <RazeCore/RZXGLContext.h>

@interface RZXGLContext ()

@property (strong, nonatomic, readonly) dispatch_queue_t contextQueue;
@property (strong, nonatomic, readonly) EAGLContext *glContext;

@property (assign, nonatomic, readonly) CVOpenGLESTextureCacheRef textureCache;

@property (strong, nonatomic, readonly) RZXCache *cache;

@end

@implementation RZXGLContext {
    GLuint _currentVAO;
    GLuint _currentProgram;
}

#pragma mark - lifecycle

+ (instancetype)defaultContext
{
    static id s_DefaultContext = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_DefaultContext = [[self alloc] init];
    });

    return s_DefaultContext;
}

+ (RZXGLContext *)currentContext
{
    return objc_getAssociatedObject([EAGLContext currentContext], _cmd);
}

- (instancetype)init
{
    return [self initWithSharedContext:nil];
}

- (instancetype)initWithSharedContext:(RZXGLContext *)shareContext
{
    self = [super init];
    if ( self ) {
        const char *queueLabel = [NSString stringWithFormat:@"com.raze.context-%lu", (unsigned long)self.hash].UTF8String;
        _contextQueue = dispatch_queue_create(queueLabel, DISPATCH_QUEUE_SERIAL);

        _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3 sharegroup:shareContext.glContext.sharegroup];

        if ( _glContext == nil ) {
            _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:shareContext.glContext.sharegroup];
        }

        if ( _glContext != nil ) {
            objc_setAssociatedObject(_glContext, @selector(currentContext), self, OBJC_ASSOCIATION_ASSIGN);

            _cache = [[RZXCache alloc] init];

            CVOpenGLESTextureCacheCreate(NULL, NULL, _glContext, NULL, &_textureCache);

            _activeTexture = GL_TEXTURE0;

            self.cullFace = GL_BACK;
        }
        else {
            RZXLog(@"Failed to initialize %@: Unable to create EAGLContext.", NSStringFromClass([self class]));
            self = nil;
        }
    }

    return self;
}

- (void)dealloc
{
    CGColorRelease(_clearColor);

    if ( _textureCache != nil ) {
        CFRelease(_textureCache);
    }

    objc_setAssociatedObject(_glContext, @selector(currentContext), nil, OBJC_ASSOCIATION_ASSIGN);

    if ( [EAGLContext currentContext] == self.glContext ) {
        [EAGLContext setCurrentContext:nil];
    }
}

#pragma mark - getters

- (EAGLRenderingAPI)apiVersion
{
    return self.glContext.API;
}

- (BOOL)isCurrentContext
{
    return ([EAGLContext currentContext] == self.glContext);
}

#pragma mark - setters

- (void)setViewport:(CGRect)viewport
{
    if ( !CGRectEqualToRect(_viewport, viewport) ) {
        [self runBlock:^(RZXGLContext *context) {
            glViewport(viewport.origin.x, viewport.origin.y, viewport.size.width, viewport.size.height);
        }];

        _viewport = viewport;
    }
}

- (void)setClearColor:(CGColorRef)clearColor
{
    if ( !CGColorEqualToColor(_clearColor, clearColor) ) {
        [self runBlock:^(RZXGLContext *context) {
            if ( clearColor != nil ) {
                const CGFloat *comps = CGColorGetComponents(clearColor);

                size_t numComps = CGColorGetNumberOfComponents(clearColor);
                CGFloat r, g, b, a;
                r = g = b = a = 0.0f;

                if ( numComps == 2 ) {
                    const CGFloat *comps = CGColorGetComponents(clearColor);
                    r = b = g = comps[0];
                    a = comps[1];
                }
                else if ( numComps == 4 ) {
                    r = comps[0];
                    g = comps[1];
                    b = comps[2];
                    a = comps[3];
                }
                
                glClearColor(r, g, b, a);
            }
            else {
                glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
            }
        }];

        CGColorRelease(_clearColor);
        _clearColor = clearColor;
        CGColorRetain(_clearColor);
    }
}

- (void)setDepthTestEnabled:(BOOL)depthTestEnabled
{
    if ( _depthTestEnabled != depthTestEnabled ) {
        [self runBlock:^(RZXGLContext *context) {
            if ( depthTestEnabled ) {
                glEnable(GL_DEPTH_TEST);
            }
            else {
                glDisable(GL_DEPTH_TEST);
            }
        }];

        _depthTestEnabled = depthTestEnabled;
    }
}

- (void)setStencilTestEnabled:(BOOL)stencilTestEnabled
{
    if ( _stencilTestEnabled != stencilTestEnabled ) {
        [self runBlock:^(RZXGLContext *context) {
            if ( stencilTestEnabled ) {
                glEnable(GL_STENCIL_TEST);
            }
            else {
                glDisable(GL_STENCIL_TEST);
            }
        }];

        _stencilTestEnabled = stencilTestEnabled;
    }
}

- (void)setCullFace:(GLenum)cullFace
{
    if ( _cullFace != cullFace ) {
        [self runBlock:^(RZXGLContext *context) {
            glCullFace(cullFace);

            if ( cullFace != GL_NONE ) {
                glEnable(GL_CULL_FACE);
            }
            else {
                glDisable(GL_CULL_FACE);
            }
        }];

        _cullFace = cullFace;
    }
}

- (void)setActiveTexture:(GLenum)activeTexture
{
    if ( _activeTexture != activeTexture ) {
        [self runBlock:^(RZXGLContext *context) {
            glActiveTexture(activeTexture);
        }];

        _activeTexture = activeTexture;
    }
}

#pragma mark - public methods

- (RZXCache *)cacheForClass:(Class)objectClass
{
    RZXCache *classCache = self.cache[(id<NSCopying>)objectClass];

    if ( classCache == nil ) {
        classCache = [[RZXCache alloc] init];
        self.cache[(id<NSCopying>)objectClass] = classCache;
    }

    return classCache;
}

- (BOOL)renderbufferStorage:(NSUInteger)target fromDrawable:(id<EAGLDrawable>)drawable
{
    __block BOOL success = NO;

    [self runBlock:^(RZXGLContext *context) {
        success = [context.glContext renderbufferStorage:target fromDrawable:drawable];
    }];

    return success;
}

- (BOOL)presentRenderbuffer:(NSUInteger)target
{
    __block BOOL success = NO;

    [self runBlock:^(RZXGLContext *context) {
        success = [context.glContext presentRenderbuffer:target];
    }];

    return success;
}

- (void)bindVertexArray:(GLuint)vao
{
    if ( vao != _currentVAO ) {
        [self runBlock:^(RZXGLContext *context) {
            if ( context.apiVersion < kEAGLRenderingAPIOpenGLES3 ) {
                glBindVertexArrayOES(vao);
            }
            else {
                glBindVertexArray(vao);
            }
        }];

        _currentVAO = vao;
    }
}

- (void)useProgram:(GLuint)program
{
    if ( program != _currentProgram ) {
        [self runBlock:^(RZXGLContext *context) {
            glUseProgram(program);
        }];

        _currentProgram = program;
    }
}

- (CVOpenGLESTextureRef)textureWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    GLsizei width = (GLsizei)CVPixelBufferGetWidth(pixelBuffer);
    GLsizei height = (GLsizei)CVPixelBufferGetHeight(pixelBuffer);

    OSType format = CVPixelBufferGetPixelFormatType(pixelBuffer);

    GLenum glFormat = (format == kCVPixelFormatType_32BGRA) ? GL_BGRA : GL_RGBA;

    CVOpenGLESTextureRef tex;
    CVOpenGLESTextureCacheCreateTextureFromImage(NULL, self.textureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, width, height, glFormat, GL_UNSIGNED_BYTE, 0, &tex);

    return tex;
}

- (void)runBlock:(void (^)(RZXGLContext *))block
{
    [self runBlock:block wait:YES];
}

- (void)runBlock:(void (^)(RZXGLContext *context))block wait:(BOOL)wait
{
    if ( block != nil ) {
        if ( self.isCurrentContext ) {
            if ( wait ) {
                block(self);
            }
            else {
                dispatch_async(self.contextQueue, ^{
                    block(self);
                });
            }
        }
        else {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            dispatch_block_t innerBlock = ^{
                if ( !self.isCurrentContext ) {
                    [EAGLContext setCurrentContext:self.glContext];
                }

                @autoreleasepool {
                    block(self);
                }

                dispatch_semaphore_signal(semaphore);
            };

            dispatch_async(self.contextQueue, innerBlock);

            if ( wait ) {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
        }
    }
}

@end

@implementation RZXGLContext (RZXAPIBridging)

- (void)genVertexArrays:(GLuint *)arrays count:(GLsizei)n
{
    if ( self.apiVersion < kEAGLRenderingAPIOpenGLES3 ) {
        glGenVertexArrays(n, arrays);
    }
    else {
        glGenVertexArraysOES(n, arrays);
    }
}

- (void)deleteVertexArrays:(const GLuint *)arrays count:(GLsizei)n
{
    if ( self.apiVersion < kEAGLRenderingAPIOpenGLES3 ) {
        glDeleteVertexArrays(n, arrays);
    }
    else {
        glDeleteVertexArraysOES(n, arrays);
    }
}

- (void)resolveFramebuffer:(GLuint)framebuffer multisampleFramebuffer:(GLuint)msFramebuffer size:(CGSize)framebufferSize
{
    static const GLenum s_GLDiscards[] = {GL_DEPTH_ATTACHMENT, GL_COLOR_ATTACHMENT0};

    if ( self.apiVersion < kEAGLRenderingAPIOpenGLES3 ) {
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, framebuffer);
        glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, msFramebuffer);
        glResolveMultisampleFramebufferAPPLE();
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, s_GLDiscards);
        glDiscardFramebufferEXT(GL_DRAW_FRAMEBUFFER_APPLE, 1, s_GLDiscards);
    }
    else {
        GLint width = framebufferSize.width;
        GLint height = framebufferSize.height;

        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, framebuffer);
        glBindFramebuffer(GL_READ_FRAMEBUFFER, msFramebuffer);
        glBlitFramebuffer(0, 0, width, height, 0, 0, width, height, GL_COLOR_BUFFER_BIT, GL_LINEAR);
        glInvalidateFramebuffer(GL_READ_FRAMEBUFFER, 2, s_GLDiscards);
        glInvalidateFramebuffer(GL_DRAW_FRAMEBUFFER, 1, s_GLDiscards);
    }
}

- (void)invalidateFramebufferAttachments:(const GLenum *)attachments count:(GLsizei)n
{
    if ( self.apiVersion < kEAGLRenderingAPIOpenGLES3 ) {
        glDiscardFramebufferEXT(GL_FRAMEBUFFER, n, attachments);
    }
    else {
        glInvalidateFramebuffer(GL_FRAMEBUFFER, n, attachments);
    }
}

@end
