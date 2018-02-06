//
//  ZaloCollectionViewLayout_Internal.h
//  trial
//
//  Created by CPU11806 on 1/12/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZaloCollectionViewLayoutAttributes.h"
#import "ZaloCollectionViewLayout.h"

extern NSString *const ZaloCollectionElementKindPlaceHolder;
extern NSString *const ZaloCollectionElementKindRowSeparator;
extern NSString *const ZaloCollectionElementKindHeader;

@class ZaloLayoutInfo;
@class ZaloLayoutSection;
@class ZaloLayoutRow;
@class ZaloDataSource;

@protocol ZaloLayoutAttributesResolving<NSObject>

- (ZaloCollectionViewLayoutAttributes*)layoutAttributesForSupplementaryViewOfKind:(NSString*)kind atIndexPath:(NSIndexPath*)indexPath;
- (ZaloCollectionViewLayoutAttributes*)layoutAttributesForDecorationViewOfKind:(NSString*)kind atIndexPath:(NSIndexPath*)indexPath;
- (ZaloCollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath;

@end // implement later

@protocol ZaloGridLayoutObject<NSObject>

@property (assign, nonatomic) CGRect frame;
@property (assign, nonatomic) NSInteger itemIndex;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) ZaloCollectionViewLayoutAttributes *layoutAttributes;

@end

// layout information for the placeHolder
@interface ZaloLayoutPlaceHolder : NSObject <ZaloGridLayoutObject>

@property (assign, nonatomic) CGFloat height;
@property (readonly, nonatomic) NSInteger startSectionIndex, endSectionIndex;

@end

@interface ZaloLayoutSupplementaryItem : NSObject <ZaloGridLayoutObject>

@property (assign, nonatomic) CGFloat height;

@property (strong, nonatomic) NSString *elementKind;
@property (weak, nonatomic) ZaloLayoutSection *sectionInfo;
@property (strong, nonatomic) void(^configureView)(UICollectionReusableView *, ZaloDataSource* , NSIndexPath *);
@property (nonatomic) Class supplementaryViewClass;

@end

// layout information for item
@interface ZaloLayoutCell : NSObject <ZaloGridLayoutObject>
@property (weak, nonatomic) ZaloLayoutSection*sectionInfo;
@property (assign, nonatomic) BOOL isSuggestionCell; // temporary. i think this is not true putting here
@property (weak, nonatomic) ZaloLayoutRow *rowInfo;

@end

@interface ZaloLayoutRow: NSObject <ZaloGridLayoutObject>

@property (weak, nonatomic) ZaloLayoutSection *sectionInfo;
@property (readonly, copy, nonatomic) NSArray<ZaloLayoutCell*> *items;
@property (strong, nonatomic) ZaloCollectionViewLayoutAttributes *seperatorLayoutAttributes;

- (void)addItem:(ZaloLayoutCell*)item;

@end

// layout information for the section
@interface ZaloLayoutSection: NSObject <ZaloLayoutAttributesResolving>

@property (weak, nonatomic) ZaloLayoutInfo *layoutInfo;
@property (assign, nonatomic) NSInteger rowHeight, suggestionRowHeight;
@property (strong, nonatomic)ZaloLayoutPlaceHolder *placeholderInfo;
@property (strong, nonatomic) id placeHolder;
@property (assign, nonatomic)NSInteger sectionIndex;
@property (strong, nonatomic) NSMutableArray<ZaloLayoutRow*> *rows;
@property (strong, nonatomic) NSMutableArray<ZaloLayoutCell*> *items;
@property (assign, nonatomic) UIEdgeInsets separatorInsets;
@property (assign, nonatomic) BOOL showRowSeparators;
@property (strong, nonatomic) UIColor *separatorColor;
@property (strong, nonatomic) NSMutableArray<ZaloLayoutSupplementaryItem*>* headers;
@property (assign, nonatomic) NSInteger collectionSuggestionIndex;

- (void)addItem:(ZaloLayoutCell*)item;
- (void)addRow:(ZaloLayoutRow*)row;
- (void)addNewHeaderFromHeader:(ZaloLayoutSupplementaryItem*)header;
- (void)enumerateLayoutAttributesWithCompletionBlock:(void(^)(ZaloCollectionViewLayoutAttributes *attributes, BOOL *stop))completionBlock;
- (CGFloat)layoutSectionWithOrigin:(CGFloat)start;
- (void)applyInformationFromSection:(ZaloLayoutSection*)sectionInfo;

@end

@interface ZaloLayoutInfo: NSObject <ZaloLayoutAttributesResolving>

@property (assign, nonatomic) CGFloat collectionViewWidth;
@property (weak, readonly, nonatomic) ZaloCollectionViewLayout *layout;

- (instancetype)initWithLayout:(ZaloCollectionViewLayout*)layout;
- (void)addSection:(ZaloLayoutSection*)section;
- (void)enumerateSectionsWithCompletionBlock:(void(^)(ZaloLayoutSection*section, NSUInteger sectionIndex, BOOL *stop))completionBlock;
- (ZaloLayoutSection*)sectionInfoForSectionAtIndex:(NSInteger)index;
- (ZaloLayoutSection*)newSectionInfoAtIndex:(NSInteger)sectionIndex;
- (ZaloLayoutPlaceHolder*)newPlaceholderInfoBeginAtSection:(NSInteger)sectionIndex;

@end

