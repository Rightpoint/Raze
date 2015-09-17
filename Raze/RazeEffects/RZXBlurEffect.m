//
//  RZXBlurEffect.m
//
//  Created by Rob Visentin on 1/16/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeEffects/RZXBlurEffect.h>
#import <RazeEffects/RZXCompositeEffect.h>

typedef NS_ENUM(NSUInteger, RZXBlurDirection) {
    kRZXBlurDirectionHorizontal,
    kRZXBlurDirectionVertical
};

typedef struct _RZXGaussianBlurProperties {
    GLfloat *weights;
    GLfloat *offsets;

    GLint numWeights;
    GLint numOffsets;

    GLfloat sigma;
} RZXGaussianBlurProperties;

static const GLfloat kRZXBlurEffectMinSigma = 1.0f;
static const GLfloat kRZXBlurEffectMaxSigmaPerLevel = 12.0f;
static const GLint kRZXBlurEffectMaxOffsetsPerLevel = kRZXBlurEffectMaxSigmaPerLevel + 1;

@interface RZXBlurEffectPartial : RZXEffect

@property (assign, nonatomic) RZXBlurDirection direction;

@property (assign, nonatomic) RZXGaussianBlurProperties blurProperties;
@property (assign, nonatomic) BOOL updateBlurProperties;

+ (instancetype)effectWithDirection:(RZXBlurDirection)direction;

@end

@interface RZXBlurEffectFull : RZXCompositeEffect

@property (assign, nonatomic) GLfloat sigma;
@property (assign, nonatomic) GLuint blurDownsample;

@property (assign, nonatomic) RZXGaussianBlurProperties blurProperties;

void RZXGetGaussianBlurWeights(GLfloat **weights, GLint *n, GLfloat sigma, GLint radius);
void RZXGetGaussianBlurOffsets(GLfloat **offsets, GLint *n, const GLfloat *weights, GLint numWeights);

@end

@interface RZXBlurEffect ()

@property (strong, nonatomic) RZXBlurEffectPartial *horizontal;
@property (strong, nonatomic) RZXBlurEffectPartial *vertical;

@property (strong, nonatomic) NSMutableArray *blurs;
@property (assign, nonatomic) NSUInteger currentIdx;

@property (nonatomic, readonly) RZXBlurEffectFull *firstBlur;
@property (nonatomic, readonly) RZXBlurEffectFull *currentBlur;

@end

@implementation RZXBlurEffect

+ (instancetype)effectWithSigma:(GLfloat)sigma
{
    RZXBlurEffectPartial *horizontal = [RZXBlurEffectPartial effectWithDirection:kRZXBlurDirectionHorizontal];
    RZXBlurEffectPartial *vertical = [RZXBlurEffectPartial effectWithDirection:kRZXBlurDirectionVertical];

    RZXBlurEffectFull *blur = [RZXBlurEffectFull compositeEffectWithFirstEffect:horizontal secondEffect:vertical];

    RZXBlurEffect *effect = [[RZXBlurEffect alloc] init];
    effect.horizontal = horizontal;
    effect.vertical = vertical;

    effect.blurs = [NSMutableArray arrayWithObject:blur];
    effect.sigma = sigma;

    return effect;
}

#pragma mark - overrides

- (BOOL)isLinked
{
    return self.horizontal.isLinked && self.vertical.isLinked;
}

- (BOOL)link
{
    return [self.horizontal link] && [self.vertical link];
}

- (void)setModelViewMatrix:(GLKMatrix4)modelViewMatrix
{
    [super setModelViewMatrix:modelViewMatrix];

    self.horizontal.modelViewMatrix = modelViewMatrix;
}

- (void)setProjectionMatrix:(GLKMatrix4)projectionMatrix
{
    [super setProjectionMatrix:projectionMatrix];

    self.horizontal.projectionMatrix = projectionMatrix;
}

- (void)setNormalMatrix:(GLKMatrix3)normalMatrix
{
    [super setNormalMatrix:normalMatrix];

    self.horizontal.normalMatrix = normalMatrix;
}

- (void)setResolution:(GLKVector2)resolution
{
    [super setResolution:resolution];

    self.horizontal.resolution = resolution;
    self.vertical.resolution = resolution;
}

- (GLuint)downsampleLevel
{
    return [super downsampleLevel] + self.currentBlur.blurDownsample;
}

- (void)setSigma:(GLfloat)sigma
{
    sigma = MAX(0.0f, sigma);
    _sigma = sigma;

    GLint i, downsample;
    GLfloat remainingSigma = sigma;

    for ( i = (GLint)self.blurs.count - 1, downsample = 0; downsample == 0 || remainingSigma > 0.0f; i--, downsample = MIN(downsample + 1, RZX_EFFECT_MAX_DOWNSAMPLE) ) {
        GLfloat multiplier = powf(2.0f, downsample);
        GLfloat levelSigma = MIN(ceilf(remainingSigma / multiplier), kRZXBlurEffectMaxSigmaPerLevel);

        if ( i >= 0 ) {
            ((RZXBlurEffect *)self.blurs[i]).sigma = levelSigma;
        }
        else {
            [self.blurs insertObject:[self blurWithSigma:levelSigma downsample:downsample] atIndex:0];
        }

        remainingSigma -= levelSigma * multiplier;
    }

    if ( i > 0 ) {
        [self.blurs removeObjectsInRange:NSMakeRange(0, i)];
    }

    self.currentIdx = 0;
}

