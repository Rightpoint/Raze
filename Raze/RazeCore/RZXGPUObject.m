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
    // TODO: when supporting multiple contexts, also ensure that the current context is the configured context
    BOOL setup = (self.configuredContext != nil);

    if ( !setup ) {
        // TODO: when supporting multiple contexts, also teardown in previous context

        RZXGLContext *currentContext = [RZXGLContext currentContext];

        if ( currentContext != nil ) {
            self.configuredContext = currentContext;
            setup = YES;
        }
        else {
            NSLog(@"Failed to setup %@: No active context!", NSStringFromClass([self class]));
        }
    }

    return setup;
}

- (BOOL)bindGL
{
    // TODO: when supporting multiple contexts, also ensure that the current context is the configured context
    BOOL bound = (self.configuredContext != nil);

    if ( !bound ) {
        bound = [self setupGL];
    }

    return bound;
}

- (void)teardownGL
{
    if ( self.teardownHandler != nil ) {
        [self.configuredContext runBlock:self.teardownHandler wait:NO];
    }

    self.configuredContext = nil;
}

- (void)dealloc
{
    [self teardownGL];
}

@end
