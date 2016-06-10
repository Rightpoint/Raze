//
//  RazeGeometryTests.m
//  RazeTests
//
//  Created by Jason Clark on 6/6/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RZXGeometry.h"

@interface RazeGeometryTests : XCTestCase

@end

@implementation RazeGeometryTests

#pragma mark - Spheres

- (void)testRZXSphereContainsPoint {

    RZXSphere sphere;
    sphere.center = GLKVector3Make(0, 0, 0);
    sphere.radius = 10.0;

    GLKVector3 point = GLKVector3Make(0, 0, 0);

    //Base case: Sphere contains own center
    XCTAssert(RZXSphereContainsPoint(sphere, point));

    //Base failure
    sphere.radius = 10.0;
    point = GLKVector3Make(sphere.radius + 1, 0, 0);
    XCTAssert(RZXSphereContainsPoint(sphere, point) == false);

    //point on sphere surface
    point = GLKVector3Make(sphere.radius, 0, 0);
    XCTAssert(RZXSphereContainsPoint(sphere, point));

    //Negative radius
    point = GLKVector3Make(0, 0, 0);
    sphere.radius = -10.0;
    XCTAssert(RZXSphereContainsPoint(sphere, point) == false);

    //point on sphere surface, non-zero center
    point = GLKVector3Make(0, 0, 0);
    sphere.center = GLKVector3Make(10, 0, 0);
    sphere.radius = 10;
    XCTAssert(RZXSphereContainsPoint(sphere, point));

    //zero-size sphere
    sphere.center = GLKVector3Make(0, 0, 0);
    sphere.radius = 0.0;
    point = GLKVector3Make(0, 0, 0);
    XCTAssert(RZXSphereContainsPoint(sphere, point));

    //test overflow
    sphere.center = GLKVector3Make(FLT_MAX, FLT_MAX, FLT_MAX);
	sphere.radius = INFINITY;
    point = GLKVector3Make(FLT_MAX, FLT_MAX, FLT_MAX);
    XCTAssert(RZXSphereContainsPoint(sphere, point));

}

- (void)testRZXSphereIntersectsSphere {

    RZXSphere sphere1, sphere2;
    sphere1.center = GLKVector3Make(0, 0, 0);
    sphere1.radius = 10.0f;

    sphere2 = sphere1;

    //identity
    XCTAssert(RZXSphereIntersectsSphere(sphere1, sphere2) == true);

    //same centers
    sphere2.radius = sphere1.radius / 2.0f;
    XCTAssert(RZXSphereIntersectsSphere(sphere1, sphere2) == true);

    //touching surfaces
    sphere1.radius = sphere2.radius = 10.0f;
    sphere1.center.x = -10.0f;
    sphere2.center.x = 10.0f;
    XCTAssert(RZXSphereIntersectsSphere(sphere1, sphere2) == true);

    //barely not touching
    sphere2.center.x += (1.0/100000.0);
    XCTAssert(RZXSphereIntersectsSphere(sphere1, sphere2) == false);

    //not touching
    sphere2.center.x += 1;
    XCTAssert(RZXSphereIntersectsSphere(sphere1, sphere2) == false);

}

#pragma mark - Boxes

-(void)testRZXBoxGetSize {
    RZXBox box;
    box.center = GLKVector3Make(0, 0, 0);
    box.radius = GLKVector3Make(10, 10, 10);
    box.axes[0] = GLKVector3Make(0, 0, 0);
    box.axes[1] = GLKVector3Make(0, 0, 0);
    box.axes[2] = GLKVector3Make(0, 0, 0);

    //base case
    GLKVector3 expectedResult = GLKVector3Make(20, 20, 20);
    XCTAssert(GLKVector3AllEqualToVector3(RZXBoxGetSize(box), expectedResult));

    //move center
    box.center = GLKVector3Make(10, 10, 10);
    XCTAssert(GLKVector3AllEqualToVector3(RZXBoxGetSize(box), expectedResult));

    //off axis
    box.axes[0] = GLKVector3Make(0, 1, 0);
    XCTAssert(GLKVector3AllEqualToVector3(RZXBoxGetSize(box), expectedResult));

    //negative dimenions
    box.radius = GLKVector3Make(-10, -10, -10);
    expectedResult = GLKVector3Make(-20, -20, -20);
    XCTAssert(GLKVector3AllEqualToVector3(RZXBoxGetSize(box), expectedResult));

    //non-cube
    box.radius = GLKVector3Make(1, 2, 3);
    expectedResult = GLKVector3Make(2, 4, 6);
    XCTAssert(GLKVector3AllEqualToVector3(RZXBoxGetSize(box), expectedResult));

}

