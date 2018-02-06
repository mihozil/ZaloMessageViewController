//
//  ZaloCollectionViewLayout.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/26/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloCollectionViewLayout.h"
#import "ZaloCollectionViewLayoutAttributes.h"
#import "ZaloCollectionViewCell.h"
#import "ZaloSuggestionCollectionViewCell.h"
#import "ZaloCollectionViewLayout_Internal.h"


@interface ZaloCollectionViewSeparatorView : UICollectionReusableView

@end

@implementation ZaloCollectionViewSeparatorView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    if ([layoutAttributes isKindOfClass:[ZaloCollectionViewLayoutAttributes class]]) {
        ZaloCollectionViewLayoutAttributes *separatorLayoutAttributes = (ZaloCollectionViewLayoutAttributes*)layoutAttributes;
        self.backgroundColor = separatorLayoutAttributes.backgroundColor;
    }
}

@end


@interface ZaloCollectionViewLayout()

@property (strong, nonatomic) ZaloLayoutInfo *layoutInfo, *oldLayoutInfo;
@property (assign, nonatomic) CGSize layoutSize; // temporary
@property (strong, nonatomic) NSMutableDictionary *additionalDeletedIndexPath, *additionalInsertedIndexPath;

@end

@implementation ZaloCollectionViewLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self registerClass:[ZaloCollectionViewSeparatorView class] forDecorationViewOfKind:ZaloCollectionElementKindRowSeparator];
}

- (void)prepareLayout {
    
    if (!CGRectIsEmpty(self.collectionView.bounds)) {
        [self buildLayout];
    }
    
    [super prepareLayout];
}

- (void)buildLayout {

    
    [self createLayoutInfoFromDataSource]; 
    
    NSInteger numberOfSection = self.collectionView.numberOfSections;
    CGFloat start =0;
    // here, we can take things like sectionIndex; placeholder index; sectionINdex
    
    for (NSInteger sectionIndex = 0; sectionIndex<numberOfSection; sectionIndex++) {
        ZaloLayoutSection *section = [self.layoutInfo sectionInfoForSectionAtIndex:sectionIndex];
        start = [section layoutSectionWithOrigin:start];
    }
    
    _layoutSize = CGSizeMake(self.collectionView.bounds.size.width, start);
}

- (void)resetLayoutInfo {
    _oldLayoutInfo = _layoutInfo;
    //1. resetLayoutInfo
    _layoutInfo = [[ZaloLayoutInfo alloc]initWithLayout:self];
    _layoutInfo.collectionViewWidth = self.collectionView.bounds.size.width; // where should I put this ?
}

- (void)createLayoutInfoFromDataSource {
    [self resetLayoutInfo];
    
    ZaloDataSource *datasource = (ZaloDataSource*)self.collectionView.dataSource;
    if (![datasource isKindOfClass:[ZaloDataSource class]])
        return;
    
    NSInteger numberOfSection = datasource.numberOfSections; // also update Mapping
    
    // snapShotDataSource
    for (NSInteger sectionIndex = 0; sectionIndex<numberOfSection; sectionIndex++) {
        ZaloLayoutSection *sectionInfo = [datasource snapShotSectionInfoAtIndex:sectionIndex];
        sectionInfo.sectionIndex = sectionIndex;
        [_layoutInfo addSection:sectionInfo];
    }
    
    // placeholders
    id placeholder = nil;
    ZaloLayoutPlaceHolder *placeholderInfo = nil;
    for (NSInteger sectionIndex = 0; sectionIndex<numberOfSection; sectionIndex++) {
        ZaloLayoutSection *sectionInfo = [_layoutInfo sectionInfoForSectionAtIndex:sectionIndex];
        if (sectionInfo.placeHolder) {
            if (sectionInfo.placeHolder != placeholder) {
                placeholderInfo = [_layoutInfo newPlaceholderInfoBeginAtSection:sectionIndex];
                [sectionInfo setPlaceholderInfo:placeholderInfo];
            }
            
            placeholder = sectionInfo.placeHolder;
            [sectionInfo setPlaceholderInfo:placeholderInfo];
        }
        
    }
    
    // populateSection : items
    for (NSInteger sectionIndex = 0; sectionIndex<numberOfSection; sectionIndex++) {
        [self populateSectionAtIndex:sectionIndex];
    }
}

- (void)populateSectionAtIndex:(NSInteger)sectionIndex {
    
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:sectionIndex];
    ZaloLayoutSection *sectionInfo = [_layoutInfo sectionInfoForSectionAtIndex:sectionIndex];
    
    for (NSInteger itemIndex = 0; itemIndex<numberOfItems; itemIndex++) {
        ZaloLayoutCell *itemInfo = [[ZaloLayoutCell alloc]init];
        if (sectionInfo.collectionSuggestionIndex == itemIndex)
            itemInfo.isSuggestionCell = true;
        itemInfo.itemIndex = itemIndex;
        [sectionInfo addItem:itemInfo];
    }
}

