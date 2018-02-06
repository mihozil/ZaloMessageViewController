//
//  ZaloSuggestionCollectionViewCell.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/17/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloSuggestionCollectionViewCell.h"
#import "ZaloSuggestionDataSource.h"
#import "ZaloMessageFoundations.h"
#import "ZaloDataSource.h"

@interface ZaloSuggestionCollectionViewCell()

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation ZaloSuggestionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpCollectionView];
    }
    return self;
}

- (void)setUpCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat itemSize = self.contentView.frame.size.height - 5;
    flowLayout.itemSize = CGSizeMake(itemSize, itemSize);
    flowLayout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    flowLayout.minimumInteritemSpacing = 2.0;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:self.contentView.bounds collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = false;
    [self.contentView addSubview:self.collectionView];
    [self.collectionView makeConstraints:^(MASConstraintMaker*make){
        make.top.and.bottom.and.left.and.right.equalTo(@0);
    }];
}

- (void)setModel:(id)model { // will be call from Parent's cellForItemAtIndexPath: setCellModel
    if ([model isKindOfClass:[ZaloDataSource class]]) {
        
        ZaloDataSource *dataSource = (ZaloDataSource*)model;
        
        [super setModel:dataSource];
        self.collectionView.dataSource = dataSource;
        [dataSource registerReusableViewsWithCollectionView:self.collectionView];
        
    }
}

// issue: it should be that, i can use the ZaloDataSoure and ZaloCollectionViewCell without having to create a new layout. too complicated

@end
