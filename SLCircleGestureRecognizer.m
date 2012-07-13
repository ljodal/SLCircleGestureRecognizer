//
//  SLCircleGestureRecognizer.m
//  Punchtimer
//
//  Created by Sigurd Ljødal on 08.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLCircleGestureRecognizer.h"

#include <math.h>

#pragma mark Defines
#define MIN_RADIUS 0.5
#define MAX_RADIUS 1.0
#define MAX_DEVIATION 0.5

#pragma mark - Simple C helpers

/*
 * This function calculates the difference between two points.
 */
static inline CGPoint CGPointDifference(CGPoint a, CGPoint b)
{
    return CGPointMake(a.x - b.x, a.y - b.y);
}

/*
 * This function takes a point, and calculates the tangent
 * compared to (0,0)
 */
static inline CGFloat CGPointTangent(CGPoint point)
{
    return sqrt(pow(fabs(point.x), 2) + pow(fabs(point.y), 2));
}

/*
 * This function calculates the radians from the top of the
 * circle to the current point on the circe.
 */
static inline CGFloat CGPointRadians(CGPoint point)
{
    return atan2f(point.y - CGPointTangent(point), point.x - .0) * 2;
}

/*
 * This function converts radians to percent / 100.
 */
static inline CGFloat RadiansToPercent(CGFloat radians)
{
    if (radians <= M_PI) {
        radians += M_PI;
    }
    
    if (radians < 0) {
        radians += 2 * M_PI;
    }
    
    return radians * (1 / (2 * M_PI));
}

#pragma mark - Private interface

@interface SLCircleGestureRecognizer ()

// Keep track of the progress
@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, readwrite) CGFloat lastProgress;
@property (nonatomic, readwrite) CGPoint midPoint;

@end

#pragma mark - Implementation
@implementation SLCircleGestureRecognizer

#pragma mark Properties
@synthesize progress = _progress;
@synthesize lastProgress = _lastProgress;
@synthesize midPoint = _midPoint;

#pragma mark - Public methods
- (void)reset
{
    [super reset];
    self.progress = .0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    NSLog(@"Gesture began");
    
    // This gesture is based on a singe touch, so if
    // multiple touches are detected, we know that this
    // gesture is not possible.
    if ([touches count] != 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    // Set the midpoint, as we're going to need this
    self.midPoint = CGPointMake(self.view.frame.size.width / 2,
                                self.view.frame.size.height / 2);
    
    // Get the touch point relative to the center point.
    CGPoint point = CGPointDifference([[touches anyObject] locationInView:self.view],
                                      self.midPoint);
    
    // Calculate the radius (tangent) of the touch point.
    CGFloat radius = CGPointTangent(point);
    
    // Gesture must begin between min and max radius.
    if (fabs(radius) > self.midPoint.y * MAX_RADIUS ||
        fabs(radius) < self.midPoint.y * MIN_RADIUS) {
        NSLog(@"Failed because of radius: %f Point: (%f,%f)", radius, point.x, point.y);
        self.state = UIGestureRecognizerStateFailed;
        return;
    }

    // We now know that the gesture is possible, so we must
    // store the information we need to calculate the progress
    // relative to this touch.
    self.progress = RadiansToPercent(CGPointRadians(point));
    
    self.lastProgress = self.progress;
    
    // We also need to set the state to possible.
    self.state = UIGestureRecognizerStatePossible;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    // If the gesture has already failed, no need to
    // calculate anything here
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    CGPoint point = CGPointDifference([[touches anyObject] locationInView:self.view],
                                      self.midPoint);
    
    CGFloat radius = CGPointTangent(point);
    
    // We allow the touch to deviate by MAX_DEVIATION before the
    // gesture fails.
    if (fabs(radius) > self.midPoint.y * MAX_RADIUS * (1.0 + MAX_DEVIATION) ||
        fabs(radius) < self.midPoint.y * MIN_RADIUS * MAX_DEVIATION) {
        
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    // The gesture is still valid, so we must update the progress
    CGFloat progress = RadiansToPercent(CGPointRadians(point));
    
    if (progress - self.lastProgress < -.5) {
        self.lastProgress = 0;
    } else if (progress - self.lastProgress > .5) {
        self.lastProgress = 1;
    }
    
    // Update progress
    self.progress += progress - self.lastProgress;
    
    if (self.progress < 0) {
        self.progress = 0;
    }
    
    self.lastProgress = progress;
    
    // Update the gesture state
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateBegan;
    } else {
        self.state = UIGestureRecognizerStateChanged;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Gesture ended");
    
    [super touchesEnded:touches withEvent:event];
    
    // If the gesture has already failed, no need to
    // calculate anything here
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    CGPoint point = CGPointDifference([[touches anyObject] locationInView:self.view],
                                      self.midPoint);
    
    CGFloat radius = CGPointTangent(point);
    
    // We allow the touch to deviate by MAX_DEVIATION before the
    // gesture fails.
    if (fabs(radius) > self.midPoint.y * MAX_RADIUS * (1.0 + MAX_DEVIATION) ||
        fabs(radius) < self.midPoint.y * MIN_RADIUS * MAX_DEVIATION) {
        
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    // The gesture is still valid, so we must update the progress
    CGFloat progress = RadiansToPercent(CGPointRadians(point));
    
    if (progress - self.lastProgress < -.5) {
        self.lastProgress = 0;
    } else if (progress - self.lastProgress > .5) {
        self.lastProgress = 1;
    }
    
    // Update progress
    self.progress += progress - self.lastProgress;
    
    if (self.progress < 0) {
        self.progress = 0;
    }
    
    self.lastProgress = progress;
    
    // Update the gesture state
    self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Gesture cancelled");
    
    [super touchesCancelled:touches withEvent:event];
    
    // Since we only used one touch, the gesture is now cancelled.
    self.state = UIGestureRecognizerStateCancelled;
}

#pragma mark - Private methods



@end
