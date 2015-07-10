//
//  RZXEffect.m
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <RazeCore/RZXEffect.h>
#import <RazeCore/RZXGLContext.h>

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

+ (instancetype)effectWithVertexShaderNamed:(NSString *)vshName fragmentShaderNamed:(NSString *)fshName
{
    NSString *vshPath = [[NSBundle mainBundle] pathForResource:vshName ofType:@"vsh"];
    NSString *fshPath = [[NSBundle mainBundle] pathForResource:fshName ofType:@"fsh"];
    
    NSString *vsh = [NSString stringWithContentsOfFile:vshPath encoding:NSASCIIStringEncoding error:nil];
    NSString *fsh = [NSString stringWithContentsOfFile:fshPath encoding:NSASCIIStringEncoding error:nil];
    
#if DEBUG
    if ( vsh == nil ) {
        NSLog(@"%@ failed to load vertex shader %@.vsh", NSStringFromClass(self), vshName);
    }
    
    if ( fsh == nil ) {
        NSLog(@"%@ failed to load fragment shader %@.fsh", NSStringFromClass(self), fshName);
    }
#endif

    return [self effectWithVertexShader:vsh fragmentShader:fsh];
}

+ (instancetype)effectWithVertexShader:(NSString *)vsh fragmentShader:(NSString *)fsh
{
    RZXEffect *effect = nil;
    
#if DEBUG
    if ( vsh == nil ) {
        NSLog(@"%@ failed to intialize, missing vertex shader.", NSStringFromClass(self));
    }
    
    if ( fsh == nil ) {
        NSLog(@"%@ failed to intialize, missing fragment shader.", NSStringFromClass(self));
    }
#endif
    
    if ( vsh != nil && fsh != nil ) {
        effect = [[self alloc] initWithVertexShader:vsh fragmentShader:fsh];
    }
    
    return effect;
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
    
#if DEBUG
    if ( success != GL_TRUE ) {
        GLint length;
        glGetProgramiv(_name, GL_INFO_LOG_LENGTH, &length);
        
        GLchar *logText = (GLchar *)malloc(length + 1);
        logText[length] = '\0';
        glGetProgramInfoLog(_name, length, NULL, logText);
        
        fprintf(stderr, "Error linking %s: %s\n", [NSStringFromClass([self class]) UTF8String], logText);
        
        free(logText);
    }
#endif

    self.linked = (success == GL_TRUE);

    return self.isLinked;
}

- (BOOL)prepareToDraw
{
    [self rzx_bindGL];
    
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
        NSLog(@"%@ failed to set uniform %@ with invalid length %i", [self class], name, length);
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
        NSLog(@"%@ failed to set uniform %@ with invalid length %i", [self class], name, length);
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

#pragma mark - RZXOpenGLObject

- (void)rzx_setupGL
{
    RZXGLContext *currentContext = [RZXGLContext currentContext];

    if ( currentContext != nil ) {
        [self rzx_teardownGL];
        
        GLuint vs = [currentContext vertexShaderWithSource:self.vshSrc];
        GLuint fs = [currentContext fragmentShaderWithSource:self.fshSrc];
        
        _name = glCreateProgram();
        
        glAttachShader(_name, vs);
        glAttachShader(_name, fs);

        [self link];
    }
    else {
        NSLog(@"Failed to setup %@: No active RZXGLContext.", NSStringFromClass([self class]));
    }
}

- (void)rzx_bindGL
{
    [[RZXGLContext currentContext] useProgram:_name];
}

- (void)rzx_teardownGL
{
    if ( _name != 0 ) {
        glDeleteProgram(_name);
        _name = 0;
    }
}

#pragma mark - private methods

- (instancetype)initWithVertexShader:(NSString *)vsh fragmentShader:(NSString *)fsh
{
    self = [self init];
    if ( self ) {
        _vshSrc = vsh;
        _fshSrc = fsh;

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
            setter(location);

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
