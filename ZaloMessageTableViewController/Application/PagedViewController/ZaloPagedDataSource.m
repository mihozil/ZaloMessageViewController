//
//  ZaloPagedDataSource.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/24/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloPagedDataSource.h"
#import "ZaloPagedCollectionViewCell.h"
#import "ZaloDataAccessManager.h"
#import "ZaloPagedModel.h"
#import "ZaloCollectionViewController.h"

@implementation ZaloPagedDataSource

#pragma mark load
- (void)loadContentWithProgress:(ZaloLoadingProgress *)progress {
    void(^loadContentCompletion)(NSArray<id<ZaloPagedModelProtocol>>*, NSError*) = ^(NSArray<id<ZaloPagedModelProtocol>>*detailModels, NSError*error) {
        if (error) {
            [progress loadCompletionWithError:error];
            return;
        }
        if (!detailModels || detailModels.count==0) {
            [progress loadCompletionWithNoContent];
            return;
        }
        
        [progress loadCompletionWithUpdate:^(ZaloPagedDataSource*me){
            [me setModels:detailModels];
        }];
    };
    [[ZaloDataAccessManager sharedInstance]fetchChatDetailWithCompletionHandle:loadContentCompletion];
}

#pragma mark collectionViewDataSource

- (NSString *)reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    return NSStringFromClass([ZaloPagedCollectionViewCell class]);
}

- (NSArray<ZaloActionView *> *)actionsForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZaloActionView *deleteAction = [[ZaloActionView alloc]initWithTitle:@"Delete" selector:@selector(deleteActionFromCell:)];
    ZaloActionView *muteAction = [[ZaloActionView alloc]initWithTitle:@"Mute" selector:@selector(muteActionFromCell:)];
    ZaloActionView *hideAction = [[ZaloActionView alloc]initWithTitle:@"Hide" selector:@selector(hideActionFromCell:)];
    return @[deleteAction,muteAction,hideAction];
}

#pragma mark subClass
- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView {
    [super registerReusableViewsWithCollectionView:collectionView];
    [collectionView registerClass:[ZaloPagedCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ZaloPagedCollectionViewCell class])];
}

- (BOOL)canDeleteItemAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (BOOL)canEditItemAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

@end
