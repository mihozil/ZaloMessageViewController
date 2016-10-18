//
//  MySlider.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/29/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "MySlider.h"

@implementation MySlider
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
//    CGRect bounds = self.bounds;
//    bounds = CGRectInset(bounds, -50, -50);
//    return CGRectContainsPoint(bounds, point);
//}

//- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value{
//    return CGRectInset([super thumbRectForBounds:bounds trackRect:rect value:value ], -20, -20);
//}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -20, -20);
    return CGRectContainsPoint(bounds, point);
}
@end
