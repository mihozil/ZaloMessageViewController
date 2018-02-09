//
//  ZaloCollectionViewLayout_Internal.m
//  trial
//
//  Created by CPU11806 on 1/12/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "ZaloCollectionViewLayout_Internal.h"
#import "ZaloCollectionViewLayout.h"

NSString *const ZaloCollectionElementKindPlaceHolder = @"ZaloCollectionElementKindPlaceHolder";
NSString *const ZaloCollectionElementKindRowSeparator = @"ZaloCollectionElementKindRowSeparator";
NSString *const ZaloCollectionElementKindHeader = @"ZaloCollectionElementKindHeader";

@interface ZaloLayoutPlaceHolder()

@property (strong, nonatomic) NSMutableIndexSet *sectionIndexs;
+ (instancetype)newPlaceHolderAtSection:(NSInteger)sectionIndex;
- (void)wasAddedToSection:(ZaloLayoutSection*)sectionInfo;

@end

@implementation ZaloLayoutPlaceHolder

@synthesize frame = _frame;
@synthesize itemIndex = _itemIndex;
@synthesize indexPath = _indexPath;

+ (instancetype)newPlaceHolderAtSection:(NSInteger)sectionIndex {
    ZaloLayoutPlaceHolder *placeHolderInfo = [[ZaloLayoutPlaceHolder alloc]init];
    placeHolderInfo.sectionIndexs = [[NSMutableIndexSet alloc]initWithIndex:sectionIndex];
    return placeHolderInfo;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.height = 200; //default
    }
    return self;
}

- (ZaloCollectionViewLayoutAttributes *)layoutAttributes {
    // what is neccessary to make layout attributes ?
    ZaloCollectionViewLayoutAttributes *layoutAttributes = [ZaloCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:ZaloCollectionElementKindPlaceHolder withIndexPath:self.indexPath];
    layoutAttributes.frame = self.frame;
    
    return layoutAttributes;
}

- (NSInteger)startSectionIndex {
    // return firstIndex of sectionIndexs;
    return 0;
}

- (NSInteger)endSectionIndex {
    // return lastIndex of sectionIndexs;
    return 0;
}

- (void)wasAddedToSection:(ZaloLayoutSection *)sectionInfo {
    [self.sectionIndexs addIndex:sectionInfo.sectionIndex];
    // check the new index must be continuous with the previous one
    
}


- (void)setItemIndex:(NSInteger)itemIndex {
    _itemIndex = itemIndex;
}

- (void)setFrame:(CGRect)frame {
    _frame = frame;
}

- (NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForItem:self.itemIndex inSection:self.startSectionIndex];
}

@end

@implementation ZaloLayoutCell

@synthesize frame = _frame;
@synthesize itemIndex = _itemIndex;

- (UICollectionViewLayoutAttributes *)layoutAttributes {
    // what is neccessary to make layout attributes?
    ZaloCollectionViewLayout *layout = self.sectionInfo.layoutInfo.layout;
    
    ZaloCollectionViewLayoutAttributes *layoutAttributes = [ZaloCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:self.indexPath]; // it already contains thing like copywithzone ..
    
    layoutAttributes.frame = self.frame;
    layoutAttributes.editing = layout.editing? [layout canEditItemAtIndexPath:self.indexPath] : NO;
    
    
    return layoutAttributes;
}

- (void)setFrame:(CGRect)frame {
    _frame = frame;
}

- (void)setItemIndex:(NSInteger)itemIndex {
    _itemIndex = itemIndex;
}

- (NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForItem:self.itemIndex inSection:self.sectionInfo.sectionIndex];
}

@end


@implementation ZaloLayoutSupplementaryItem

@synthesize itemIndex = _itemIndex;
@synthesize frame = _frame;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.height = 30; // default
    }
    return self;
}

- (ZaloCollectionViewLayoutAttributes *)layoutAttributes {
    ZaloCollectionViewLayoutAttributes *attributes = [ZaloCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:self.elementKind withIndexPath:self.indexPath];
    attributes.frame = self.frame;
    
    return attributes;
}

