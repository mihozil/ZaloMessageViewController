//
//  ZaloDataAccessManager.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/8/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloDataAccessManager.h"

@interface ZaloDataAccessManager ()

@property (strong, nonatomic) NSArray<id<ZaloMessageModelProtocol>> *chatArray;
@property (strong, nonatomic) NSArray<id<ZaloSuggestionCollectionViewModelProtocol>> *suggestionArray;
@property (strong, nonatomic) NSArray<id<ZaloFriendRequestModelProtocol>> *friendRequestArray;

@end

@implementation ZaloDataAccessManager

+ (instancetype)sharedInstance {
    static ZaloDataAccessManager *dataAccessManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!dataAccessManager)
            dataAccessManager = [[ZaloDataAccessManager alloc]init];
    });
    return dataAccessManager;
}

- (void)fetchJsonResourceWithName:(NSString*)name completionHandle:(void (^) (NSDictionary*json, NSError*error))completion {
    NSURL *resourceURL = [[NSBundle mainBundle]URLForResource:name withExtension:@"json"];
    if (!resourceURL) {
        NSAssert(NO, @"invalid jsonResource");
    }
    
    NSError*error;
    NSData *data = [NSData dataWithContentsOfURL:resourceURL options:NSDataReadingMappedIfSafe error:&error];
    if (!data) {
        NSLog(@"No Data");
        return;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!json) {
        if (completion)
            completion(nil,error);
    }
    
    NSNumber *delayResultNumber = json[@"delayResult"];
    if (delayResultNumber && [delayResultNumber isKindOfClass:[NSNumber class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([delayResultNumber floatValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion)
                completion(json,error);
        });
    } else {
        if (completion)
            completion(json,error);
    }
}

#pragma mark fetch

- (void)fetchChatsWithCompletionHandle:(void(^)(NSArray<id<ZaloMessageModelProtocol>>*chats, NSError*error))completion {
    
    if (completion) {
        
        if (self.chatArray) {
            completion(_chatArray,nil);
            return;
        }
        
        __weak ZaloDataAccessManager *weakSelf = self;
        [self fetchJsonResourceWithName:@"chat" completionHandle:^(NSDictionary*json, NSError*error) {
            NSArray *chats = json[@"result"];
            for (id object in chats) {
                if (![object isKindOfClass:[NSDictionary class]]) {
                    NSAssert(NO, @"objectType in result array should be dictionary");
                }
            }
            NSArray<id<ZaloMessageModelProtocol>> *models = [self createModelsFromChats:chats];
            weakSelf.chatArray = models;
            completion(models,error);
        }];
    }
}

- (void)fetchSuggestionWithCompletionHandle:(void (^) (NSArray<id<ZaloSuggestionCollectionViewModelProtocol>>*suggestions, NSError *error))completion {
    if (completion) {
        if (self.suggestionArray) {
            completion(_suggestionArray,nil);
            return;
        }
        
        __weak ZaloDataAccessManager *weakSelf = self;
        [self fetchJsonResourceWithName:@"suggestion" completionHandle:^(NSDictionary*json, NSError*error){
            NSArray *suggestions = json[@"result"];
            NSArray<id<ZaloSuggestionCollectionViewModelProtocol>>* suggestionModels = [self createSuggestionsModelsFromSuggestion:suggestions];
            weakSelf.suggestionArray = suggestionModels;
            if (completion)
                completion(suggestionModels,error);
        }];
    }
}

- (void)fetchChatDetailWithCompletionHandle:(void(^)(NSArray<id<ZaloPagedModelProtocol>>*details, NSError*error))completion {
    [self fetchJsonResourceWithName:@"chatdetail" completionHandle:^(NSDictionary *json, NSError*error){
        NSArray *details = json[@"result"];
        NSArray<id<ZaloPagedModelProtocol>> *models = [self createModelsFromDetails:details];
        if (completion)
            completion(models,error);
    }];
}

- (void)fetchFriendRequestsWithCompletionHandle:(void (^)(NSArray<id<ZaloFriendRequestModelProtocol>> *, NSError *))completion {
    if (completion) {
        if (self.friendRequestArray) {
            completion(self.friendRequestArray,nil);
            return;
        }
        
        __weak ZaloDataAccessManager *weakSelf = self;
        [self fetchJsonResourceWithName:@"friendRequest" completionHandle:^(NSDictionary *json, NSError*error){
            NSArray *requests = json[@"result"];
            NSArray<id<ZaloFriendRequestModelProtocol>> *requestModels = [self createModelsFromFriendRequests:requests];
            weakSelf.friendRequestArray = requestModels;
            completion(requestModels,error);
                
        }];
    }
    
}

#pragma mark modelsFromJson

- (NSArray*)createModelsFromFriendRequests:(NSArray<NSDictionary*>*)requests {
    NSMutableArray *models = [NSMutableArray new];
    [requests enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger index, BOOL *stop){
        ZaloFriendRequestModel *model = [[ZaloFriendRequestModel alloc]init];
        model.title = object[@"title"];
        model.detail = object[@"detail"];
        model.icon = object[@"icon"];
        [models addObject:(id<ZaloFriendRequestModelProtocol>)model];
    }];
    return models;
}

- (NSArray*)createModelsFromChats:(NSArray<NSDictionary*>*)items {
    NSMutableArray *models = [NSMutableArray new];
    [items enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger index, BOOL *stop){
        ZaloMessegeModel *model = [[ZaloMessegeModel alloc]init];
        model.title = object[@"title"];
        model.detail = object[@"detail"];
        model.lastUpdate = object[@"lastUpdate"];
        model.icon = object[@"icon"];
        [models addObject:(id<ZaloMessageModelProtocol>)model];
    }];
    return models;
}


- (NSArray*)createSuggestionsModelsFromSuggestion:(NSArray<NSDictionary*>*)suggestions {
    NSMutableArray *suggestionModels = [NSMutableArray new];
    [suggestions enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger index, BOOL *stop){
        ZaloSuggestionCollectionViewModel *suggestionModel = [[ZaloSuggestionCollectionViewModel alloc]init];
        suggestionModel.title = object[@"title"];
        suggestionModel.icon = object[@"icon"];
        [suggestionModels addObject:(id<ZaloSuggestionCollectionViewModelProtocol>)suggestionModel];
    }];
    return suggestionModels;
}

- (NSArray *)createModelsFromDetails:(NSArray<NSDictionary*>*)details {
    NSMutableArray *models = [NSMutableArray new];
    [details enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger index, BOOL *stop){
        ZaloPagedModel *model = [[ZaloPagedModel alloc]init];
        model.title = object[@"title"];
        model.detail = object[@"detail"];
        model.icon = object[@"icon"];
        [models addObject:(id<ZaloPagedModelProtocol>)model];
    }];
    return models;
}

@end
