//
//  RZXTexture.m
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <RazeCore/RZXTexture.h>

NSString* const kRZXTextureMinFilterKey = @"RZXTextureMinFilter";
NSString* const kRZXTextureMagFilterKey = @"RZXTextureMagFilter";
NSString* const kRZXTextureSWrapKey     = @"RZXTextureSWrap";
NSString* const kRZXTextureTWrapKey     = @"RZXTextureTWrap";

@implementation RZXTexture

#pragma mark - public methods

- (CGSize)size
{
    if ( self.configuredContext == nil ) {
        [[RZXGLContext defaultContext] runBlock:^(RZXGLContext *context) {
            [self setupGL];
        }];
    }

    return _size;
}

- (void)applyOptions:(NSDictionary *)options
{
    if ( options.count && [RZXGLContext currentContext] != nil ) {
        if ( _name ) {
            [self bindGL];

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

#pragma mark - RZXGPUObject overrides

- (RZXGPUObjectTeardownBlock)teardownHandler
{
    RZXGPUObjectTeardownBlock teardown = nil;

    if ( _name != 0 ) {
        GLuint name = _name;
        teardown = ^(RZXGLContext *context) {
            glDeleteTextures(1, &name);
        };
    }

    return teardown;
}

- (BOOL)bindGL
{
    BOOL bound = [super bindGL];

    if ( bound ) {
        self.configuredContext.activeTexture = GL_TEXTURE0;
        glBindTexture(GL_TEXTURE_2D, _name);
    }

#if DEBUG
    bound &= !RZXGLError();
#endif

    return bound;
}

- (void)teardownGL
{
    [super teardownGL];

    _name = 0;
}

@end
