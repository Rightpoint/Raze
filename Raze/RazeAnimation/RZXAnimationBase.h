//
//  RZXAnimationBase.h
//  RazeAnimation
//
//  Created by Rob Visentin on 7/13/15.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/CAAnimation.h>

#ifndef RZXAnimationBase_h
#define RZXAnimationBase_h

typedef NS_OPTIONS(NSUInteger, RZXAnimationOptions) {
    kRZXAnimationOptionRepeat            = 1 << 0,
    kRZXAnimationOptionAutoReverse       = 1 << 1,

    kRZXAnimationOptionCurveLinear       = 0 << 8, // default
    kRZXAnimationOptionCurveEaseIn       = 1 << 8,
    kRZXAnimationOptionCurveEaseOut      = 2 << 8,
    kRZXAnimationOptionCurveEaseInOut    = 3 << 8
};

typedef void (^RZXAnimationStartBlock)(CAAnimation *animation);
typedef void (^RZXAnimationCompletionBlock)(CAAnimation *animation, BOOL finished);

#endif
