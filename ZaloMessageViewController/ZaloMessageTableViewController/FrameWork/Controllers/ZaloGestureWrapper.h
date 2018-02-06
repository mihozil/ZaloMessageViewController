//
//  ZaloGestureWrapper.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/27/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ZaloGestureWrapper : NSObject

@property (nonatomic) SEL actionSelector;
@property (nonatomic) SEL beginSelector;
@property (weak, nonatomic) id<UIGestureRecognizerDelegate> target; // no need gestureRecognizerDelegate
@property (strong, nonatomic) UIGestureRecognizer *gesture;

- (instancetype)initWithGesture:(UIGestureRecognizer*)gesture target:(id)target;

@end
