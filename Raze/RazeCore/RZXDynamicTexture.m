//
//  RZXDynamicTexture.m
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

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

#pragma mark - RZXGPUObject overrides

- (RZXGPUObjectTeardownBlock)teardownHandler
{
    // OpenGL texture is managed by the context's texture cache, so doesn't need to be freed here
    return nil;
}

- (BOOL)setupGL
{
    BOOL setup = [super setupGL];

    if ( setup ) {
        NSDictionary *buffersAttrs = @{(__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey : [NSDictionary dictionary]};

        CVReturn bufferStatus = CVPixelBufferCreate(NULL, _texWidth, _texHeight, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)(buffersAttrs), &_pixBuffer);

        if ( bufferStatus == kCVReturnSuccess ) {
            CVPixelBufferLockBaseAddress(_pixBuffer, 0);

            _tex = [self.configuredContext textureWithPixelBuffer:_pixBuffer];

            _name = CVOpenGLESTextureGetName(_tex);

            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            _context = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(_pixBuffer), _texWidth, _texHeight, 8, CVPixelBufferGetBytesPerRow(_pixBuffer), colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
            CGColorSpaceRelease(colorSpace);

            CGContextScaleCTM(_context, _scale, _scale);
            
            CVPixelBufferUnlockBaseAddress(_pixBuffer, 0);
        }
        else {
            RZXLog(@"Failed to setup %@: Unable to create CVPixelBuffer (Error %i)", NSStringFromClass([self class]), (int)bufferStatus);
        }
    }

#if DEBUG
    setup &= !RZXGLError();
#endif

    return setup;
}

- (void)teardownGL
{
    [super teardownGL];
    
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