- (BOOL)prepareToDraw
{
    BOOL unfinished = YES;

    if ( ![self.currentBlur prepareToDraw] ) {
        if ( self.currentIdx + 1 < self.blurs.count ) {
            self.currentIdx++;;
        }
        else {
            self.currentIdx = 0;
            unfinished = NO;
        }
    }

    return unfinished;
}

- (void)bindAttribute:(NSString *)attribute location:(GLuint)location
{
    // empty implementation
}

- (GLint)uniformLoc:(NSString *)uniformName
{
    return -1;
}

#pragma mark - RZXGPUObject overrides

- (BOOL)setupGL
{
    return ([self.horizontal setupGL] && [self.vertical setupGL]);
}

- (BOOL)bindGL
{
    return [self.currentBlur bindGL];
}

- (void)teardownGL
{
    [super teardownGL];

    [self.horizontal teardownGL];
    [self.vertical teardownGL];
}

#pragma mark - private methods

- (RZXBlurEffectFull *)blurWithSigma:(GLfloat)sigma downsample:(GLuint)downsample
{
    RZXBlurEffectFull *blur = [RZXBlurEffectFull compositeEffectWithFirstEffect:self.horizontal secondEffect:self.vertical];
    blur.sigma = sigma;
    blur.blurDownsample = downsample;

    return blur;
}

- (RZXBlurEffectFull *)firstBlur
{
    return (RZXBlurEffectFull *)[self.blurs firstObject];
}

- (RZXBlurEffectFull *)currentBlur
{
    return (RZXBlurEffectFull *)self.blurs[self.currentIdx];
}

@end

#pragma mark - RZXBlurEffectFull

@implementation RZXBlurEffectFull

- (GLfloat)sigma
{
    return _blurProperties.sigma;
}

- (void)setSigma:(GLfloat)sigma
{
    _blurProperties.sigma = sigma;

    free(_blurProperties.weights);
    free(_blurProperties.offsets);

    RZXGetGaussianBlurWeights(&_blurProperties.weights, &_blurProperties.numWeights, sigma, 2 * kRZXBlurEffectMaxOffsetsPerLevel);
    RZXGetGaussianBlurOffsets(&_blurProperties.offsets, &_blurProperties.numOffsets, _blurProperties.weights, _blurProperties.numWeights);
}

- (BOOL)prepareToDraw
{
    RZXBlurEffectPartial *horizontal = (RZXBlurEffectPartial *)self.firstEffect;
    RZXBlurEffectPartial *vertical = (RZXBlurEffectPartial *)self.secondEffect;

    horizontal.downsampleLevel = self.blurDownsample;
    vertical.downsampleLevel = self.blurDownsample;

    if ( horizontal.blurProperties.sigma != _blurProperties.sigma ) {
        horizontal.blurProperties = _blurProperties;
    }

    if ( vertical.blurProperties.sigma != _blurProperties.sigma ) {
        vertical.blurProperties = _blurProperties;
    }

    return [super prepareToDraw];
}

- (void)dealloc
{
    free(_blurProperties.weights);
    free(_blurProperties.offsets);
}

#pragma mark - private methods

void RZXGetGaussianBlurWeights(GLfloat **weights, GLint *n, GLfloat sigma, GLint radius)
{
    GLint numWeights = radius + 1;
    *weights = (GLfloat *)malloc(numWeights * sizeof(GLfloat));

    if ( sigma >= kRZXBlurEffectMinSigma ) {
        GLfloat norm = (1.0f / sqrtf(2.0f * M_PI * sigma * sigma));
        (*weights)[0] = norm;
        GLfloat sum = norm;

        // compute standard Gaussian weights using the 1-dimensional Gaussian function
        for ( GLint i = 1; i < numWeights; i++ ) {
            GLfloat weight =  norm * exp(-i * i / (2.0 * sigma * sigma));
            (*weights)[i] = weight;
            sum += 2.0f * weight;
        }

        // normalize weights to prevent the clipping of the Gaussian curve and reduced luminance
        for ( GLint i = 0; i < numWeights; i++ ) {
            (*weights)[i] /= sum;
        }
    }
    else {
        (*weights)[0] = 1.0f;
        for ( GLint i = 1; i < numWeights; i++ ) {
            (*weights)[i] = 0.0f;
        }
    }


    if ( n != NULL ) {
        *n = numWeights;
    }
}

