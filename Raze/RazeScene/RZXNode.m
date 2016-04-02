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
#import <RazeScene/RZXNode_Private.h>

#import <RazeScene/RZXScene.h>

@interface RZXNode ()

@property (strong, nonatomic) NSMutableArray *mutableChildren;
@property (weak, nonatomic, readwrite) RZXNode *parent;

@property (strong, nonatomic) NSMutableDictionary *mutableAnimations;

@property (copy, nonatomic) RZXTransform3D *snapshotTransform;

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

- (GLKVector2)resolution
{
    GLKVector2 resolution = _resolution;

    if ( (resolution.x <= 0.0f || resolution.y <= 0.0f) && self.parent != nil ) {
        resolution = self.parent.resolution;
    }

    return resolution;
}

- (NSArray *)children
{
    return [self.mutableChildren copy];
}

- (void)setTransform:(RZXTransform3D *)transform
{
    _transform = (transform != nil) ? [transform copy] : [RZXTransform3D transform];
}

- (void)setPhysicsBody:(RZXPhysicsBody *)physicsBody
{
    if ( _physicsBody != physicsBody ) {
        RZXScene *scene = self.scene;

        if ( scene != nil) {
            [scene.physicsWorld removeCollider:_physicsBody.collider];
            [scene.physicsWorld addCollider:physicsBody.collider];
        }

        _physicsBody.node = nil;
        _physicsBody = physicsBody;
        _physicsBody.node = self;
    }
}

- (void)addChild:(RZXNode *)child
{
    [self insertChild:child atIndex:self.mutableChildren.count];
}

- (void)insertChild:(RZXNode *)child atIndex:(NSUInteger)index
{
    [self.mutableChildren insertObject:child atIndex:index];
    child.parent = self;
    child.scene = self.scene;
}

- (void)removeFromParent
{
    [self.parent.mutableChildren removeObject:self];
    self.parent = nil;
    self.scene = nil;
}

- (void)didMoveToParent:(RZXNode *)parent
{
    // subclass override
}

- (BOOL)isDescendantOfNode:(RZXNode *)node
{
    __block BOOL descendant = NO;

    [self traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
        descendant = (ancestor == node);
        *stop = descendant;
    }];

    return descendant;
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

- (GLKVector3)convertPoint:(GLKVector3)point fromNode:(RZXNode *)node
{
    __block GLKVector3 convertedPoint = point;

    if ( node != self && [node isDescendantOfNode:self] ) {
        [node.parent traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
            convertedPoint = RZXMatrix4TransformVector3(ancestor.transform.modelMatrix, convertedPoint);
            *stop = (ancestor == self);
        }];
    }

    return convertedPoint;
}

- (GLKVector3)convertPoint:(GLKVector3)point toNode:(RZXNode *)node
{
    __block GLKVector3 convertedPoint = point;

    if ( [node isDescendantOfNode:self] ) {
        [node traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
            GLKMatrix4 invertedTransform = GLKMatrix4Invert(ancestor.transform.modelMatrix, NULL);
            convertedPoint = RZXMatrix4TransformVector3(invertedTransform, convertedPoint);
            *stop = (ancestor.parent == self);
        }];
    }

    return convertedPoint;
}

- (GLKVector3)convertScale:(GLKVector3)scale fromNode:(RZXNode *)node
{
    __block GLKVector3 convertedScale = scale;

    if ( node != self && [node isDescendantOfNode:self] ) {
        [node.parent traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
            convertedScale = GLKVector3Multiply(convertedScale, ancestor.transform.scale);
            *stop = (ancestor == self);
        }];
    }

    return convertedScale;
}

- (GLKVector3)convertScale:(GLKVector3)scale toNode:(RZXNode *)node
{
    __block GLKVector3 convertedScale = scale;

    if ( [node isDescendantOfNode:self] ) {
        [node traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
            convertedScale = GLKVector3Divide(convertedScale, ancestor.transform.scale);
            *stop = (ancestor.parent == self);
        }];
    }

    return convertedScale;
}

