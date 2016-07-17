//
//  RZXPolyCurve.h
//  RazeAnimation
//
//  Created by Rob Visentin on 7/17/16.
//
//  Adapated from http://opensource.apple.com/source/WebCore/WebCore-7537.70/platform/graphics/UnitBezier.h
//  License:

/*
 * Copyright (C) 2008 Apple Inc. All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef _RZXPolyCurve_h
#define _RZXPolyCurve_h

#include <CoreFoundation/CoreFoundation.h>

typedef struct _RZXPolyCurve {
    double ax, bx, cx;
    double ay, by, cy;
} RZXPolyCurve;

typedef struct _RZXControlPoint {
    double x, y;
} RZXControlPoint;

CF_INLINE RZXPolyCurve RZXPolyCurveMake(RZXControlPoint c1, RZXControlPoint c2)
{
    double cx = 3.0 * c1.x;
    double bx = 3.0 * (c2.x - c1.x) - cx;
    double ax = 1.0 - cx -bx;

    double cy = 3.0 * c1.y;
    double by = 3.0 * (c2.y - c1.y) - cy;
    double ay = 1.0 - cy - by;

    return (RZXPolyCurve) {
        .ax = ax, .bx = bx, .cx = cx,
        .ay = ay, .by = by, .cy = cy
    };
}

CF_INLINE double RZXPolyCurveSampleX(RZXPolyCurve curve, double t)
{
    return ((curve.ax * t + curve.bx) * t + curve.cx) * t;
}

CF_INLINE double RZXPolyCurveSampleY(RZXPolyCurve curve, double t)
{
    return ((curve.ay * t + curve.by) * t + curve.cy) * t;
}

CF_INLINE double RZXPolyCurveSampleDerivativeX(RZXPolyCurve curve, double t)
{
    return (3.0 * curve.ax * t + 2.0 * curve.bx) * t + curve.cx;
}

CF_INLINE double RZXPolyCurveSolveX(RZXPolyCurve curve, double x)
{
    static double epsilon = 1e-6;

    double t0;
    double t1;
    double t2;
    double x2;
    double d2;

    // First try a few iterations of Newton's method -- normally very fast.
    for ( int i = 0, t2 = x; i < 8; i++ ) {
        x2 = RZXPolyCurveSampleX(curve, t2) - x;
        if ( fabs(x2) < epsilon ) {
            return t2;
        }

        d2 = RZXPolyCurveSampleDerivativeX(curve, t2);
        if ( fabs(d2) < epsilon ) {
            break;
        }

        t2 = t2 - x2 / d2;
    }

    // Fall back to the bisection method for reliability.
    t0 = 0.0;
    t1 = 1.0;
    t2 = x;

    if ( t2 < t0 ) {
        return t0;
    }

    if (t2 > t1) {
        return t1;
    }

    while ( t0 < t1 ) {
        x2 = RZXPolyCurveSampleX(curve, t2);
        if ( fabs(x2 - x) < epsilon ) {
            return t2;
        }

        if ( x > x2 ) {
            t0 = t2;
        }
        else {
            t1 = t2;
        }

        t2 = (t1 - t0) * 0.5 + t0;
    }

    // Failure.
    return t2;
}

CF_INLINE double RZXPolyCurveSolve(RZXPolyCurve curve, double x)
{
    return RZXPolyCurveSampleY(curve, RZXPolyCurveSolveX(curve, x));
}

#endif