#pragma mark collectionViewLayoutAPI
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    ZaloCollectionViewLayoutAttributes *layoutAttributes = [self.layoutInfo layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
    
    if (!layoutAttributes)
        NSAssert(NO, @"layoutAttributes Must Not Be Nil");
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZaloCollectionViewLayoutAttributes *layoutAttributes = [self.layoutInfo layoutAttributesForItemAtIndexPath:indexPath];

    if (!layoutAttributes)
        NSAssert(NO, @"layoutAttributes Must Not Be Nil");
    return layoutAttributes;
}

//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath {
//    if ([elementKind isEqualToString:ZaloCollectionElementKindRowSeparator]) {
//        ZaloCollectionViewLayoutAttributes *layoutAttributes = [self.layoutInfo layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:decorationIndexPath];
//
//        NSLog(@"initialLayoutDecoration: %ld",decorationIndexPath.row);
//        return layoutAttributes;
//    }
//    return nil;
//}

// this get called when insert/delete of performBatchUpdate
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([elementKind isEqualToString:ZaloCollectionElementKindRowSeparator]) {
        ZaloCollectionViewLayoutAttributes *layoutAttributes = [self.layoutInfo layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
        
        if (!layoutAttributes)
            NSAssert(NO, @"layoutAttributes Must Not Be Nil");
        
        return layoutAttributes;
    }
    
    NSAssert(NO, @"layoutAttributes Must Not Be Nil");
    return nil;
}

- (NSArray<NSIndexPath *> *)indexPathsToDeleteForDecorationViewOfKind:(NSString *)elementKind {
    NSMutableArray *toDeleteIndexPaths = [[super indexPathsToDeleteForDecorationViewOfKind:elementKind] mutableCopy];
    NSArray *additionalDeleteIndexPaths = [[self.additionalDeletedIndexPath objectForKey:elementKind] copy];
    if (additionalDeleteIndexPaths.count>0)
        [toDeleteIndexPaths addObjectsFromArray:additionalDeleteIndexPaths];
    
    return toDeleteIndexPaths;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray new];
    
    [self.layoutInfo enumerateSectionsWithCompletionBlock:^(ZaloLayoutSection*sectionInfo, NSUInteger sectionIndex, BOOL*stop){
        [sectionInfo enumerateLayoutAttributesWithCompletionBlock:^(ZaloCollectionViewLayoutAttributes*attributes, BOOL *stop){
            [layoutAttributes addObject:attributes];
        }];
    }];
    
    return layoutAttributes;
}

- (CGSize)collectionViewContentSize {
    return _layoutSize;
}

- (void)recordAdditionalDeleteIndexPath:(NSIndexPath*)indexPath forElementKind:(NSString*)elementKind {
    NSMutableArray *kindIndexPaths = [self.additionalInsertedIndexPath[elementKind] mutableCopy];
    if (!kindIndexPaths)
        kindIndexPaths = [NSMutableArray array];
    if (indexPath)
        [kindIndexPaths addObject:indexPath];
    
    [self.additionalDeletedIndexPath setObject:kindIndexPaths forKey:elementKind];
    
}

- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems {
    self.additionalDeletedIndexPath = [NSMutableDictionary dictionary];
    self.additionalInsertedIndexPath = [NSMutableDictionary dictionary];
    
    for (UICollectionViewUpdateItem *item in updateItems) {
        if (item.updateAction == UICollectionUpdateActionDelete) {
            
            NSIndexPath *beforeIndexPath = item.indexPathBeforeUpdate;
            ZaloLayoutSection *section = [_oldLayoutInfo sectionInfoForSectionAtIndex:beforeIndexPath.section];
            ZaloLayoutRow *rowInfo = [section.rows objectAtIndex:beforeIndexPath.item];
            
            [self recordAdditionalDeleteIndexPath:rowInfo.seperatorLayoutAttributes.indexPath forElementKind:ZaloCollectionElementKindRowSeparator];
        }
    }
    
    [super prepareForCollectionViewUpdates:updateItems];
}


#pragma mark publics
- (BOOL)canEditItemAtIndexPath:(NSIndexPath *)indexPath {
    ZaloDataSource *dataSource = (ZaloDataSource*)self.collectionView.dataSource;
    return self.editing? [dataSource canEditItemAtIndexPath:indexPath] : NO;
}

@end
