//
//  RZXDynamicTexture.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <CoreGraphics/CGGeometry.h>
#import <RazeCore/RZXTexture.h>


typedef void (^RZXTextureRenderBlock)(id self, CGContextRef ctx);

/**
 *  A texture that is expected to be modified with each update call. Core video pixel buffers are used for rapid texture generation. (Note that on the simulator this approach is not used and dynamic textures will perform exceptionally poorly.
 */
@interface RZXDynamicTexture : RZXTexture


@property (assign, nonatomic, readonly) CGFloat scale;

// Initialize a dynamic texture. Screen scale is typcially UIScreen.MainScreen.Scale
+ (instancetype)textureWithSize:(CGSize)size scale:(CGFloat)scale;

- (void)updateWithBlock:(RZXTextureRenderBlock)renderBlock;

- (CGImageRef)createImageRepresentation CF_RETURNS_RETAINED;

@end
