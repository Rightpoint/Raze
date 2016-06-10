//
//  RZXMathTests.m
//  RazeTests
//
//  Created by Jason Clark on 6/9/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RZXMath.h"

#define ACCURACY 0.001

@interface RZXMathTests : XCTestCase

@end

@implementation RZXMathTests

- (void)testRZXSafeASin {
	XCTAssertEqualWithAccuracy(RZXSafeASin(0.0), 0, ACCURACY);
	XCTAssertEqualWithAccuracy(RZXSafeASin(0.5), asinf(0.5), ACCURACY);
	XCTAssertEqualWithAccuracy(RZXSafeASin(-0.5), -asinf(0.5), ACCURACY);
	XCTAssertEqualWithAccuracy(RZXSafeASin(1), M_PI_2, ACCURACY);
	XCTAssertEqualWithAccuracy(RZXSafeASin(-1), -M_PI_2, ACCURACY);
	XCTAssertEqualWithAccuracy(RZXSafeASin(FLT_MAX), M_PI_2, ACCURACY);
	XCTAssertEqualWithAccuracy(RZXSafeASin(-FLT_MAX), -M_PI_2, ACCURACY);
}

- (void)testRZXQuaternionGetEulerAngles {

	float x, y, z;
	//x base case
	GLKQuaternion xQuaternion = GLKQuaternionMakeWithAngleAndAxis(M_PI_2, 1, 0, 0);
	RZXQuaternionGetEulerAngles(xQuaternion, &x, &y, &z);
	XCTAssertEqualWithAccuracy(x, M_PI_2, ACCURACY);
	XCTAssertEqualWithAccuracy(y, 0, ACCURACY);
	XCTAssertEqualWithAccuracy(z, 0, ACCURACY);

	//y base case
	GLKQuaternion yQuaternion = GLKQuaternionMakeWithAngleAndAxis(M_PI_2, 0, 1, 0);
	RZXQuaternionGetEulerAngles(yQuaternion, &x, &y, &z);
	XCTAssertEqualWithAccuracy(x, 0, ACCURACY);
	XCTAssertEqualWithAccuracy(y, M_PI_2, ACCURACY);
	XCTAssertEqualWithAccuracy(z, 0, ACCURACY);

	//z base case
	GLKQuaternion zQuaternion = GLKQuaternionMakeWithAngleAndAxis(M_PI_2, 0, 0, 1);
	RZXQuaternionGetEulerAngles(zQuaternion, &x, &y, &z);
	XCTAssertEqualWithAccuracy(x, 0, ACCURACY);
	XCTAssertEqualWithAccuracy(y, 0, ACCURACY);
	XCTAssertEqualWithAccuracy(z, M_PI_2, ACCURACY);

}

- (void)testRZXQuaternionMakeEuler {

	float vectorGranularity = 0.1;
	float angleGranularity = M_PI / 8.0;

	for (float x = -1; x<=1; x+= vectorGranularity) {
		for (float y = -1; y<=1; y+= vectorGranularity) {
			for (float z = -1; z<=1; z+= vectorGranularity) {
				for (float rad = -M_2_PI; rad <= M_2_PI; rad = rad+ angleGranularity) {
					GLKQuaternion original = GLKQuaternionNormalize(GLKQuaternionMakeWithAngleAndAxis(rad, x, y, z));
					float a, b, c;
					RZXQuaternionGetEulerAngles(original, &a, &b, &c);
					GLKQuaternion converted = GLKQuaternionNormalize(RZXQuaternionMakeEuler(a, b, c));

					XCTAssertEqualWithAccuracy(original.x, converted.x, ACCURACY);
					XCTAssertEqualWithAccuracy(original.y, converted.y, ACCURACY);
					XCTAssertEqualWithAccuracy(original.z, converted.z, ACCURACY);
					XCTAssertEqualWithAccuracy(original.w, converted.w, ACCURACY);
				}
			}
		}
	}
	
}

@end
