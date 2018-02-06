//
//  ZaloSuggestionDataSource.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/17/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloSuggestionDataSource.h"
#import "ZaloSuggestionCollectionViewCellCell.h"


@implementation ZaloSuggestionDataSource

- (void)setModels:(NSArray *)models {
    [super setModels:models];
}


#pragma mark subClass
- (NSString *)reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    return NSStringFromClass([ZaloSuggestionCollectionViewCellCell class]);
}

- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView {
//    [super registerReusableViewsWithCollectionView:collectionView];
    [collectionView registerClass:[ZaloSuggestionCollectionViewCellCell class] forCellWithReuseIdentifier:NSStringFromClass([ZaloSuggestionCollectionViewCellCell class])];
}

#pragma mark collectionDataSource
// superClass

@end

