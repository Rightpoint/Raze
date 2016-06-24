//
//  RZXGPUObject.m
//  Raze
//
//  Created by Rob Visentin on 7/16/15.
//
//

#import "RZXGPUObject.h"

@interface RZXGPUObject ()

@property (strong, nonatomic, readwrite) RZXGLContext *configuredContext;

@end

@implementation RZXGPUObject

- (RZXGPUObjectTeardownBlock)teardownHandler
{
    return nil;
}

- (BOOL)setupGL
{
    RZXGLContext *currentContext = [RZXGLContext currentContext];

    BOOL setup = (self.configuredContext != nil);

    if ( setup && currentContext != nil && currentContext != self.configuredContext ) {
        [self teardownGL];
        setup = NO;
    }

    if ( !setup ) {
        if ( currentContext != nil ) {
            self.configuredContext = currentContext;
            setup = YES;
        }
        else {
            RZXLog(@"Failed to setup %@: No active context!", self);
        }
    }

    return setup;
}

- (BOOL)bindGL
{
    RZXGLContext *currentContext = [RZXGLContext currentContext];

    BOOL bound = (self.configuredContext != nil);

    if ( bound && currentContext != nil && currentContext != self.configuredContext ) {
        [self teardownGL];
        bound = NO;
    }

    if ( !bound ) {
        bound = [self setupGL];
    }

    return bound;
}

- (void)teardownGL
{
    if ( self.configuredContext != nil && self.teardownHandler != nil ) {
        [self.configuredContext runBlock:self.teardownHandler wait:NO];
    }

    self.configuredContext = nil;
}

- (void)dealloc
{
    [self teardownGL];
}

@end
