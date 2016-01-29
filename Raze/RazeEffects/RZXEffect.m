//
//  RZXEffect.m
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeEffects/RZXEffect.h>
#import <RazeCore/RZXCache.h>

GLuint RZXCompileShader(const GLchar *source, GLenum type);

@interface RZXEffect ()

@property (strong, nonatomic) NSString *vshSrc;
@property (strong, nonatomic) NSString *fshSrc;

@property (nonatomic, readwrite, getter = isLinked) BOOL linked;

@property (strong, nonatomic) NSCache *uniforms;
@property (strong, nonatomic) NSCache *uniformValues;

@end

@implementation RZXEffect {
    GLuint _name;
}

#pragma mark - lifecycle

+ (instancetype)effectWithVertexShader:(NSString *)vsh fragmentShader:(NSString *)fsh
{
    RZXEffect *effect = nil;

    if ( vsh == nil ) {
        RZXLog(@"%@ failed to intialize, missing vertex shader.", NSStringFromClass(self));
    }
    
    if ( fsh == nil ) {
        RZXLog(@"%@ failed to intialize, missing fragment shader.", NSStringFromClass(self));
    }
    
    if ( vsh != nil && fsh != nil ) {
        effect = [[self alloc] initWithVertexShader:vsh fragmentShader:fsh];
    }
    
    return effect;
}

- (instancetype)initWithVertexShader:(NSString *)vsh fragmentShader:(NSString *)fsh
{
    self = [super init];
    if ( self ) {
        _vshSrc = vsh;
        _fshSrc = fsh;
    }
    return self;
}

#pragma mark - public methods

- (void)setDownsampleLevel:(GLuint)downsampleLevel
{
    _downsampleLevel = MIN(downsampleLevel, RZX_EFFECT_MAX_DOWNSAMPLE);
}

- (NSInteger)preferredLevelOfDetail
{
    return 0;
}

- (BOOL)link
{
    [self.uniforms removeAllObjects];
    
    glLinkProgram(_name);
    
    GLint success;
    glGetProgramiv(_name, GL_LINK_STATUS, &success);

    if ( success != GL_TRUE ) {
        GLint length;
        glGetProgramiv(_name, GL_INFO_LOG_LENGTH, &length);
        
        GLchar *logText = (GLchar *)malloc(length + 1);
        logText[length] = '\0';
        glGetProgramInfoLog(_name, length, NULL, logText);
        
        fprintf(stderr, "Error linking %s: %s\n", [NSStringFromClass([self class]) UTF8String], logText);
        
        free(logText);
    }

    self.linked = (success == GL_TRUE);

    return self.isLinked;
}

- (BOOL)prepareToDraw
{
    [self bindGL];

    if ( self.mvpUniform != nil ) {
        GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(_projectionMatrix, _modelViewMatrix);
        [self setMatrix4Uniform:self.mvpUniform value:&mvpMatrix transpose:GL_FALSE count:1];
    }
    
    if ( self.mvUniform != nil ) {
        [self setMatrix4Uniform:self.mvUniform value:&_modelViewMatrix transpose:GL_FALSE count:1];
    }
    
    if ( self.normalMatrixUniform != nil ) {
        [self setMatrix3Uniform:self.normalMatrixUniform value:&_normalMatrix transpose:GL_FALSE count:1];
    }
    
    return NO;
}

- (void)bindAttribute:(NSString *)attribute location:(GLuint)location
{
    glBindAttribLocation(_name, location, [attribute UTF8String]);
}

#pragma mark - uniforms

- (GLint)uniformLoc:(NSString *)uniformName
{
    GLint loc;
    NSNumber *cachedLoc = [self.uniforms objectForKey:uniformName];
    
    if ( cachedLoc != nil ) {
        loc = cachedLoc.intValue;
    }
    else {
        loc = glGetUniformLocation(_name, [uniformName UTF8String]);
        
        if ( loc != -1 ) {
            [self.uniforms setObject:@(loc) forKey:uniformName];
        }
    }

    return loc;
}

- (void)setFloatUniform:(NSString *)name value:(const GLfloat *)value length:(GLsizei)length count:(GLsizei)count
{
    void (*uniformFunc)(GLint, GLsizei, const GLfloat *) = NULL;

    switch ( length ) {
        case 1: {
            uniformFunc = glUniform1fv;
            break;
        }

        case 2: {
            uniformFunc = glUniform2fv;
            break;
        }

        case 3: {
            uniformFunc = glUniform3fv;
            break;
        }

        case 4: {
            uniformFunc = glUniform4fv;
            break;
        }

        default:
            break;
    }

    if ( uniformFunc != NULL ) {
        size_t byteLength = length * count * sizeof(GLfloat);

        [self setUniform:name value:value length:byteLength setter:^(GLint location) {
            uniformFunc(location, count, value);
        }];
    }
    else {
        RZXLog(@"%@ failed to set uniform %@ with invalid length %i", [self class], name, length);
    }
}