- (NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForItem:self.itemIndex inSection:self.sectionInfo.sectionIndex];
}

- (void)setItemIndex:(NSInteger)itemIndex {
    _itemIndex = itemIndex;
}

- (void)setFrame:(CGRect)frame {
    _frame = frame;
}

- (CGRect)frame {
    return _frame;
}

@end

@implementation ZaloLayoutRow {
    NSMutableArray *_items;
}

@synthesize frame = _frame;

- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [NSMutableArray array];
    }
    return self;
}

- (void)addItem:(ZaloLayoutCell *)item {
    [_items addObject:item];
    item.rowInfo = self;
}

@end

@implementation ZaloLayoutSection

// it is ok getting all information <including cell> from snapShotFromDataSource
// just get information, no initialization, no every thing ..

- (instancetype)init {
    self = [super init];
    if (self) {
        // initialization
        self.rowHeight = 64;
        self.suggestionRowHeight = 88;
        self.items = [[NSMutableArray alloc]init];;
        self.rows = [[NSMutableArray alloc]init];
        self.separatorInsets = UIEdgeInsetsMake(0, 74, 0, 0);
        self.showRowSeparators = true;
        self.separatorColor = [UIColor lightGrayColor];
        self.collectionSuggestionIndex = -1;
    }
    return self;
} 

- (void)addItem:(ZaloLayoutCell *)item {
    if (item) {
        item.sectionInfo = self;
        [self.items addObject:item];
    }
}

- (void)applyInformationFromSection:(ZaloLayoutSection *)sectionInfo {
    // header
    if (sectionInfo.headers.count>0) {
        if (!self.headers)
            self.headers = [NSMutableArray array];
        [sectionInfo.headers enumerateObjectsUsingBlock:^(ZaloLayoutSupplementaryItem *header, NSUInteger idx, BOOL *stop){
            [self addNewHeaderFromHeader:header];
        }];
    }
    
    // placeholder:
    if (!self.placeHolder && sectionInfo.placeHolder)
        self.placeHolder = sectionInfo.placeHolder;
    
    // items
    self.collectionSuggestionIndex = sectionInfo.collectionSuggestionIndex;
}

- (void)addRow:(ZaloLayoutRow*)row {
    NSInteger rowIndex = self.rows.count;
    
    [self.rows addObject:row];
    row.sectionInfo = self;
    CGFloat bottomRow = CGRectGetMaxY(row.frame);
    CGFloat rowWidth = row.frame.size.width;
    CGFloat hairLine = 0.2;
    
    if (self.showRowSeparators && !row.seperatorLayoutAttributes) {
        ZaloCollectionViewLayoutAttributes *rowSeperatorLayoutAttributes = [ZaloCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:ZaloCollectionElementKindRowSeparator withIndexPath:[NSIndexPath indexPathForItem:rowIndex inSection:self.sectionIndex]];
        rowSeperatorLayoutAttributes.backgroundColor = self.separatorColor;
        CGRect separatorFrame = CGRectMake(self.separatorInsets.left, bottomRow , rowWidth - self.separatorInsets.left - self.separatorInsets.right, hairLine);
        ZaloLayoutCell *item = [row.items firstObject];
        if (item.isSuggestionCell) {
            separatorFrame.origin.x = 0;
            separatorFrame.size.width = rowWidth;
        }
        
        [rowSeperatorLayoutAttributes setFrame:separatorFrame];
        
        row.seperatorLayoutAttributes = rowSeperatorLayoutAttributes;
    }
}

- (void)addNewHeaderFromHeader:(ZaloLayoutSupplementaryItem *)header {
    ZaloLayoutSupplementaryItem *newHeader = [[ZaloLayoutSupplementaryItem alloc]init];
    newHeader.configureView = header.configureView;
    newHeader.elementKind = header.elementKind;
    
    newHeader.sectionInfo = self;
    newHeader.itemIndex = self.headers.count;
    
    if (!self.headers)
        self.headers = [NSMutableArray array];
    [self.headers addObject:newHeader];
}

