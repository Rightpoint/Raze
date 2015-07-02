//
//  RZXTexture.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//
//

#import <OpenGLES/gltypes.h>
#import <RazeCore/RZXOpenGLObject.h>

OBJC_EXTERN NSString* const kRZXTextureMinFilterKey; /** Default GL_NEAREST */
OBJC_EXTERN NSString* const kRZXTextureMagFilterKey; /** Default GL_LINEAR */
OBJC_EXTERN NSString* const kRZXTextureSWrapKey;     /** Default GL_REPEAT */
OBJC_EXTERN NSString* const kRZXTextureTWrapKey;     /** Default GL_REPEAT */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"

@interface RZXTexture : NSObject <RZXOpenGLObject> {
    @protected
    GLuint _name;
}

- (void)applyOptions:(NSDictionary *)options;

@end

#pragma clang diagnostic pop
