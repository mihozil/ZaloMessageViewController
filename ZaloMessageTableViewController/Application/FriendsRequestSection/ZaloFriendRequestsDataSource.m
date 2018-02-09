//
//  ZaloFriendRequestsDataSource.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/26/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloFriendRequestsDataSource.h"
#import "ZaloDataAccessManager.h"
#import "ZaloFriendRequestsCollectionViewCell.h"
#import "ZaloSectionHeaderView.h"
#import "ZaloCollectionViewController.h"

@implementation ZaloFriendRequestsDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        ZaloLayoutSupplementaryItem *sectionHeader = [self newHeaderForKey:ZaloDataSourceTitleHeaderKey];
        sectionHeader.supplementaryViewClass = [ZaloSectionHeaderView class];
        sectionHeader.configureView = ^(UICollectionReusableView *view, ZaloDataSource*dataSource, NSIndexPath*indexPath){
            ZaloSectionHeaderView *sectionHeaderView = (ZaloSectionHeaderView*)view;
            sectionHeaderView.leftText = dataSource.title;
        };
    }
    return self;
}

- (void)loadContentWithProgress:(ZaloLoadingProgress *)progress {
    void (^loadFriendRequestsCompletion) (NSArray<id<ZaloFriendRequestModelProtocol>>*, NSError*) = ^(NSArray<id<ZaloFriendRequestModelProtocol>>*requestModels, NSError*error){
        if (error) {
            [progress loadCompletionWithError:error];
            return;
        }
        if (!requestModels || requestModels.count == 0) {
            [progress loadCompletionWithNoContent];
            return;
        }
        [progress loadCompletionWithUpdate:^(ZaloFriendRequestsDataSource *me){
            [me setModels:requestModels];
        }];
    };
    [[ZaloDataAccessManager sharedInstance]fetchFriendRequestsWithCompletionHandle:loadFriendRequestsCompletion];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = [super collectionView:collectionView numberOfItemsInSection:section];
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark subClass
- (NSString *)reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    return NSStringFromClass([ZaloFriendRequestsCollectionViewCell class]);
}

- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView {
    [super registerReusableViewsWithCollectionView:collectionView];
    [collectionView registerClass:[ZaloFriendRequestsCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ZaloFriendRequestsCollectionViewCell class])];
}

- (BOOL)canDeleteItemAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (BOOL)canEditItemAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (NSArray<ZaloActionView *> *)actionsForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZaloActionView *deleteAction = [[ZaloActionView alloc]initWithTitle:@"Delete" selector:@selector(deleteActionFromCell:)];
    ZaloActionView *muteAction = [[ZaloActionView alloc]initWithTitle:@"Mute" selector:@selector(muteActionFromCell:)];
    ZaloActionView *hideAction = [[ZaloActionView alloc]initWithTitle:@"Hide" selector:@selector(hideActionFromCell:)];
    return @[deleteAction,muteAction,hideAction];
}

@end