- (void)setPlaceholderInfo:(ZaloLayoutPlaceHolder *)placeholderInfo {
    
    if (!placeholderInfo)
        return;
    _placeholderInfo = placeholderInfo;
    [placeholderInfo wasAddedToSection:self];
}

- (CGFloat)layoutSectionWithOrigin:(CGFloat)start {
    ZaloLayoutInfo *layoutInfo = self.layoutInfo;
    CGFloat collectionViewWidth = layoutInfo.collectionViewWidth;
    CGFloat padding = 5; // temporary put here, will update section.padding later
    __block CGFloat originY = start;
    NSInteger numberOfItems = self.items.count;
    
    if (self.placeholderInfo && self.placeholderInfo.startSectionIndex == self.sectionIndex) { // only make placeHolder once
        CGFloat placeholderHeight = self.placeholderInfo.height;
        self.placeholderInfo.frame = CGRectMake(0, start, collectionViewWidth, placeholderHeight);
        
        originY+=self.placeholderInfo.height + padding;
    }
    
    void (^supplementaryItemBlock) (ZaloLayoutSupplementaryItem *item, NSUInteger idx, BOOL *stop) = ^(ZaloLayoutSupplementaryItem *supplementaryItem, NSUInteger idx, BOOL *stop){
        if (!numberOfItems) // and !supplementary.showWhenNoNumberOfItem
            return ;
        
        CGFloat supplementaryItemHeight = supplementaryItem.height;
        supplementaryItem.frame = CGRectMake(0, start, collectionViewWidth, supplementaryItemHeight);
        
        originY+= supplementaryItemHeight + padding;
    };
    [self.headers enumerateObjectsUsingBlock:supplementaryItemBlock];
    
    __block ZaloLayoutRow *row = [[ZaloLayoutRow alloc]init];
    void(^nextRow)(void) = ^(){ // temporary now: only one column
        
        ZaloLayoutCell *item = [row.items firstObject];
        row.frame = item.frame;
        
        [self addRow:row];
        
        // new Row
        row = [[ZaloLayoutRow alloc]init];
    };
    
    // items
    if (!self.placeholderInfo && self.items.count>0) {
        [self.items enumerateObjectsUsingBlock:^(ZaloLayoutCell *item, NSUInteger index, BOOL *stop){
            
            CGFloat rowHeight;
            if (item.isSuggestionCell)
                rowHeight = self.suggestionRowHeight;
            else rowHeight = self.rowHeight;
            item.frame = CGRectMake(0, originY, collectionViewWidth, rowHeight);
            
            originY+=rowHeight+padding;
            
            [row addItem:item];
            
            if (nextRow)
                nextRow();
        }];
    }
    return originY;
}

- (void)enumerateLayoutAttributesWithCompletionBlock:(void (^)(ZaloCollectionViewLayoutAttributes *, BOOL *))completionBlock {
    __block BOOL stop = false;
    if (self.placeholderInfo && self.placeholderInfo.startSectionIndex == self.sectionIndex) {
        if (completionBlock)
            completionBlock(self.placeholderInfo.layoutAttributes, &stop);
    }
    if (stop) {
        return;
    }
    
    if (!self.placeholderInfo) { // globalSection is for incase show placeholder but still show header
        void (^supplementaryItemBlock) (ZaloLayoutSupplementaryItem *item, NSUInteger idx, BOOL *stop) = ^(ZaloLayoutSupplementaryItem *item, NSUInteger idx, BOOL *itemStop){
            if (completionBlock)
                completionBlock(item.layoutAttributes,&stop);
        };
        [self.headers enumerateObjectsUsingBlock:supplementaryItemBlock];
        if (stop)
            return;
        
        
        for (ZaloLayoutRow *row in self.rows) {
            if (row.seperatorLayoutAttributes) {
                if (completionBlock)
                    completionBlock(row.seperatorLayoutAttributes, &stop);
                
                if (stop)
                    return;
            }
            
            for (ZaloLayoutCell *item in row.items) {
                if (completionBlock)
                    completionBlock(item.layoutAttributes, &stop);
                if (stop)
                    return;
            }
        }
    }
    
}