- (void)setIntUniform:(NSString *)name value:(const GLint *)value length:(GLsizei)length count:(GLsizei)count
{
    void (*uniformFunc)(GLint, GLsizei, const GLint *) = NULL;

    switch ( length ) {
        case 1: {
            uniformFunc = glUniform1iv;
            break;
        }

        case 2: {
            uniformFunc = glUniform2iv;
            break;
        }

        case 3: {
            uniformFunc = glUniform3iv;
            break;
        }

        case 4: {
            uniformFunc = glUniform4iv;
            break;
        }

        default:
            break;
    }

    if ( uniformFunc != NULL ) {
        size_t byteLength = length * count * sizeof(GLint);

        [self setUniform:name value:value length:byteLength setter:^(GLint location) {
            uniformFunc(location, count, value);
        }];
    }
    else {
        RZXLog(@"%@ failed to set uniform %@ with invalid length %i", [self class], name, length);
    }
}

- (void)setMatrix2Uniform:(NSString *)name value:(const GLKMatrix2 *)value transpose:(GLboolean)transpose count:(GLsizei)count
{
    [self setUniform:name value:value->m length:sizeof(value->m) setter:^(GLint location) {
        glUniformMatrix2fv(location, count, transpose, value->m);
    }];
}

- (void)setMatrix3Uniform:(NSString *)name value:(const GLKMatrix3 *)value transpose:(GLboolean)transpose count:(GLsizei)count
{
    [self setUniform:name value:value->m length:sizeof(value->m) setter:^(GLint location) {
        glUniformMatrix3fv(location, count, transpose, value->m);
    }];
}

- (void)setMatrix4Uniform:(NSString *)name value:(const GLKMatrix4 *)value transpose:(GLboolean)transpose count:(GLsizei)count
{
    [self setUniform:name value:value->m length:sizeof(value->m) setter:^(GLint location) {
        glUniformMatrix4fv(location, count, transpose, value->m);
    }];
}

#pragma mark - RZXGPUObject overrides

- (RZXGPUObjectTeardownBlock)teardownHandler
{
    GLuint name = _name;
    return ^(RZXGLContext *context) {
        glDeleteProgram(name);
    };
}

- (BOOL)setupGL
{
    BOOL setup = [super setupGL];

    if ( setup ) {
        RZXCache *cache = [self.configuredContext cacheForClass:[RZXEffect class]];

        GLuint vs = [cache[self.vshSrc] unsignedIntValue];

        if ( vs == 0 ) {
            vs = RZXCompileShader(self.vshSrc.UTF8String, GL_VERTEX_SHADER);
            cache[self.vshSrc] = @(vs);
        }

        GLuint fs = [cache[self.fshSrc] unsignedIntValue];

        if ( fs == 0 ) {
            fs = RZXCompileShader(self.fshSrc.UTF8String, GL_FRAGMENT_SHADER);
            cache[self.fshSrc] = @(fs);
        }

        _name = glCreateProgram();

        glAttachShader(_name, vs);
        glAttachShader(_name, fs);

        setup = [self link];
    }

#if RZX_DEBUG
    setup &= !RZXGLError();
#endif

    return setup;
}

- (BOOL)bindGL
{
    BOOL bound = [super bindGL];

    if ( bound ) {
        [self.configuredContext useProgram:_name];
    }

#if RZX_DEBUG
    bound &= !RZXGLError();
#endif

    return bound;
}

- (void)teardownGL
{
    [super teardownGL];

    _name = 0;
}

#pragma mark - private methods

- (instancetype)init
{
    if ( (self = [super init]) ) {
        _modelViewMatrix = GLKMatrix4Identity;
        _projectionMatrix = GLKMatrix4Identity;
        _normalMatrix = GLKMatrix3Identity;

        _uniforms = [[NSCache alloc] init];
        _uniformValues = [[NSCache alloc] init];
    }
    return self;
}

- (void)setUniform:(NSString *)uniformName value:(const void *)value length:(size_t)bytes setter:(void (^)(GLint location))setter
{
    if ( ![self uniformValueCacheHit:uniformName value:value length:bytes] ) {
        GLint location = [self uniformLoc:uniformName];

        if ( location >= 0 ) {
            [self.configuredContext runBlock:^(RZXGLContext *context) {
                [self bindGL];
                setter(location);
            }];

            NSData *valueData = [NSData dataWithBytes:value length:bytes];
            [self.uniformValues setObject:valueData forKey:uniformName];
        }
    }
}

- (BOOL)uniformValueCacheHit:(NSString *)uniformName value:(const void *)value length:(size_t)length
{
    BOOL hit = NO;

    NSData *cachedValue = [self.uniformValues objectForKey:uniformName];

    if ( cachedValue != nil ) {
        NSData *newValue = [[NSData alloc] initWithBytesNoCopy:(void *)value length:length freeWhenDone:NO];

        hit = [cachedValue isEqualToData:newValue];
    }

    return hit;
}

@end

GLuint RZXCompileShader(const GLchar *source, GLenum type)
{
    GLuint shader = glCreateShader(type);
    GLint length = (GLuint)strlen(source);

    glShaderSource(shader, 1, &source, &length);
    glCompileShader(shader);

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

    return shader;
}
