//
//  ZaloStateMachine.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/27/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZaloGestureWrapper.h"
@class ZaloStateMachine;

@protocol ZaloStateMachineDelegate <NSObject>

@optional
- (NSString*)missingTransitionFromState:(NSString*)fromState toState:(NSString*)toState;
- (void)stateWillChange;
- (void)stateDidChange;

@end

@interface ZaloStateMachine : NSObject

@property (weak, nonatomic) id<ZaloStateMachineDelegate>delegate;
@property (strong, nonatomic) NSString *currentState;
@property (strong, nonatomic) NSDictionary *tranmissions;

@end
