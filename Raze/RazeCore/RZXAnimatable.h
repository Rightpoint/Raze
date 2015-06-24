//
//  RZXAnimatable.h
//  RazeScene
//
//  Created by Rob Visentin on 6/24/15.
//

#import <Foundation/Foundation.h>

@class RZXInterpolationFunction;

@protocol RZXAnimatable <NSObject>

+ (RZXInterpolationFunction *)rzx_interpolationFunctionForKey:(NSString *)key;

@end
