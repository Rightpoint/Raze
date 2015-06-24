//
//  RZXCompositeEffect.m
//
//  Created by Rob Visentin on 1/16/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZXCompositeEffect.h"

@interface RZXCompositeEffect ()

@property (strong, nonatomic, readwrite) RZXEffect *firstEffect;
@property (strong, nonatomic, readwrite) RZXEffect *secondEffect;

@property (strong, nonatomic, readwrite) RZXEffect *currentEffect;

@end

@implementation RZXCompositeEffect

+ (instancetype)compositeEffectWithFirstEffect:(RZXEffect *)first secondEffect:(RZXEffect *)second
{
    RZXCompositeEffect *effect = [[self alloc] init];
    effect.firstEffect = first;
    effect.secondEffect = second;
    effect.currentEffect = effect.firstEffect;
    
    return effect;
}

- (BOOL)isLinked
{
    return self.firstEffect.isLinked && self.secondEffect.isLinked;
}

- (void)setModelViewMatrix:(GLKMatrix4)modelViewMatrix
{
    [super setModelViewMatrix:modelViewMatrix];

    self.firstEffect.modelViewMatrix = modelViewMatrix;
    self.secondEffect.modelViewMatrix = modelViewMatrix;
}

- (void)setProjectionMatrix:(GLKMatrix4)projectionMatrix
{
    [super setProjectionMatrix:projectionMatrix];

    self.firstEffect.projectionMatrix = projectionMatrix;
    self.secondEffect.projectionMatrix = projectionMatrix;
}

- (void)setNormalMatrix:(GLKMatrix3)normalMatrix
{
    [super setNormalMatrix:normalMatrix];

    self.firstEffect.normalMatrix = normalMatrix;
    self.secondEffect.normalMatrix = normalMatrix;
}

- (void)setResolution:(GLKVector2)resolution
{
    [super setResolution:resolution];

    self.firstEffect.resolution = resolution;
    self.secondEffect.resolution = resolution;
}

- (GLuint)downsampleLevel
{
    return [super downsampleLevel] + self.currentEffect.downsampleLevel;
}

- (NSInteger)preferredLevelOfDetail
{
    return MAX(self.firstEffect.preferredLevelOfDetail, self.secondEffect.preferredLevelOfDetail);
}

- (BOOL)link
{
    return [self.firstEffect link] && [self.secondEffect link];
}

- (BOOL)prepareToDraw
{
    BOOL unfinished = YES;
    
    if ( self.currentEffect == self.firstEffect ) {
        if ( ![self.firstEffect prepareToDraw] ) {
            if ( self.secondEffect != nil ) {
                self.currentEffect = self.secondEffect;
            }
            else {
                unfinished = NO;
            }
        }
    }
    else {
        unfinished = [self.secondEffect prepareToDraw];
        
        if ( !unfinished ) {
            self.currentEffect = self.firstEffect;
        }
    }
    
    return unfinished;
}

- (void)bindAttribute:(NSString *)attribute location:(GLuint)location
{
    [self.currentEffect bindAttribute:attribute location:location];
}

- (GLint)uniformLoc:(NSString *)uniformName
{
    return [self.currentEffect uniformLoc:uniformName];
}

#pragma mark - RZXOpenGLObject

- (void)rzx_setupGL
{
    [self.firstEffect rzx_setupGL];
    [self.secondEffect rzx_setupGL];
}

- (void)rzx_bindGL
{
    [self.currentEffect rzx_bindGL];
}

- (void)rzx_teardownGL
{
    [self.firstEffect rzx_teardownGL];
    [self.secondEffect rzx_teardownGL];
}

@end
