//
//  RZXImageFilter.m
//  RazeEffects
//
//  Created by Rob Visentin on 7/23/15.
//

#import <RazeCore/RZXQuadMesh.h>
#import <RazeCore/RZXDynamicTexture.h>
#import <RazeEffects/RZXEffect.h>
#import <RazeEffects/RZXImageFilter.h>

@interface RZXImageFilter ()

@property (strong, nonatomic) RZXGLContext *context;
@property (strong, nonatomic) RZXQuadMesh *quad;

@property (strong, nonatomic) RZXDynamicTexture *sourceTexture;
@property (copy, nonatomic) NSArray *fboTextures;

@end

@implementation RZXImageFilter {
    GLuint _fbos[2];
    CGImageRef _outputImage;
}

- (instancetype)init
{
    if ( (self = [super init]) ) {
        self.context = [[RZXGLContext alloc] init];
        self.quad = [RZXQuadMesh quad];

        [self.context runBlock:^(RZXGLContext *context) {
            context.depthTestEnabled = NO;
            context.cullFace = GL_NONE;

            glGenFramebuffers(2, _fbos);

            [self.quad setupGL];
        }];
    }
    return self;
}

- (instancetype)initWithSourceImage:(CGImageRef)sourceImage effect:(RZXEffect *)effect
{
    if ( (self = [self init]) ) {
        self.sourceImage = sourceImage;
        self.effect = effect;
    }
    return self;
}

- (void)dealloc
{
    GLuint *fbos = (GLuint *)malloc(sizeof(_fbos));
    memcpy(fbos, _fbos, sizeof(_fbos));
    [self.context runBlock:^(RZXGLContext *context) {
        glDeleteFramebuffers(2, fbos);
    } wait:NO];

    _fbos[0] = _fbos[1] = 0;

    CGImageRelease(_sourceImage);
    CGImageRelease(_outputImage);
}

- (void)setSourceImage:(CGImageRef)sourceImage
{
    CGImageRelease(_sourceImage);
    _sourceImage = sourceImage;
    CGImageRetain(_sourceImage);

    CGImageRelease(_outputImage);
    _outputImage = nil;

    if ( sourceImage != nil ) {
        [self configureTextures];
    }
    else {
        self.sourceTexture = nil;
        self.fboTextures = nil;
    }
}

- (void)setEffect:(RZXEffect *)effect
{
    _effect = effect;

    if ( effect != nil ) {
        [self.context runBlock:^(RZXGLContext *context) {
            [effect setupGL];
        } wait:NO];
    }
}

- (CGImageRef)outputImage
{
    if ( _outputImage == nil ) {
        GLKVector2 resolution = GLKVector2Make(CGImageGetWidth(self.sourceImage), CGImageGetHeight(self.sourceImage));

        self.effect.resolution = resolution;

        [self.context runBlock:^(RZXGLContext *context) {
            context.viewport = CGRectMake(0.0f, 0.0f, resolution.x, resolution.y);

            [self.sourceTexture bindGL];

            int fbo = 0;
            RZXDynamicTexture *currentTexture = [self.fboTextures firstObject];

            // TODO: handle downsample level of effects

            while ( [self.effect prepareToDraw] ) {
                [self renderToFramebuffer:_fbos[fbo]];

                // prepare for next pass
                [currentTexture bindGL];
                fbo = 1 - fbo;
                currentTexture = self.fboTextures[fbo];
            };

            // final pass
            [self renderToFramebuffer:_fbos[fbo]];

            glFinish();

            glBindTexture(GL_TEXTURE_2D, 0);
            glBindFramebuffer(GL_FRAMEBUFFER, 0);

            _outputImage = [currentTexture createImageRepresentation];
        } wait:YES];
    }

    return _outputImage;
}

#pragma mark - private methods

- (void)configureTextures
{
    CGImageRef sourceImage = self.sourceImage;
    CGImageRetain(sourceImage);

    CGSize imageSize = CGSizeMake(CGImageGetWidth(sourceImage), CGImageGetHeight(sourceImage));

    self.sourceTexture = [RZXDynamicTexture textureWithSize:imageSize scale:1.0f];
    self.fboTextures = @[[RZXDynamicTexture textureWithSize:imageSize scale:1.0f],
                         [RZXDynamicTexture textureWithSize:imageSize scale:1.0f]];

    NSDictionary *textureOptions = @{ kRZXTextureSWrapKey : @(GL_CLAMP_TO_EDGE),
                                      kRZXTextureTWrapKey : @(GL_CLAMP_TO_EDGE) };

    RZXDynamicTexture *sourceTexture = self.sourceTexture;
    NSArray *fboTextures = self.fboTextures;

    [self.context runBlock:^(RZXGLContext *context) {
        [sourceTexture setupGL];
        [sourceTexture updateWithBlock:^(id self, CGContextRef ctx) {
            CGRect contextRect = (CGRect){.size.width = CGBitmapContextGetWidth(ctx), .size.height = CGBitmapContextGetHeight(ctx)};
            CGContextClearRect(ctx, contextRect);
            CGContextDrawImage(ctx, contextRect, sourceImage);
        }];

        [sourceTexture applyOptions:textureOptions];

        [fboTextures makeObjectsPerformSelector:@selector(setupGL)];
        [fboTextures makeObjectsPerformSelector:@selector(applyOptions:) withObject:textureOptions];

        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[0]);
        [[fboTextures firstObject] attachToFramebuffer:GL_FRAMEBUFFER];

        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[1]);
        [[fboTextures lastObject] attachToFramebuffer:GL_FRAMEBUFFER];

        glBindTexture(GL_TEXTURE_2D, 0);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);

        CGImageRelease(sourceImage);
    } wait:NO];
}

- (void)renderToFramebuffer:(GLuint)fbo
{
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.quad rzx_render];
}

@end
