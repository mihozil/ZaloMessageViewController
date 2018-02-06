//
//  ZaloLoadingProcess.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/7/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloLoadingProgress.h"

@interface ZaloLoadingProgress()

@property (strong, nonatomic) LoadCompletion completionBlock;

@end

NSString *const ZaloLoadingStateInitial = @"InitialState";
NSString *const ZaloLoadingStateLoading = @"LoadingState";
NSString *const ZaloLoadingStateLoaded = @"LoadedState";
NSString *const ZaloLoadingStateError = @"ErrorState";
NSString *const ZaloLoadingStateNoContent = @"NoContentState";
NSString *const ZaloLoadingStateRefreshing = @"RefreshingState";

@implementation ZaloLoadingProgress

+ (instancetype)initializeLoadingProcessWithCompletionHandle:(LoadCompletion)completion {
    ZaloLoadingProgress *loadingProcess = [[ZaloLoadingProgress alloc]init];
    if (loadingProcess) {
        loadingProcess.completionBlock = completion;
    }
    return loadingProcess;
}

// temporary like this
// take care:
    //1. put completionBlockToMainThread
    //2. resetCompletionBlock

- (void)loadCompletionWithError:(NSError *)error {
    if (self.completionBlock) {
        self.completionBlock(ZaloLoadingStateError, error, nil);
    }
}

- (void)loadCompletionWithNoContent {
    if (self.completionBlock) {
        self.completionBlock(ZaloLoadingStateNoContent, nil, nil);
    }
}

- (void)loadCompletionWithUpdate:(ZaloUpdateBlock)update {
    if (self.completionBlock) {
        self.completionBlock(ZaloLoadingStateLoaded, nil, update);
    }
}

- (void)done {
    if (self.completionBlock) {
        self.completionBlock(ZaloLoadingStateLoaded, nil, nil);
    }
}

@end

@implementation ZaloLoadingStateMachine

- (id)init {
    self = [super init];
    if (self) {
        self.tranmissions = @{
                              ZaloLoadingStateInitial : ZaloLoadingStateLoading,
                              ZaloLoadingStateLoading : @[ZaloLoadingStateLoaded, ZaloLoadingStateError, ZaloLoadingStateNoContent],
                              ZaloLoadingStateLoaded : ZaloLoadingStateRefreshing,
                              ZaloLoadingStateNoContent : ZaloLoadingStateRefreshing,
                              ZaloLoadingStateError : ZaloLoadingStateRefreshing,
                              ZaloLoadingStateRefreshing : @[ZaloLoadingStateLoaded, ZaloLoadingStateNoContent, ZaloLoadingStateError]
                              };
    }
    return self;
}


@end
