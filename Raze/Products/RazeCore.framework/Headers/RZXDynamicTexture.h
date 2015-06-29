//
//  RZXDynamicTexture.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <CoreGraphics/CGGeometry.h>
#import <RazeCore/RZXTexture.h>

typedef void (^RZXTextureRenderBlock)(RZXTexture *self, CGContextRef ctx);

@interface RZXDynamicTexture : RZXTexture

@property (assign, nonatomic, readonly) CGSize size;
@property (assign, nonatomic, readonly) CGFloat scale;

+ (instancetype)textureWithSize:(CGSize)size scale:(CGFloat)scale;

- (void)updateWithBlock:(RZXTextureRenderBlock)renderBlock;

@end
