//
//  RZXDynamicTexture.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <CoreGraphics/CGGeometry.h>
#import <RazeCore/RZXTexture.h>

/**
 *  <#Description#>
 *
 *  @param self <#self description#>
 *  @param ctx  <#ctx description#>
 */
typedef void (^RZXTextureRenderBlock)(id self, CGContextRef ctx);

/**
 *  A texture that is expected to be modified with each update call. Core video pixel buffers are used for rapid texture generation. (Note that on the simulator this approach is not used and dynamic textures will perform exceptionally poorly.
 */
@interface RZXDynamicTexture : RZXTexture


@property (assign, nonatomic, readonly) CGFloat scale;

/**
 *  Initialize a dynamic texture
 *
 *  @param size  size as CGSize
 *  @param scale screen scalle (typically UIScreen.MainScreen.Scale)
 *
 *  @return dynamic texture instance
 */
+ (instancetype)textureWithSize:(CGSize)size scale:(CGFloat)scale;

/**
 *  Method to call on texture update
 *
 *  @param renderBlock code to execute with each update
 */
- (void)updateWithBlock:(RZXTextureRenderBlock)renderBlock;

/**
 *  Get an image representation of the texture
 *
 *  @return CGImageRef (Retained)
 */
- (CGImageRef)createImageRepresentation CF_RETURNS_RETAINED;

@end
