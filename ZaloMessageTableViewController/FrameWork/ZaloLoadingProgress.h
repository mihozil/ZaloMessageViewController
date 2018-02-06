//
//  ZaloLoadingProcess.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/7/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZaloStateMachine.h"

extern NSString *const ZaloLoadingStateInitial;
extern NSString *const ZaloLoadingStateLoading;
extern NSString *const ZaloLoadingStateLoaded;
extern NSString *const ZaloLoadingStateError;
extern NSString *const ZaloLoadingStateNoContent;
extern NSString *const ZaloLoadingStateRefreshing;

@interface ZaloLoadingStateMachine: ZaloStateMachine

@end

typedef void (^ZaloUpdateBlock)(id object);
typedef void (^LoadCompletion) (NSString *state, NSError *error, ZaloUpdateBlock update);

@interface ZaloLoadingProgress : NSObject


+ (instancetype)initializeLoadingProcessWithCompletionHandle:(LoadCompletion)completion;
- (void)loadCompletionWithError:(NSError *)error;
- (void)loadCompletionWithNoContent;
- (void)loadCompletionWithUpdate:(ZaloUpdateBlock)update;
- (void)done;

@end

@protocol ZaloLoadingState <NSObject>

@property (strong,nonatomic)NSError *loadingError;
@property (strong, nonatomic)NSString *loadingState;

@end

