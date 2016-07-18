//
//  CAMediaTimingFunction+RZXExtensions.m
//  RazeAnimation
//
//  Created by Rob Visentin on 7/17/16.
//

#import <objc/runtime.h>
#import <RazeAnimation/CAMediaTimingFunction+RZXExtensions.h>
#import <RazeAnimation/RZXPolyCurve.h>

static void* const kRZXPolyCurveKey = (void *)&kRZXPolyCurveKey;

@implementation CAMediaTimingFunction (RZXExtensions)

- (float)rzx_solveForNormalizedTime:(float)t
{
    NSValue *curveValue = objc_getAssociatedObject(self, kRZXPolyCurveKey);

    if ( curveValue == nil ) {
        float cps[4];
        memset(cps, 0, sizeof(cps));

        [self getControlPointAtIndex:1 values:cps];
        [self getControlPointAtIndex:2 values:cps + 2];

        RZXControlPoint cp1 = (RZXControlPoint){ .x = cps[0], .y = cps[1] };
        RZXControlPoint cp2 = (RZXControlPoint){ .x = cps[2], .y = cps[3] };

        RZXPolyCurve curve = RZXPolyCurveMake(cp1, cp2);

        curveValue = [NSValue valueWithBytes:&curve objCType:@encode(RZXPolyCurve)];
        objc_setAssociatedObject(self, kRZXPolyCurveKey, curveValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    RZXPolyCurve curve;
    [curveValue getValue:&curve];

    return RZXPolyCurveSolve(curve, t);
}

- (CAMediaTimingFunction *)rzx_inverseFunction
{
    float cps[4];
    memset(cps, 0, sizeof(cps));

    [self getControlPointAtIndex:1 values:cps];
    [self getControlPointAtIndex:2 values:cps + 2];

    // flip around the line y = 1 - x
    return [CAMediaTimingFunction functionWithControlPoints:1.0f - cps[2] :cps[1] :1.0f - cps[0] :cps[3]];
}

@end
