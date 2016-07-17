//
//  RZXNode.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RazeCore.h>
#import <RazeEffects/RZXEffect.h>
#import <RazeAnimation/RZXAnimatable.h>
#import <RazeAnimation/RazeCore+RZXAnimation.h>

#import <RazeScene/RZXNode.h>
#import <RazeScene/RZXNode_Private.h>
#import <RazeScene/RZXScene.h>

@interface RZXNode ()

@property (strong, nonatomic) NSMutableArray *mutableChildren;
@property (weak, nonatomic, readwrite) RZXNode *parent;

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
        _animator = [RZXAnimator animatorForObject:self];
    }
    return self;
}

#pragma mark - public methods

- (RZXTransform3D *)transform
{
    if ( _transform == nil ) {
        _transform = [RZXTransform3D transform];
    }
    return _transform;
}

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
    __block GLKMatrix4 modelMatrix = self.transform.modelMatrix;

    [self.parent traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
        modelMatrix = GLKMatrix4Multiply(ancestor.transform.modelMatrix, modelMatrix);
    }];

    return modelMatrix;
}

- (GLKMatrix4)viewMatrix
{
    __block GLKMatrix4 viewMatrix = self.camera ? self.camera.viewMatrix : GLKMatrix4Identity;

    [self.parent traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
        RZXCamera *cam = ancestor.camera;
        if ( cam != nil ) {
            viewMatrix = GLKMatrix4Multiply(cam.viewMatrix, viewMatrix);
        }
    }];

    return viewMatrix;
}

- (GLKMatrix4)projectionMatrix
{
    __block GLKMatrix4 projectionMatrix = self.camera ? self.camera.projectionMatrix : GLKMatrix4Identity;
    
    [self.parent traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
        RZXCamera *cam = ancestor.camera;
        if ( cam != nil ) {
            projectionMatrix = GLKMatrix4Multiply(cam.projectionMatrix, projectionMatrix);
        }
    }];
    
    return projectionMatrix;
}

- (GLKVector3)convertPoint:(GLKVector3)point toNode:(RZXNode *)node
{
    __block GLKVector3 convertedPoint = point;

    if ( node != self ) {
        if ( [node isDescendantOfNode:self] ) {
            [node traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
                GLKMatrix4 invertedTransform = GLKMatrix4Invert(ancestor.transform.modelMatrix, NULL);
                convertedPoint = RZXMatrix4TransformVector3(invertedTransform, convertedPoint);
                *stop = (ancestor.parent == self);
            }];
        }
        else if ( node == nil || [self isDescendantOfNode:node] ) {
            [self traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
                convertedPoint = RZXMatrix4TransformVector3(ancestor.transform.modelMatrix, convertedPoint);
                *stop = (ancestor.parent == node);
            }];
        }
    }

    return convertedPoint;
}

- (GLKVector3)convertPoint:(GLKVector3)point fromNode:(RZXNode *)node
{
    return [node convertPoint:point toNode:self];
}

- (GLKVector3)convertScale:(GLKVector3)scale toNode:(RZXNode *)node
{
    __block GLKVector3 convertedScale = scale;

    if ( node != self ) {
        if ( [node isDescendantOfNode:self] ) {
            [node traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
                convertedScale = GLKVector3Divide(convertedScale, ancestor.transform.scale);
                *stop = (ancestor.parent == self);
            }];
        }
        else if ( node == nil || [self isDescendantOfNode:node] ) {
            [self traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
                convertedScale = GLKVector3Multiply(convertedScale, ancestor.transform.scale);
                *stop = (ancestor.parent == node);
            }];
        }
    }

    return convertedScale;
}

- (GLKVector3)convertScale:(GLKVector3)scale fromNode:(RZXNode *)node
{
    return [node convertScale:scale toNode:self];
}

- (GLKQuaternion)convertRotation:(GLKQuaternion)rotation toNode:(RZXNode *)node
{
    __block GLKQuaternion convertedRotation = rotation;

    if ( node != self ) {
        if ( [node isDescendantOfNode:self] ) {
            [node traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
                GLKQuaternion invertedRotation = GLKQuaternionInvert(ancestor.transform.rotation);
                convertedRotation = GLKQuaternionMultiply(invertedRotation, convertedRotation);
                *stop = (ancestor.parent == self);
            }];
        }
        else if ( node == nil || [self isDescendantOfNode:node] ) {
            [self traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
                convertedRotation = GLKQuaternionMultiply(ancestor.transform.rotation, convertedRotation);
                *stop = (ancestor.parent == node);
            }];
        }
    }

    return convertedRotation;
}

- (GLKQuaternion)convertRotation:(GLKQuaternion)rotation fromNode:(RZXNode *)node
{
    return [node convertRotation:rotation toNode:self];
}

- (RZXTransform3D *)convertTransform:(RZXTransform3D *)transform toNode:(RZXNode *)node
{
    RZXTransform3D *convertedTransform = [transform copy];

    if ( node != self ) {
        if ( [node isDescendantOfNode:self] ) {
            [node traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
                [convertedTransform leftTransformBy:[ancestor.transform invertedTransform]];
                *stop = (ancestor.parent == self);
            }];
        }
        else if ( node == nil || [self isDescendantOfNode:node] ) {
            [self traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
                [convertedTransform leftTransformBy:ancestor.transform];
                *stop = (ancestor.parent == node);
            }];
        }
    }

    return convertedTransform;
}

- (RZXTransform3D *)convertTransform:(RZXTransform3D *)transform fromNode:(RZXNode *)node
{
    return [node convertTransform:transform toNode:self];
}

#pragma mark - Physics

- (RZXTransform3D *)worldTransform
{
    RZXTransform3D *transform = [self.transform copy];

    [self.parent traverseAncestorsWithBlock:^(RZXNode *ancestor, BOOL *stop) {
        [transform leftTransformBy:ancestor.transform];
    }];

    return transform;
}

- (void)willSimulatePhysics
{
    // subclass override
}

- (void)didSimulatePhysics
{
    // subclass override
}

- (void)setPhysicsBody:(RZXPhysicsBody *)physicsBody
{
    if ( _physicsBody != physicsBody ) {
        RZXScene *scene = self.scene;

        if ( scene != nil) {
            [scene.physicsWorld removeBody:_physicsBody];
            [scene.physicsWorld addBody:physicsBody];
        }

        _physicsBody.representedObject = nil;
        _physicsBody = physicsBody;
        _physicsBody.representedObject = self;
    }
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
    [self.animator rzx_update:dt];
    [self.camera rzx_update:dt];

    for ( RZXNode *child in self.children ) {
        [child rzx_update:dt];
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

        RZXPhysicsBody *body = self.physicsBody;

        if ( body != nil ) {
            if ( scene == nil ) {
                [scene.physicsWorld removeBody:body];
            }
            else {
                [scene.physicsWorld addBody:body];
            }
        }

        for ( RZXNode *child in self.children ) {
            child.scene = scene;
        }

        [self didMoveToScene:scene];
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

@implementation RZXPhysicsBody (RZXNode)

- (RZXNode *)node
{
    id<RZXPhysicsObject> representedObject = self.representedObject;
    return [representedObject isKindOfClass:[RZXNode class]] ? (RZXNode *)representedObject : nil;
}

@end
