//
//  RZXTexture.m
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//
//

#import <OpenGLES/ES2/gl.h>
#import <RazeCore/RZXGLContext.h>
#import <RazeCore/RZXTexture.h>

NSString* const kRZXTextureMinFilterKey = @"RZXTextureMinFilter";
NSString* const kRZXTextureMagFilterKey = @"RZXTextureMagFilter";
NSString* const kRZXTextureSWrapKey     = @"RZXTextureSWrap";
NSString* const kRZXTextureTWrapKey     = @"RZXTextureTWrap";

@implementation RZXTexture

@synthesize size = _size;

#pragma mark - public methods

- (void)applyOptions:(NSDictionary *)options
{
    if ( options.count && [RZXGLContext currentContext] != nil ) {
        if ( _name ) {
            [self rzx_bindGL];

            if ( options[kRZXTextureMinFilterKey] != nil ) {
                GLint minFilter = [[options objectForKey:kRZXTextureMinFilterKey] intValue];
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
            }

            if ( options[kRZXTextureMagFilterKey] != nil ) {
                GLint magFilter = [[options objectForKey:kRZXTextureMagFilterKey] intValue];
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
            }

            if ( options[kRZXTextureSWrapKey] != nil ) {
                GLint sWrap = [[options objectForKey:kRZXTextureSWrapKey] intValue];
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, sWrap);
            }

            if ( options[kRZXTextureTWrapKey] != nil ) {
                GLint tWrap = [[options objectForKey:kRZXTextureTWrapKey] intValue];
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, tWrap);
            }
        }
    }
    else {
        NSLog(@"[%@] failed to apply options: %@. No active context!", [self class], options);
    }
}

#pragma mark - RZXOpenGLObject

- (void)rzx_setupGL
{
    // subclass override
}

- (void)rzx_bindGL
{
    [RZXGLContext currentContext].activeTexture = GL_TEXTURE0;
    glBindTexture(GL_TEXTURE_2D, _name);
}

- (void)rzx_teardownGL
{
    if ( _name ) {
        glDeleteTextures(1, &_name);
        _name = 0;
    }
}

@end
