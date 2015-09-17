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
    if ( options.count ) {
        GLuint name = _name;

        [self.configuredContext runBlock:^(RZXGLContext *context) {
            if ( name ) {
                glBindTexture(GL_TEXTURE_2D, name);

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
        } wait:NO];
    }
}

- (void)attachToFramebuffer:(GLenum)framebuffer
{
    glFramebufferTexture2D(framebuffer, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _name, 0);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p [%i, %i]>", [self class], self, (int)self.size.width, (int)self.size.height];
}

#pragma mark - RZXGPUObject overrides

- (RZXGPUObjectTeardownBlock)teardownHandler
{
    GLuint name = _name;
    return ^(RZXGLContext *context) {
        glDeleteTextures(1, &name);
    };
}

- (BOOL)bindGL
{
    BOOL bound = [super bindGL];

    if ( bound ) {
        self.configuredContext.activeTexture = GL_TEXTURE0;
        glBindTexture(GL_TEXTURE_2D, _name);
    }

#if RZX_DEBUG
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