- (GLKQuaternion)convertRotation:(GLKQuaternion)rotation fromNode:(RZXNode *)node
{
    __block GLKQuaternion convertedRotation = rotation;

    if ( node != self && [node isDescendantOfNode:self] ) {
        [node.parent traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
            convertedRotation = GLKQuaternionMultiply(convertedRotation, ancestor.transform.rotation);
            *stop = (ancestor == self);
        }];
    }

    return convertedRotation;
}

- (GLKQuaternion)convertRotation:(GLKQuaternion)rotation toNode:(RZXNode *)node
{
    __block GLKQuaternion convertedRotation = rotation;

    if ( [node isDescendantOfNode:self] ) {
        [node traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
            GLKQuaternion invertedRotation = GLKQuaternionInvert(ancestor.transform.rotation);
            convertedRotation = GLKQuaternionMultiply(convertedRotation, invertedRotation);
            *stop = (ancestor.parent == self);
        }];
    }

    return convertedRotation;
}

- (RZXTransform3D *)convertTransform:(RZXTransform3D *)transform fromNode:(RZXNode *)node
{
    RZXTransform3D *convertedTransform = [transform copy];

    if ( node != self && [node isDescendantOfNode:self] && node != self ) {
        [node.parent traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
            [convertedTransform transformBy:ancestor.transform];
            *stop = (ancestor == self);
        }];
    }

    return convertedTransform;
}

- (RZXTransform3D *)convertTransform:(RZXTransform3D *)transform toNode:(RZXNode *)node
{
    RZXTransform3D *convertedTransform = [transform copy];

    if ( [node isDescendantOfNode:self] ) {
        [node traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
            [convertedTransform transformBy:[ancestor.transform invertedTransform]];
            *stop = (ancestor.parent == self);
        }];
    }

    return convertedTransform;
}

#pragma mark - Animation

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

#pragma mark - Physics

- (void)didBeginContact:(RZXCollider *)collider
{
    // subclass override
}

- (void)didEndContact:(RZXCollider *)collider
{
    // subclass override
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
        self.effect.resolution = self.resolution;

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

    // Update the collider with the current world transform of the node
    if ( self.physicsBody.collider != nil ) {
        self.physicsBody.collider.transform = [self.scene convertTransform:self.transform fromNode:self];
    }
}

#pragma mark - RZXRenderable

- (void)rzx_render
{
    // TODO: because this method is called on a background thread, it should be thread safe
    for ( RZXNode *child in self.children ) {
        [child bindGL];
        [child rzx_render];
    }
}

#pragma mark - private methods

- (void)setParent:(RZXNode *)parent
{
    if ( _parent != parent ) {
        _parent = parent;

        [self didMoveToParent:parent];
    }
}

- (void)setScene:(RZXScene *)scene
{
    if ( _scene != scene ) {
        _scene = scene;

        RZXCollider *collider = self.physicsBody.collider;

        if ( collider != nil ) {
            if ( scene == nil ) {
                [scene.physicsWorld removeCollider:collider];
            }
            else {
                [scene.physicsWorld addCollider:collider];
            }
        }

        [self didMoveToScene:scene];
    }
}

- (void)snapshotCurrentTransform
{
    self.snapshotTransform = _transform;
}

- (void)revertToSnapshot
{
    NSAssert(_snapshotTransform != nil, @"Failed to revert to snapshot because snapshot doesn't exist!");

    if ( _snapshotTransform != nil ) {
        _transform = _snapshotTransform;
        _snapshotTransform = nil;
    }
}

- (void)traverseAncestorsWithBlock:(void (^)(RZXNode *ancestor, BOOL *stop))traversalBlock
{
    RZXNode *current = self;
    BOOL stop = NO;

    while ( current != nil && !stop ) {
        traversalBlock(current, &stop);
        current = current.parent;
    }

}

@end
