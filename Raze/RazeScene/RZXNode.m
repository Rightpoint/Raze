//
//  RZXNode.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RazeCore.h>
#import <RazeEffects/RZXEffect.h>
#import <RazeAnimation/CAAnimation+RZXExtensions.h>
#import <RazeAnimation/RZXAnimatable.h>

#import <RazeScene/RZXNode.h>

@interface RZXNode ()

@property (strong, nonatomic) NSMutableArray *mutableChildren;
@property (weak, nonatomic, readwrite) RZXNode *parent;

@property (strong, nonatomic) NSMutableDictionary *mutableAnimations;

@end

@implementation RZXNode

#pragma mark - lifecycle

+ (void)load
{
    @autoreleasepool {
        [self rzx_addKVCComplianceForGLKTypes];
    }
}

+ (instancetype)node
{
    return [[self alloc] init];
}

- (instancetype)init
{
    if ( (self = [super init]) ) {
        _mutableChildren = [NSMutableArray array];
        _mutableAnimations = [NSMutableDictionary dictionary];
        _transform = [RZXTransform3D transform];
    }
    return self;
}

#pragma mark - public methods

- (RZXEffect *)effect
{
    RZXEffect *effect = _effect;
    
    if ( effect == nil && self.parent != nil ) {
        effect = self.parent.effect;
    }
    
    return effect;
}

- (NSArray *)children
{
    return [self.mutableChildren copy];
}

- (void)addChild:(RZXNode *)child
{
    [self insertChild:child atIndex:self.mutableChildren.count];
}

- (void)insertChild:(RZXNode *)child atIndex:(NSUInteger)index
{
    [self.mutableChildren insertObject:child atIndex:index];
    child.parent = self;
}

- (void)removeFromParent
{
    [self.parent.mutableChildren removeObject:self];
    self.parent = nil;
}

- (GLKMatrix4)modelMatrix
{
    GLKMatrix4 modelMatrix = self.transform ? self.transform.modelMatrix : GLKMatrix4Identity;
    
    if ( self.parent != nil ) {
        modelMatrix = GLKMatrix4Multiply([self.parent modelMatrix], modelMatrix);
    }
    
    return modelMatrix;
}

- (GLKMatrix4)viewMatrix
{
    GLKMatrix4 viewMatrix = self.camera ? self.camera.viewMatrix : GLKMatrix4Identity;
    
    if ( self.parent != nil ) {
        viewMatrix = GLKMatrix4Multiply([self.parent viewMatrix], viewMatrix);
    }
    
    return viewMatrix;
}

- (GLKMatrix4)projectionMatrix
{
    GLKMatrix4 projectionMatrix = self.camera ? self.camera.projectionMatrix : GLKMatrix4Identity;
    
    if ( self.parent != nil ) {
        projectionMatrix = GLKMatrix4Multiply([self.parent projectionMatrix], projectionMatrix);
    }
    
    return projectionMatrix;
}

- (void)addAnimation:(CAAnimation *)animation forKey:(NSString *)key
{
    animation = [animation copy];
    key = key ?: [NSString stringWithFormat:@"%p", animation];
    [self removeAnimationForKey:key];
    self.mutableAnimations[key] = animation;
}

- (CAAnimation *)animationForKey:(NSString *)key
{
    return [self.mutableAnimations[key] copy];
}

- (void)removeAnimationForKey:(NSString *)key
{
    [self.mutableAnimations[key] rzx_interrupt];
    [self.mutableAnimations removeObjectForKey:key];
}

#pragma mark - RZXGPUObject overrides

- (BOOL)setupGL
{
    BOOL setup = [super setupGL];

    setup &= [self.effect setupGL];
    
    for ( RZXNode *child in self.children ) {
        setup &= [child setupGL];
    }

    return setup;
}

- (BOOL)bindGL
{
    BOOL bound = [super bindGL];

    if ( bound ) {
        // TODO: get resolution somehow
        //    self.effect.resolution = GLKVector2Make(_backingWidth, _backingHeight);

        GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply([self viewMatrix], [self modelMatrix]);

        self.effect.modelViewMatrix = modelViewMatrix;
        self.effect.projectionMatrix = [self projectionMatrix];

        // can use modelView matrix for normal matrix if only uniform scaling occurs
        GLKVector3 scale = self.transform.scale;

        if ( scale.x == scale.y && scale.y == scale.z ) {
            self.effect.normalMatrix = GLKMatrix4GetMatrix3(modelViewMatrix);
        }
        else {
            self.effect.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
        }
        
        [self.effect prepareToDraw];
    }

    return bound;
}

- (void)teardownGL
{
    [super teardownGL];
    
    [self.effect teardownGL];
    
    for ( RZXNode *child in self.children ) {
        [child teardownGL];
    }
}

#pragma mark - RZXUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    for ( NSString *key in self.mutableAnimations.allKeys ) {
        CAAnimation *animation = self.mutableAnimations[key];

        [animation rzx_update:dt];
        [animation rzx_applyToObject:self];

        if ( animation.rzx_isFinished ) {
            [self.mutableAnimations removeObjectForKey:key];
        }
    }

    for ( RZXNode *child in self.children ) {
        [child rzx_update:dt];
    }
}

#pragma mark - RZXRenderable

- (void)rzx_render
{
    for ( RZXNode *child in self.children ) {
        [child bindGL];
        [child rzx_render];
    }
}

@end
