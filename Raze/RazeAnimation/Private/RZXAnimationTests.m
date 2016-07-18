//
//  RZXAnimationTests.m
//  Raze
//
//  Created by Rob Visentin on 7/17/16.
//
//

#import <XCTest/XCTest.h>
#import <objc/message.h>

@import RazeAnimation;

@interface RZXAnimationTests : XCTestCase

@end

@implementation RZXAnimationTests

- (void)testTimingFunctions {
    void (^testFunction)(CAMediaTimingFunction *) = ^(CAMediaTimingFunction *function) {
        for ( float t = 0.0f; t <= 1.0f; t += 1e-3f ) {
            float truth = ((float(*)(id, SEL, float))objc_msgSend)(function, sel_getUid("_solveForInput:"), t);
            float test = [function rzx_solveForNormalizedTime:t];

            XCTAssertEqualWithAccuracy(test, truth, 1e-4);

        }
    };

    testFunction([CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]);
    testFunction([CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
    testFunction([CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]);
    testFunction([CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]);
}

@end