void RZXGetGaussianBlurOffsets(GLfloat **offsets, GLint *n, const GLfloat *weights, GLint numWeights)
{
    GLint radius = numWeights - 1;

    // compute the offsets at which to read interpolated texel values
    // see: http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
    GLint numOffsets = ceilf(radius / 2.0);
    *offsets = (GLfloat *)malloc(numOffsets * sizeof(GLfloat));

    for ( GLint i = 0; i < numOffsets; i++ ) {
        GLfloat w1 = weights[i * 2 + 1];
        GLfloat w2 = weights[i * 2 + 2];

        if ( w1 + w2 > 0.0f ) {
            (*offsets)[i] = (w1 * (i * 2 + 1) + w2 * (i * 2 + 2)) / (w1 + w2);
        }
        else {
            (*offsets)[i] = 0.0f;
        }
    }

    if ( n != NULL ) {
        *n = numOffsets;
    }
}

@end

#pragma mark - RZXBlurEffectPartial

@implementation RZXBlurEffectPartial

+ (instancetype)effectWithDirection:(RZXBlurDirection)direction
{
    NSString *vsh = [self vertexShaderWithNumOffsets:kRZXBlurEffectMaxOffsetsPerLevel];
    NSString *fsh = [self fragmentShaderWithNumWeights:2 * kRZXBlurEffectMaxOffsetsPerLevel + 1];
    
    RZXBlurEffectPartial *effect = [self effectWithVertexShader:vsh fragmentShader:fsh];
    effect.direction = direction;
    
    effect.mvpUniform = @"u_MVPMatrix";
    
    return effect;
}

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        _blurProperties.sigma = -1.0f;
    }
    return self;
}

- (void)setBlurProperties:(RZXGaussianBlurProperties)blurProperties
{
    _blurProperties = blurProperties;
    self.updateBlurProperties = YES;
}

- (BOOL)link
{
    [self bindAttribute:@"a_position" location:kRZXVertexAttribPosition];
    [self bindAttribute:@"a_texCoord0" location:kRZXVertexAttribTexCoord];
    
    return [super link];
}

- (BOOL)prepareToDraw
{
    BOOL ret = [super prepareToDraw];
    
    if ( self.updateBlurProperties ) {
        [self setFloatUniform:@"u_Weights" value:_blurProperties.weights length:1 count:_blurProperties.numWeights];

        [self setFloatUniform:@"u_Offsets" value:_blurProperties.offsets length:1 count:_blurProperties.numOffsets];

        self.updateBlurProperties = NO;
    }
    
    GLfloat scale = powf(2.0, self.downsampleLevel);
    GLfloat step[2] = {(1 - self.direction) * scale / self.resolution.x, self.direction * scale / self.resolution.y};
    
    [self setFloatUniform:@"u_Step" value:step length:2 count:1];
    
    return ret;
}

#pragma mark - private methods

+ (NSString *)vertexShaderWithNumOffsets:(GLint)numOffsets
{
    NSMutableString *vsh = [NSMutableString string];
    
    [vsh appendFormat:@"\
     uniform mat4 u_MVPMatrix;\n\
     uniform vec2 u_Step;\n\
     uniform float u_Offsets[%i];\n\
     \n\
     attribute vec4 a_position;\n\
     attribute vec2 a_texCoord0;\n\
     \n\
     varying vec2 v_blurCoords[%i];\n\
     \n\
     void main(void)\n\
     {\n\
     gl_Position = u_MVPMatrix * a_position;\n\
     v_blurCoords[0] = a_texCoord0;\n\
     ", numOffsets, numOffsets * 2 + 1];
    
    for ( int i = 0; i < numOffsets; i++ ) {
        [vsh appendFormat:@"v_blurCoords[%i] = a_texCoord0 + u_Step * u_Offsets[%i];\n", i * 2 + 1, i];
        [vsh appendFormat:@"v_blurCoords[%i] = a_texCoord0 - u_Step * u_Offsets[%i];\n", i * 2 + 2, i];
    }
    
    [vsh appendString:@"}"];
    
    return vsh;
}

+ (NSString *)fragmentShaderWithNumWeights:(GLint)numWeights
{
    NSMutableString *fsh = [NSMutableString string];
    
    [fsh appendFormat:@"\
     uniform lowp sampler2D u_Texture;\n\
     \n\
     uniform highp vec2 u_Step;\n\
     uniform highp float u_Weights[%i];\n\
     \n\
     varying highp vec2 v_blurCoords[%i];\n\
     \n\
     void main(void)\n\
     {\n\
     lowp vec4 color = texture2D(u_Texture, v_blurCoords[0]) * u_Weights[0];\n\
     highp float weight = 0.0;\n\
     ", numWeights, numWeights];
    
    for ( int i = 0; i < ceil((numWeights - 1) / 2); i++ ) {
        [fsh appendFormat:@"weight = u_Weights[%i] + u_Weights[%i];\n", i * 2 + 1, i * 2 + 2];
        
        [fsh appendFormat:@"color += texture2D(u_Texture, v_blurCoords[%i]) * weight;\n", i * 2 + 1];
        [fsh appendFormat:@"color += texture2D(u_Texture, v_blurCoords[%i]) * weight;\n", i * 2 + 2];
    }
    
    [fsh appendString:@"\
     gl_FragColor = color;\n\
     }"];
    
    return fsh;
}

@end
