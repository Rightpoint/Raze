//
//  RZXMath.h
//
//  Created by Rob Visentin on 2/10/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#ifndef _RZXMath_h
#define _RZXMath_h

#import <GLKit/GLKMath.h>

// Handles the singularity at +/-M_PI_2 pitch
GLK_INLINE float RZXSafeASin(float x)
{
    float asin;

    if ( isnan(x) )          asin = 0.0f;
    else if ( x >= 1.0f )    asin = M_PI_2;
    else if ( x <= -1.0f )   asin = -M_PI_2;
    else                     asin = asinf(x);

    return asin;
}

GLK_INLINE void RZXQuaternionGetEulerAngles(GLKQuaternion q, float *x, float *y, float *z)
{
    if( x!= NULL ) {
        *x = RZXSafeASin(2.0f * (q.w * q.x - q.y * q.z));
    }

    if( y != NULL ) {
        *y = atan2f(2.0f * (q.w * q.y + q.z * q.x), 1 - 2.0f * (q.x * q.x + q.y * q.y));
    }
    if( z != NULL ) {
        *z = atan2f(2.0f * (q.w * q.z + q.x * q.y), 1 - 2.0f * (q.z * q.z + q.x * q.x));
    }
}

GLK_INLINE GLKQuaternion RZXQuaternionMakeEuler(float x, float y, float z)
{
    GLKQuaternion q;

    float halfPitch = x * 0.5f;
    float sinHalfPitch = sinf(halfPitch);
    float cosHalfPitch = cosf(halfPitch);

    float halfYaw = y * 0.5f;
    float sinHalfYaw = sinf(halfYaw);
    float cosHalfYaw = cosf(halfYaw);

    float halfRoll = z * 0.5f;
    float sinHalfRoll = sinf(halfRoll);
    float cosHalfRoll = cosf(halfRoll);

    q.x = cosHalfYaw * sinHalfPitch * cosHalfRoll + sinHalfYaw * cosHalfPitch * sinHalfRoll;
    q.y = sinHalfYaw * cosHalfPitch * cosHalfRoll - cosHalfYaw * sinHalfPitch * sinHalfRoll;
    q.z = cosHalfYaw * cosHalfPitch * sinHalfRoll - sinHalfYaw * sinHalfPitch * cosHalfRoll;
    q.w = cosHalfYaw * cosHalfPitch * cosHalfRoll + sinHalfYaw * sinHalfPitch * sinHalfRoll;
    
    return q;
}

#endif
