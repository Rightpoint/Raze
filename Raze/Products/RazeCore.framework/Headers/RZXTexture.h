//
//  RZXTexture.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <RazeCore/RZXGPUObject.h>

OBJC_EXTERN NSString* const kRZXTextureMinFilterKey; /** Default GL_NEAREST */
OBJC_EXTERN NSString* const kRZXTextureMagFilterKey; /** Default GL_LINEAR */
OBJC_EXTERN NSString* const kRZXTextureSWrapKey;     /** Default GL_REPEAT */
OBJC_EXTERN NSString* const kRZXTextureTWrapKey;     /** Default GL_REPEAT */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"

@interface RZXTexture : RZXGPUObject {
    @protected
    GLuint _name;
    CGSize _size;
}

// NOTE: If the texture is not yet loaded, it will be loaded in the default context before returning.
@property (assign, nonatomic, readonly) CGSize size;

- (void)applyOptions:(NSDictionary *)options;

- (void)attachToFramebuffer:(GLenum)framebuffer;

@end

#pragma clang diagnostic pop
