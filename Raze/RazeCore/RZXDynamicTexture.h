//
//  RZXDynamicTexture.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <CoreGraphics/CGGeometry.h>
#import <RazeCore/RZXTexture.h>

typedef void (^RZXTextureRenderBlock)(id self, CGContextRef ctx);

@interface RZXDynamicTexture : RZXTexture

@property (assign, nonatomic, readonly) CGFloat scale;

+ (instancetype)textureWithSize:(CGSize)size scale:(CGFloat)scale;

- (void)updateWithBlock:(RZXTextureRenderBlock)renderBlock;

- (CGImageRef)createImageRepresentation CF_RETURNS_RETAINED;

@end
