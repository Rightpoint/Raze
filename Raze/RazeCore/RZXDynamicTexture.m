//
//  RZXDynamicTexture.m
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <RazeCore/RZXGLContext.h>
#import <RazeCore/RZXDynamicTexture.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIGraphics.h>
#else
#warning Import things necessary to make CGGraphicsContext current on OSX
#endif

#if RZX_CV_AVAILABLE
#define RZX_DYNAMIC_TEXTURE_LOCK(flags) { \
CVPixelBufferLockBaseAddress(_pixBuffer, flags); \
}
#define RZX_DYNAMIC_TEXTURE_UNLOCK(flags) { \
CVPixelBufferUnlockBaseAddress(_pixBuffer, flags); \
}
#else
#define RZX_DYNAMIC_TEXTURE_LOCK(flags)
#define RZX_DYNAMIC_TEXTURE_UNLOCK(flags)

// Bitmap CGContexts should be 16-byte aligned. See:
// https://developer.apple.com/library/ios/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_context/dq_context.html
static size_t const kRZXDynamicTextureByteAlignment = 16;

NS_INLINE size_t RZXAlignSize(size_t size)
{
    return ceil(size / (double)kRZXDynamicTextureByteAlignment) * kRZXDynamicTextureByteAlignment;
}

#endif

@implementation RZXDynamicTexture {
    GLsizei _texWidth;
    GLsizei _texHeight;

#if RZX_CV_AVAILABLE
    CVPixelBufferRef _pixBuffer;
    CVOpenGLESTextureRef _tex;
#else
    void *_pixData;
#endif

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
    if ( renderBlock != nil && _context != nil ) {
        RZX_DYNAMIC_TEXTURE_LOCK(0);
        UIGraphicsPushContext(_context);
        renderBlock(self, _context);
        UIGraphicsPopContext();
        RZX_DYNAMIC_TEXTURE_UNLOCK(0);

#if !RZX_CV_AVAILABLE
        [self.configuredContext runBlock:^(RZXGLContext *context) {
            glBindTexture(GL_TEXTURE_2D, _name);
            glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, (GLsizei)RZXAlignSize(_texWidth), _texHeight, GL_BGRA, GL_UNSIGNED_BYTE, _pixData);
            glBindTexture(GL_TEXTURE_2D, 0);
        } wait:NO];
#endif
    }
}

- (CGImageRef)createImageRepresentation
{
    CGImageRef image = nil;

    if ( _context != nil ) {
        RZX_DYNAMIC_TEXTURE_LOCK(kCVPixelBufferLock_ReadOnly);
        image = CGBitmapContextCreateImage(_context);
        RZX_DYNAMIC_TEXTURE_UNLOCK(kCVPixelBufferLock_ReadOnly);
    }

    return image;
}

#pragma mark - RZXGPUObject overrides

- (RZXGPUObjectTeardownBlock)teardownHandler
{
#if RZX_CV_AVAILABLE
    // OpenGL texture is managed by the context's texture cache, so doesn't need to be freed here
    return nil;
#else
    GLuint name = _name;
    return ^(RZXGLContext *context) {
        glDeleteTextures(1, &name);
    };
#endif
}

- (BOOL)setupGL
{
    BOOL setup = [super setupGL];

    if ( setup ) {
        if ( [self createTextureBuffer] ) {
            RZX_DYNAMIC_TEXTURE_LOCK(0);

#if RZX_CV_AVAILABLE
            void *contextData = CVPixelBufferGetBaseAddress(_pixBuffer);
            size_t bytesPerRow = CVPixelBufferGetBytesPerRow(_pixBuffer);
#else
            void *contextData = _pixData;
            size_t bytesPerRow = RZXAlignSize(_texWidth) * 4;
#endif

            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            _context = CGBitmapContextCreate(contextData,
                                             _texWidth,
                                             _texHeight,
                                             8,
                                             bytesPerRow,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);

            CGContextScaleCTM(_context, _scale, _scale);

            RZX_DYNAMIC_TEXTURE_UNLOCK(0);
            CGColorSpaceRelease(colorSpace);
        }
        else {
            setup = NO;
        }
    }

#if RZX_DEBUG
    setup &= !RZXGLError();
#endif

    return setup;
}

- (void)teardownGL
{
    [super teardownGL];
    
    CGContextRelease(_context);
    _context = nil;

#if RZX_CV_AVAILABLE
    CVPixelBufferRelease(_pixBuffer);

    if ( _tex != nil ) {
        CFRelease(_tex);
    }

    _pixBuffer = nil;
    _tex = nil;
#else
    free(_pixData);
    _pixData = NULL;
#endif
}

#pragma mark - private methods

- (BOOL)createTextureBuffer
{
    BOOL success = NO;

#if RZX_CV_AVAILABLE
    NSDictionary *buffersAttrs = @{(__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey : [NSDictionary dictionary]};

    CVReturn bufferStatus = CVPixelBufferCreate(NULL, _texWidth, _texHeight, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)(buffersAttrs), &_pixBuffer);

    if ( bufferStatus == kCVReturnSuccess ) {
        _tex = [self.configuredContext textureWithPixelBuffer:_pixBuffer];
        _name = CVOpenGLESTextureGetName(_tex);

        success = YES;
    }
    else {
        RZXLog(@"Failed to setup %@: Unable to create CVPixelBuffer (Error %i)", NSStringFromClass([self class]), (int)bufferStatus);
    }
#else
    free(_pixData);

    size_t alignedWidth = RZXAlignSize(_texWidth);
    size_t dataSize = RZXAlignSize(alignedWidth * _texHeight * 4);

    success = (posix_memalign(&_pixData, kRZXDynamicTextureByteAlignment, dataSize) == 0);

    if ( success ) {
        memset(_pixData, 0, dataSize);

        glGenTextures(1, &_name);
        glBindTexture(GL_TEXTURE_2D, _name);

        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)alignedWidth, _texHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, _pixData);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        // non power of 2 texture must be clamped to edge
        if ( log2(_texWidth) != 0.0 || log2(_texHeight) != 0.0 ) {
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }

        glBindTexture(GL_TEXTURE_2D, 0);

        success &= (_name != 0);
    }
#endif

    return success;
}

@end
