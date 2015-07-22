//
//  RZXDynamicTexture.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <CoreGraphics/CGGeometry.h>
#import <RazeCore/RZXTexture.h>

// !!!: This doesn't currently work in the simulator;
// TODO: provide simulator support

typedef void (^RZXTextureRenderBlock)(id self, CGContextRef ctx);

@interface RZXDynamicTexture : RZXTexture

@property (assign, nonatomic, readonly) CGFloat scale;

+ (instancetype)textureWithSize:(CGSize)size scale:(CGFloat)scale;

- (void)updateWithBlock:(RZXTextureRenderBlock)renderBlock;

- (CGImageRef)createImageRepresentation;

@end
