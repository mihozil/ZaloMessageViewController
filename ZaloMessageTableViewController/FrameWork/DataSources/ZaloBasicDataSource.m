//
//  ZaloBasicDataSource.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/30/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloBasicDataSource.h"

@implementation ZaloBasicDataSource

// set items usually be called from subClass DataSource
// normally, all the update <items; loadingState, refresedSections be make within updateBlock. So dataSource has no idea about >
- (void)setModels:(NSMutableArray *)items {
    if (_models == items || [_models isEqualToArray:items])
        return;
    
    _models = items;
    
    // loadingState
    self.loadingState = ZaloLoadingStateLoaded;
    
    // notifySectionRefreshed
    if ([self.delegate respondsToSelector:@selector(dataSource:didRefreshSections:)]) {
        [self.delegate dataSource:self didRefreshSections:[NSIndexSet indexSetWithIndex:0]];
    }
}

#pragma mark update

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
    [self removeItemsAtIndexPaths:@[indexPath]];
}

- (void)removeItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    for (NSIndexPath *indexPath in indexPaths) {
        [indexSet addIndex:indexPath.item];
    }

    NSMutableArray *models = [_models mutableCopy];
    [models removeObjectsAtIndexes:indexSet];
    _models = models;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataSource:didRemoveItemsAtIndexPaths:)]) {
        [self.delegate dataSource:self didRemoveItemsAtIndexPaths:indexPaths];
    }
    
    
//    __block dispatch_block_t batchUpdate = ^{};
//    NSMutableArray *newModels = [NSMutableArray new];
//
//    [_models enumerateObjectsUsingBlock:^(id model, NSUInteger idx, BOOL *stop){
//        dispatch_block_t oldBlock = batchUpdate;
//
//        if ([indexSet containsIndex:idx]) { // remove idx
//            batchUpdate = ^{
//                oldBlock();
//                [delegate dataSource:self didRemoveItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:0]]];
//            };
//        } else { // keep idx
//            NSInteger newIdx = [newModels count];
//            [newModels addObject:model];
//            batchUpdate = ^{
//                oldBlock();
//
//                [delegate dataSource:self didMoveItemFromIndexPath:[NSIndexPath indexPathForItem:idx inSection:0] toIndexPath:[NSIndexPath indexPathForItem:newIdx inSection:0]];
//            };
//        }
//    }];

    // will perform all update after finish update models
//    batchUpdate(); // not turn activate batchUpdate here ?
}

- (void)updateModels:(NSArray *)models {
    _models = models;
}

#pragma mark collectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reuseIdentifier = [self reuseIdentifierForCellAtIndexPath:indexPath];
    
    ZaloCollectionViewCell *cell = (ZaloCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    id model = [_models objectAtIndex:indexPath.row];
    
    [cell setModel:model];
    
    return cell;
}

@end
