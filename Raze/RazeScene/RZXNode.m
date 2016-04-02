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

@end

@implementation RZXNode {
    RZXTransform3D *_snapshotTransform;
}

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
    BOOL descendant = NO;
    RZXNode *current = node;

    do {
        if ( current == self ) {
            return YES;
        }
    } while ( current != nil && !descendant );

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

    if ( [node isDescendantOfNode:self] ) {
        [node traverseAncestorsUntil: self withBlock:^(RZXNode *ancestor) {
            convertedPoint = RZXMatrix4TransformVector3(ancestor.transform.modelMatrix, convertedPoint);
        }];
    }

    return convertedPoint;
}

- (GLKVector3)convertPoint:(GLKVector3)point toNode:(RZXNode *)node
{
    __block GLKVector3 convertedPoint = point;

    if ( [node isDescendantOfNode:self] ) {
        [node traverseAncestorsUntil: self withBlock:^(RZXNode *ancestor) {
            GLKMatrix4 invertedTransform = GLKMatrix4Invert(ancestor.transform.modelMatrix, NULL);
            convertedPoint = RZXMatrix4TransformVector3(invertedTransform, convertedPoint);
        }];
    }

    return convertedPoint;
}

- (GLKVector3)convertScale:(GLKVector3)scale fromNode:(RZXNode *)node
{
    __block GLKVector3 convertedScale = scale;

    if ( [node isDescendantOfNode:self] ) {
        [node traverseAncestorsUntil: self withBlock:^(RZXNode *ancestor) {
            convertedScale = GLKVector3Multiply(convertedScale, ancestor.transform.scale);
        }];
    }

    return convertedScale;
}

- (GLKVector3)convertScale:(GLKVector3)scale toNode:(RZXNode *)node
{
    __block GLKVector3 convertedScale = scale;

    if ( [node isDescendantOfNode:self] ) {
        [node traverseAncestorsUntil: self withBlock:^(RZXNode *ancestor) {
            convertedScale = GLKVector3Divide(convertedScale, ancestor.transform.scale);
        }];
    }

    return convertedScale;
}

- (GLKQuaternion)convertRotation:(GLKQuaternion)rotation fromNode:(RZXNode *)node
{
    __block GLKQuaternion convertedRotation = rotation;

    if ( [node isDescendantOfNode:self] ) {
        [node traverseAncestorsUntil: self withBlock:^(RZXNode *ancestor) {
            convertedRotation = GLKQuaternionMultiply(convertedRotation, ancestor.transform.rotation);
        }];
    }

    return convertedRotation;
}

- (GLKQuaternion)convertRotation:(GLKQuaternion)rotation toNode:(RZXNode *)node
{
    __block GLKQuaternion convertedRotation = rotation;

    if ( [node isDescendantOfNode:self] ) {
        [node traverseAncestorsUntil: self withBlock:^(RZXNode *ancestor) {
            GLKQuaternion invertedRotation = GLKQuaternionInvert(ancestor.transform.rotation);
            convertedRotation = GLKQuaternionMultiply(convertedRotation, invertedRotation);
        }];
    }

    return convertedRotation;
}

- (RZXTransform3D *)convertTransform:(RZXTransform3D *)transform fromNode:(RZXNode *)node
{
    RZXTransform3D *convertedTransform = [transform copy];

    if ( [node isDescendantOfNode:self] ) {
        [node traverseAncestorsUntil: self withBlock:^(RZXNode *ancestor) {
            [convertedTransform transformBy:ancestor.transform];
        }];
    }

    return convertedTransform;
}

- (RZXTransform3D *)convertTransform:(RZXTransform3D *)transform toNode:(RZXNode *)node
{
    RZXTransform3D *convertedTransform = [transform copy];

    if ( [node isDescendantOfNode:self] ) {
        [node traverseAncestorsUntil: self withBlock:^(RZXNode *ancestor) {
            [convertedTransform transformBy:[ancestor.transform invertedTransform]];
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
    // If the node will be involved in physics calculations,
    // save transform state in case it has to be reverted.
    if ( self.physicsBody.collider != nil ) {
        _snapshotTransform = [self.transform copy];

        // Update the collider with the current world transform of the node
        self.physicsBody.collider.transform = [self.scene convertTransform:self.transform fromNode:self];
    }

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

- (void)revertToSnapshot
{
    NSAssert(_snapshotTransform != nil, @"Failed to revert to snapshot because snapshot doesn't exist!");

    _transform = _snapshotTransform;
    _snapshotTransform = nil;
}

- (void)traverseAncestorsUntil:(RZXNode *)stopNode withBlock:(void (^)(RZXNode *ancestor))traversalBlock
{
    RZXNode *current = self;

    while ( current != nil && current != stopNode ) {
        traversalBlock(current);
    }

}

@end