-(void)testRZXBoxGetRotation {
    RZXBox box;
    box.center = GLKVector3Make(0, 0, 0);
    box.radius = GLKVector3Make(1, 1, 1);
    box.axes[0] = GLKVector3Make(1, 0, 0);
    box.axes[1] = GLKVector3Make(0, 1, 0);
    box.axes[2] = GLKVector3Make(0, 0, 1);

    //Identity
    NSString *result = NSStringFromGLKQuaternion(RZXBoxGetRotation(box));
    NSString *expectedResult = NSStringFromGLKQuaternion(GLKQuaternionIdentity);
    XCTAssert([result isEqualToString: expectedResult], "expected '%@' to equal '%@'", result, expectedResult);
}

-(void)testRZXBoxGetNearestPoint {

}

-(void)testRZXBoxContainsPoint {
    RZXBox box;
    box.center = GLKVector3Make(0, 0, 0);
    box.radius = GLKVector3Make(1, 1, 1);
    box.axes[0] = GLKVector3Make(1, 0, 0);
    box.axes[1] = GLKVector3Make(0, 1, 0);
    box.axes[2] = GLKVector3Make(0, 0, 1);

    //base case
    GLKVector3 point = GLKVector3Make(0, 0, 0);
    XCTAssert(RZXBoxContainsPoint(box, point));

    //point on box surface
    point = GLKVector3Make(0, 0, 1);
    XCTAssert(RZXBoxContainsPoint(box, point));

    //point just beyond box surface
    point = GLKVector3Make(0, 0, 1.1);
    XCTAssert(RZXBoxContainsPoint(box, point) == false);

    //no radius
    box.radius = GLKVector3Make(0, 0, 0);
    point = GLKVector3Make(0, 0, 0);
    XCTAssert(RZXBoxContainsPoint(box, point));

    //point on corner, translated box
    box.center = GLKVector3Make(1, 1, 1);
    box.radius = GLKVector3Make(1, 1, 1);
    point = GLKVector3Make(0, 0, 0);
    XCTAssert(RZXBoxContainsPoint(box, point));

}

-(void)testRZXBoxTranslate {
    RZXBox box;
    box.center = GLKVector3Make(0, 0, 0);

    GLKVector3 translation = GLKVector3Make(0, 1, 0);
    GLKVector3 expectedLocation = GLKVector3Make(0, 1, 0);
    RZXBoxTranslate(&box, translation);
    XCTAssert(GLKVector3AllEqualToVector3(box.center, expectedLocation));

    translation = GLKVector3Make(1, 0, 1);
    expectedLocation = GLKVector3Make(1, 1, 1);
    RZXBoxTranslate(&box, translation);
    XCTAssert(GLKVector3AllEqualToVector3(box.center, expectedLocation));

    translation = GLKVector3Make(-1, -1, -1);
    expectedLocation = GLKVector3Make(0, 0, 0);
    RZXBoxTranslate(&box, translation);
    XCTAssert(GLKVector3AllEqualToVector3(box.center, expectedLocation));
}

-(void)testRZXBoxScale {
    RZXBox box;
    box.radius = GLKVector3Make(1, 1, 1);
    GLKVector3 scale = GLKVector3Make(1, 1, 1);
    GLKVector3 expectedRadius = GLKVector3Make(1, 1, 1);

    //identity
    RZXBoxScale(&box, scale);
    XCTAssert(GLKVector3AllEqualToVector3(box.radius, expectedRadius));

    scale = GLKVector3Make(1, 2, 3);
    expectedRadius = GLKVector3Make(1, 2, 3);
    RZXBoxScale(&box, scale);
    XCTAssert(GLKVector3AllEqualToVector3(box.radius, expectedRadius));

    scale = GLKVector3Make(-1, -2, -3);
    expectedRadius = GLKVector3Make(-1, -4, -9);
    RZXBoxScale(&box, scale);
    XCTAssert(GLKVector3AllEqualToVector3(box.radius, expectedRadius));

    scale = GLKVector3Make(0, 0, 0);
    expectedRadius = GLKVector3Make(0, 0, 0);
    RZXBoxScale(&box, scale);
    XCTAssert(GLKVector3AllEqualToVector3(box.radius, expectedRadius));
}

-(void)testRZXBoxRotate {

}

- (void)testRZXBoxIntersection {
    
}


@end
