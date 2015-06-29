//
//  RZXDynamicTexture.m
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <OpenGLES/ES2/glext.h>
#import <RazeCore/RZXGLContext.h>
#import <RazeCore/RZXDynamicTexture.h>

@implementation RZXDynamicTexture {
    GLsizei _texWidth;
    GLsizei _texHeight;

    CVPixelBufferRef _pixBuffer;
    CVOpenGLESTextureRef _tex;

    CGContextRef _context;
}

+ (instancetype)textureWithSize:(CGSize)size scale:(CGFloat)scale
{
    return [[[self class] alloc] initWithSize:size scale:scale];
}

- (instancetype)initWithSize:(CGSize)size scale:(CGFloat)scale
{
    self = [super init];
    if ( self ) {
        _size = size;
        _scale = scale;

        _texWidth = size.width * scale;
        _texHeight = size.height * scale;
    }
    return self;
}

- (void)updateWithBlock:(RZXTextureRenderBlock)renderBlock
{
    if ( renderBlock != nil ) {
        CVPixelBufferLockBaseAddress(_pixBuffer, 0);
        renderBlock(self, _context);
        CVPixelBufferUnlockBaseAddress(_pixBuffer, 0);
    }
}

#pragma mark - RZXOpenGLObject

- (void)rzx_setupGL
{
    RZXGLContext *currentContext = [RZXGLContext currentContext];

    if ( currentContext != nil ) {
        [self rzx_teardownGL];

        NSDictionary *buffersAttrs = @{(__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey : [NSDictionary dictionary]};

        CVPixelBufferCreate(NULL, _texWidth, _texHeight, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)(buffersAttrs), &_pixBuffer);

        CVPixelBufferLockBaseAddress(_pixBuffer, 0);

        _tex = [currentContext textureWithPixelBuffer:_pixBuffer];

        _name = CVOpenGLESTextureGetName(_tex);

        glBindTexture(GL_TEXTURE_2D, _name);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        glBindTexture(GL_TEXTURE_2D, 0);

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        _context = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(_pixBuffer), _texWidth, _texHeight, 8, CVPixelBufferGetBytesPerRow(_pixBuffer), colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
        CGColorSpaceRelease(colorSpace);

        CGContextScaleCTM(_context, _scale, _scale);

        CVPixelBufferUnlockBaseAddress(_pixBuffer, 0);
    }
    else {
        NSLog(@"Failed to setup %@: No active context!", [self class]);
    }
}

- (void)rzx_teardownGL
{
    // explicity not calling super
    
    CGContextRelease(_context);
    CVPixelBufferRelease(_pixBuffer);

    if ( _tex != nil ) {
        CFRelease(_tex);
    }

    _context = NULL;
    _pixBuffer = NULL;
    _tex = NULL;
}

@end
