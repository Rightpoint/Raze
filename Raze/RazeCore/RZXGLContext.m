//
//  RZXGLContext.m
//
//  Created by Rob Visentin on 2/18/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>
#import <objc/runtime.h>
#import <RazeCore/RZXGLContext.h>

static GLuint RZXCompileShader(const GLchar *source, GLenum type)
{
    GLuint shader = glCreateShader(type);
    GLint length = (GLuint)strlen(source);

    glShaderSource(shader, 1, &source, &length);
    glCompileShader(shader);

#if DEBUG
    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);

    if ( success != GL_TRUE ) {
        GLint length;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &length);

        GLchar *logText = malloc(length + 1);
        logText[length] = '\0';
        glGetShaderInfoLog(shader, length, NULL, logText);

        fprintf(stderr, "Error compiling shader: %s\n", logText);

        free(logText);
    }
#endif

    return shader;
}

@interface RZXGLContext ()

@property (strong, nonatomic, readwrite) dispatch_queue_t contextQueue;
@property (strong, nonatomic) EAGLContext *glContext;

@property (strong, nonatomic) NSMutableDictionary *compiledShaders;

@property (assign, nonatomic) CVOpenGLESTextureCacheRef textureCache;

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
        if ( _glContext != nil ) {
            objc_setAssociatedObject(_glContext, @selector(currentContext), self, OBJC_ASSOCIATION_ASSIGN);
        }

        _compiledShaders = [NSMutableDictionary dictionary];

        CVOpenGLESTextureCacheCreate(NULL, NULL, _glContext, NULL, &_textureCache);

        _activeTexture = GL_TEXTURE0;

        self.cullFace = GL_BACK;
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

        _clearColor = clearColor;
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
            glBindVertexArrayOES(vao);
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

- (GLuint)vertexShaderWithSource:(NSString *)vshSrc
{
    __block GLuint vsh;

    if ( self.compiledShaders[vshSrc] != nil ) {
        vsh = [self.compiledShaders[vshSrc] unsignedIntValue];
    }
    else {
        [self runBlock:^(RZXGLContext *context) {
            vsh = RZXCompileShader([vshSrc UTF8String], GL_VERTEX_SHADER);
            self.compiledShaders[vshSrc] = @(vsh);
        }];
    }

    return vsh;
}

- (GLuint)fragmentShaderWithSource:(NSString *)fshSrc
{
    __block GLuint fsh;

    if ( self.compiledShaders[fshSrc] != nil ) {
        fsh = [self.compiledShaders[fshSrc] unsignedIntValue];
    }
    else {
        [self runBlock:^(RZXGLContext *context) {
            fsh = RZXCompileShader([fshSrc UTF8String], GL_FRAGMENT_SHADER);
            self.compiledShaders[fshSrc] = @(fsh);
        }];
    }

    return fsh;
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
            void (^innerBlock)() = ^{
                if ( !self.isCurrentContext ) {
                    [EAGLContext setCurrentContext:self.glContext];
                }

                @autoreleasepool {
                    block(self);
                }
            };

            if ( wait ) {
                dispatch_sync(self.contextQueue, innerBlock);
            }
            else {
                dispatch_async(self.contextQueue, innerBlock);
            }
        }
    }
}

@end
