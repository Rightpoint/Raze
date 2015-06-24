//
//  RZXAnimatable.h
//  RazeScene
//
//  Created by Rob Visentin on 6/24/15.
//

#import <Foundation/Foundation.h>

@class RZXInterpolationFunction;

@protocol RZXAnimatable <NSObject>

#warning Prefix with rzx_
+ (RZXInterpolationFunction *)interpolationFunctionForKey:(NSString *)key;

@end
