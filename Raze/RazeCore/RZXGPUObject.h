//
//  RZXGPUObject.h
//  RazeCode
//
//  Created by Rob Visentin on 7/16/15.
//

#import <RazeCore/RZXGLContext.h>
#import <RazeCore/RZXBase.h>

typedef void (^RZXGPUObjectTeardownBlock)(RZXGLContext *context);

/**
 *  The base class for objects representing a GPU resource.
 *  Examples include textures, meshes, and shader programs.
 */
@interface RZXGPUObject : NSObject

/**
 *  The context in which the object is currently configured, or nil if it has not been configured.
 */
@property (strong, nonatomic, readonly) RZXGLContext *configuredContext;

/**
 *  The block to invoke when the object is destroyed or explicitly torn down.
 *  This block must free any GPU or other resources before it exits.
 *
 *  @note Because this block is run asynchronously, it may be invoked after the RZXGPUObject has been deallocted. 
 *  Therefore it MUST NOT contain any implicit or explicity reference to self.
 */
@property (nonatomic, readonly) RZXGPUObjectTeardownBlock teardownHandler;

/**
 *  Configure the receiver in the current RZX context.
 *  If there is no current context, this method returns NO.
 *
 *  Subclasses must invoke super if overriding this method.
 *
 *  @return YES if configuration succeeded, NO otherwise.
 *
 *  @note In most cases this method is invoked internally at the appropriate times.
 *  Therefore, you should generally not call this method.
 */
- (BOOL)setupGL;

/**
 *  Binds any necessary GPU resources in the current context.
 *  If there is no current context, this method returns NO.
 *
 *  Subclasses must invoke super if overriding this method.
 *
 *  @return YES if the binding succeeded, NO otherwise.
 *
 *  @note If the object is not yet configured in the current context, this method first calls setupGL.
 */
- (BOOL)bindGL;

/**
 *  Invokes the teardownHandler asynchronously on the configuredContext, and then sets the currentContext to nil.
 *  This method is called automatically from dealloc, so you generally do not need to call this method.
 *
 *  Subclasses must invoke super if overriding this method.
 */
- (void)teardownGL;

@end
