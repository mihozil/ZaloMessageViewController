//
//  ZaloStateMachine.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/27/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloStateMachine.h"
#import <objc/message.h>
#import <libkern/OSAtomic.h>

@implementation ZaloStateMachine

- (void)setCurrentState:(NSString *)currentState {
    [self attemptToSetCurrentState:currentState];
}

- (BOOL)attemptToSetCurrentState:(NSString*)newState {
    NSString *fromState = _currentState;
    NSString *appliedState = [self validateTransitionFromState:fromState toState:newState];
    if (!appliedState)
        return false;
    
    // stateWillChange
    if (self.delegate && [self.delegate respondsToSelector:@selector(stateWillChange)]) {
        typedef void (*ObjCMsgSendReturnVoid)(id, SEL);
        ObjCMsgSendReturnVoid implementation = (ObjCMsgSendReturnVoid)objc_msgSend;
        implementation(self.delegate, @selector(stateWillChange));
    }
    
    
    _currentState = appliedState;
    [self updateFromState:fromState toState:_currentState];
    
    return ([newState isEqual:appliedState]);
}

- (NSString*)triggerMissingTransitionFromState:(NSString*)fromState toState:(NSString*)toState {
    id<ZaloStateMachineDelegate>delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(missingTransitionFromState:toState:)]) {
        // only if app is reseting content, otherwise, will return nil
        toState = [delegate missingTransitionFromState:fromState toState:toState];
        return toState;
    }
    return nil;
}

- (NSString*)validateTransitionFromState:(NSString*)fromState toState:(NSString*)toState {
    
    if (toState == nil) {
        NSLog(@"toState can not be nil");
        return nil;
    }
    
    if (fromState) {
        id validToStates = _tranmissions[fromState];
        BOOL validTransition = true;
        if ([validToStates isKindOfClass:[NSArray class]]) {
            if (![validToStates containsObject:toState]) {
                validTransition = false;
            }
        } else
            if (![validToStates isEqual:toState]) {
                validTransition = false;
            }
        if (!validTransition) {
            if ([fromState isEqualToString:toState]) {
                NSLog(@"transform fromState: %@ toState: %@ is not allowed",fromState,toState);
                return nil;
            }
            toState = [self triggerMissingTransitionFromState:fromState toState:toState];
            if (!toState)
                return nil;
        }
    }
    
    // shouldEnter: raise an exception by should enter
    SEL shouldEnterStateAction = NSSelectorFromString([@"shouldEnter" stringByAppendingString:toState]);
    if (self.delegate && [self.delegate respondsToSelector:shouldEnterStateAction]) {
        typedef BOOL (*ObjCMsgSendReturnBool)(id, SEL);
        ObjCMsgSendReturnBool shouldEnter = (ObjCMsgSendReturnBool)objc_msgSend;
        if (!shouldEnter(self.delegate, shouldEnterStateAction)) {
            NSLog(@"should enter %@ return false",toState);
            return nil;
        }
    }
    
    return toState;
}

- (void)updateFromState:(NSString*)fromState toState:(NSString*)toState {
    
    // didExitFromState
    if (fromState) {
        SEL exitStateAction = NSSelectorFromString([@"didExit" stringByAppendingString:fromState]);
        
        if (self.delegate && [self.delegate respondsToSelector:exitStateAction]) {
            
            typedef void (*ObjCMsgSendReturnVoid)(id, SEL);
            ObjCMsgSendReturnVoid methodImplementation = (ObjCMsgSendReturnVoid)objc_msgSend;
            
            methodImplementation(self.delegate, exitStateAction);
        }
    }
    
    // didEnterToState
    SEL enterStateAction = NSSelectorFromString([@"didEnter" stringByAppendingString:toState]);
    if (self.delegate && [self.delegate respondsToSelector:enterStateAction]) {
        typedef void (*ObjCMsgSendReturnVoid)(id, SEL);
        ObjCMsgSendReturnVoid methodImplementation = (ObjCMsgSendReturnVoid)objc_msgSend;
        
        methodImplementation(self.delegate, enterStateAction);
    }
}

@end
