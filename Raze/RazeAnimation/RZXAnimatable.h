//
//  RZXAnimatable.h
//  RazeAnimation
//
//  Created by Rob Visentin on 6/24/15.
//

#import <Foundation/Foundation.h>

@class RZXInterpolator;

@protocol RZXAnimatable <NSObject>

+ (RZXInterpolator *)rzx_interpolatorForKey:(NSString *)key;

@end

@interface NSObject (RZXAnimatable) <RZXAnimatable>

+ (void)rzx_addKVCComplianceForGLKTypes;

@end