- (ZaloCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:ZaloCollectionElementKindPlaceHolder]) {
        if (self.placeholderInfo)
            return self.placeholderInfo.layoutAttributes;
    }
    
    if ([kind isEqualToString:ZaloCollectionElementKindHeader]) {
        ZaloLayoutSupplementaryItem *header = [self.headers objectAtIndex:indexPath.item];
        return header.layoutAttributes;
    }
    
    return nil;
}

- (ZaloCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger itemIndex = indexPath.item;
    if (itemIndex<self.items.count) {
        ZaloLayoutCell *item = [_items objectAtIndex:itemIndex];
        return item.layoutAttributes;
    }
    return nil;
}

- (ZaloCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:ZaloCollectionElementKindRowSeparator]) {
        if (indexPath.item<self.rows.count) {
            ZaloLayoutRow *row = [self.rows objectAtIndex:indexPath.item];
            return row.seperatorLayoutAttributes;
        }
    }
    return nil;
}


@end

@interface ZaloLayoutInfo()

@property (strong, nonatomic) NSMutableArray<ZaloLayoutSection*> *sections;
@property (weak, nonatomic) ZaloCollectionViewLayout *layout;

@end

@implementation ZaloLayoutInfo

- (instancetype)initWithLayout:(ZaloCollectionViewLayout *)layout {
    self = [super init];
    if (self) {
        self.layout = layout;
    }
    return self;
}


- (void)addSection:(ZaloLayoutSection *)section {
    if (section) {
        if (!self.sections)
            self.sections = [NSMutableArray array];
        section.layoutInfo = self;
        [self.sections addObject:section];
    }
}

- (void)enumerateSectionsWithCompletionBlock:(void (^)(ZaloLayoutSection *, NSUInteger, BOOL *))completionBlock {
    [self.sections enumerateObjectsUsingBlock:^(ZaloLayoutSection *section, NSUInteger index, BOOL *stop){
        if (completionBlock) {
            completionBlock(section, index, stop);
        }
    }];
}

- (ZaloLayoutSection *)sectionInfoForSectionAtIndex:(NSInteger)index {
    if (index<self.sections.count)
        return [self.sections objectAtIndex:index];
    return nil;
}

- (ZaloCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger sectionIndex = indexPath.section;
    
    if (sectionIndex<self.sections.count) {
        
        ZaloLayoutSection *sectionInfo = [self.sections objectAtIndex:sectionIndex];
        return [sectionInfo layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    }
    
    return nil;
}
- (ZaloCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger sectionIndex = indexPath.section;
    if (sectionIndex<self.sections.count) {
        ZaloLayoutSection *sectionInfo = [self.sections objectAtIndex:sectionIndex];
        return [sectionInfo layoutAttributesForItemAtIndexPath:indexPath];
    }
    return nil;
}

- (ZaloCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:ZaloCollectionElementKindRowSeparator]) {
        if (indexPath.section<self.sections.count) {
            ZaloLayoutSection *sectionInfo = [self.sections objectAtIndex:indexPath.section];
            return [sectionInfo layoutAttributesForDecorationViewOfKind:kind atIndexPath:indexPath];
        }
    }
    return nil;
}

- (ZaloLayoutSection*)newSectionInfoAtIndex:(NSInteger)sectionIndex {
    ZaloLayoutSection *sectionInfo = [[ZaloLayoutSection alloc]init];
    sectionInfo.layoutInfo = self;
    sectionInfo.sectionIndex = sectionIndex;
    [self addSection:sectionInfo];
    
    return sectionInfo;
}

- (ZaloLayoutPlaceHolder*)newPlaceholderInfoBeginAtSection:(NSInteger)sectionIndex {
    ZaloLayoutPlaceHolder *placeholderInfo = [ZaloLayoutPlaceHolder newPlaceHolderAtSection:sectionIndex];
    return placeholderInfo;
}

@end
