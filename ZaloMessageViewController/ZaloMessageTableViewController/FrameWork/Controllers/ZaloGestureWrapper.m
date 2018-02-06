//
//  ZaloGestureWrapper.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/27/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloGestureWrapper.h"
#import <objc/message.h>
#import <libkern/OSAtomic.h>

@interface ZaloGestureWrapper() <UIGestureRecognizerDelegate>

@end

@implementation ZaloGestureWrapper

- (instancetype)initWithGesture:(UIGestureRecognizer*)gesture target:(id)target {
    self = [super init];
    if (self) {
        _actionSelector = NULL;
        _beginSelector = NULL;
        
        _target = target;
        _gesture = gesture;
        _gesture.delegate = self;
        [_gesture addTarget:self action:@selector(handleAction:)];
    }
    return self;
}

- (void)handleAction:(UIGestureRecognizer*)gestureRecognizer {
    
    if (_actionSelector == NULL) {
        return;
    }
    if (self.target && [self.target respondsToSelector:_actionSelector]) {
        typedef void (*ObjCMsgSendReturnVoidWithId)(id, SEL, id);
        ObjCMsgSendReturnVoidWithId methodImplementation = (ObjCMsgSendReturnVoidWithId)objc_msgSend;
        
        methodImplementation(self.target, _actionSelector, gestureRecognizer);
    }
}

#pragma mark gestureDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (!_beginSelector) {
        return false;
    }
    
    if (self.target && [self.target respondsToSelector:_beginSelector]) {
        typedef BOOL (*ObjCMsgSendReturnBoolWithId)(id, SEL, id);
        ObjCMsgSendReturnBoolWithId shouldBegin = (ObjCMsgSendReturnBoolWithId)objc_msgSend;
        return shouldBegin(self.target, _beginSelector, gestureRecognizer);
    }
    
    return false;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return true;
}

// updateGesture and maybe, target for Action

@end
