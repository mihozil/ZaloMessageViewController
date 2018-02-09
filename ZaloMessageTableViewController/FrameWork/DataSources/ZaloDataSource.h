//
//  ZaloDataSource.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/25/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZaloCollectionViewCell.h"
#import "ZaloLoadingProgress.h"
#import "ZaloCollectionViewLayout_Internal.h"

extern NSString *const ZaloDataSourceTitleHeaderKey;

// providing everything concerning data

@class ZaloDataSource;

// this is to notify datasource's delegate.
//for example: did delete item at index; did update ..
@protocol ZaloDataSourceDelegate <NSObject>


@optional
- (void)dataSource:(ZaloDataSource*)dataSource perFormBatchUpdate:(dispatch_block_t)update completion:(dispatch_block_t)completion;

- (void)dataSource:(ZaloDataSource*)dataSource notifyDidLoadContentWithError:(NSError*)error;

- (void)dataSource:(ZaloDataSource*)dataSource didRefreshSections:(NSIndexSet*)sections;
- (void)dataSource:(ZaloDataSource*)dataSource didShowActivityIndicatorAtSections:(NSIndexSet*)sections;
- (void)dataSource:(ZaloDataSource*)dataSource didInsertSections:(NSIndexSet*)sections;

- (void)dataSource:(ZaloDataSource*)dataSource didRemoveItemsAtIndexPaths:(NSArray*)indexPaths;
- (void)dataSource:(ZaloDataSource*)dataSource didMoveItemFromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath;

@end

@interface ZaloDataSourcePlaceholder : NSObject

+ (instancetype)placeholderWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image;
@property (copy, nonatomic) NSString *title, *message;
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) BOOL showActivityIndicator;

@end

@interface ZaloDataSource : NSObject <UICollectionViewDataSource,ZaloLoadingState, ZaloStateMachineDelegate>

#pragma mark loadingContent
@property (strong, nonatomic) dispatch_block_t loadingCompletionBlock;
- (void)loadContentWithProgress:(ZaloLoadingProgress*_Nullable)progress;
- (void)loadContent;
- (ZaloLayoutSection*_Nullable)snapShotSectionInfoAtIndex:(NSInteger)sectionIndex; // snapshot header; footer; placeholder. cell later
- (void)endLoadContentWithState:(NSString*)state error:(NSError*)error block:(ZaloUpdateBlock)block;

#pragma mark dataSourceAPI
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) NSInteger collectionSuggetionIndex;
@property (weak, nonatomic) id<ZaloDataSourceDelegate> delegate;
- (void)registerReusableViewsWithCollectionView:(UICollectionView*_Nullable)collectionView;
- (NSArray<ZaloActionView*>*_Nullable)actionsForItemAtIndexPath:(NSIndexPath*_Nullable)indexPath;
- (BOOL)canEditItemAtIndexPath:(NSIndexPath*_Nullable)indexPath;
- (BOOL)canDeleteItemAtIndexPath:(NSIndexPath*_Nullable)indexPath;
- (ZaloDataSource*)dataSourceForSectionAtIndex:(NSInteger)sectionIndex;
- (NSString*)reuseIdentifierForCellAtIndexPath:(NSIndexPath*)indexPath;


#pragma mark update
@property (strong, nonatomic) dispatch_block_t pendingUpdateBlock;
@property (assign, nonatomic) BOOL resetingContent;
- (void)removeItemAtIndexPath:(NSIndexPath*_Nullable)indexPath;
- (void)insertItem:(id _Nullable )item atIndexPath:(NSIndexPath*_Nullable)indexPath;
- (void)updateItem:(id _Nullable )item atIndexPath:(NSIndexPath*_Nullable)indexPath;
- (void)removeItemsAtIndexPaths:(NSArray<NSIndexPath*>*_Nullable)indexPaths;
- (void)whenLoaded:(dispatch_block_t _Nullable )block;
- (void)performUpdate:(dispatch_block_t _Nullable )blockUpdate completion:(dispatch_block_t _Nullable )completion;

#pragma mark sectionInfo
@property (readonly, nonatomic) NSInteger numberOfSections;
@property (strong, nonatomic) ZaloDataSourcePlaceholder * _Nullable noContentPlaceholder;
@property (strong, nonatomic) ZaloDataSourcePlaceholder *loadErrorPlaceholder;
- (NSInteger)numberOfHeadersForSectionAtIndex:(NSInteger)index includeChildDataSource:(BOOL)includeChildDataSource;
- (void) findSupplementaryItemAtIndexPath:(NSIndexPath*)indexPath withBlock:(void(^)(ZaloLayoutSupplementaryItem *, ZaloDataSource *, NSIndexPath *localIndexPath)) block;
- (ZaloLayoutSupplementaryItem*)newHeaderForKey:(NSString*)key;

@end
