//
//  ZaloDataAccessManager.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/8/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZaloMessegeModel.h"
#import "ZaloSuggestionCollectionViewModel.h"
#import "ZaloPagedModel.h"
#import "ZaloFriendRequestModel.h"

@interface ZaloDataAccessManager : NSObject

+ (instancetype)sharedInstance;
- (void)fetchChatsWithCompletionHandle:(void(^)(NSArray<id<ZaloMessageModelProtocol>>*chats, NSError*error))completion;
- (void)fetchSuggestionWithCompletionHandle:(void (^) (NSArray<id<ZaloSuggestionCollectionViewModelProtocol>>*suggestions, NSError *error))completion;
- (void)fetchChatDetailWithCompletionHandle:(void(^)(NSArray<id<ZaloPagedModelProtocol>>*details, NSError*error))completion;
- (void)fetchFriendRequestsWithCompletionHandle:(void(^)(NSArray<id<ZaloFriendRequestModelProtocol>>*requests, NSError*error))completion;

@end
