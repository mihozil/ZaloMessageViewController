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

extern NSString const* ZaloDataSourceTitleHeaderKey;

// providing everything concerning data

@class ZaloDataSource;

// this is to notify datasource's delegate.
//for example: did delete item at index; did update ..
@protocol ZaloDataSourceDelegate <NSObject>


@optional
- (void)dataSource:(ZaloDataSource*)dataSource perFormBatchUpdate:(dispatch_block_t)update completion:(dispatch_block_t)completion;

// in case composedDataSource: when child DataSource finish, notify to its parent
- (void)dataSource:(ZaloDataSource*)dataSource notifyDidLoadContentWithError:(NSError*)error;

// when updating items, notify viewController the refreshing sections -> viewController performBatchUpdate update that sections
- (void)dataSource:(ZaloDataSource*)dataSource didRefreshSections:(NSIndexSet*)sections;
- (void)dataSource:(ZaloDataSource*)dataSource didShowActivityIndicatorAtSections:(NSIndexSet*)sections;
- (void)dataSource:(ZaloDataSource*)dataSource didInsertSections:(NSIndexSet*)sections;

// updateUI after updatingDatasource; & shut Pane editing Cell
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

@property (weak, nonatomic) id<ZaloDataSourceDelegate> delegate;
@property (strong, nonatomic) ZaloDataSourcePlaceholder *loadErrorPlaceholder;
@property (strong, nonatomic) ZaloDataSourcePlaceholder *noContentPlaceholder;
@property (strong, nonatomic) ZaloDataSourcePlaceholder *placeHolder; // this should not be public. just temporary put it here
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) NSInteger collectionSuggetionIndex;
@property (strong, nonatomic) dispatch_block_t loadingCompletionBlock;
@property (strong, nonatomic) dispatch_block_t pendingUpdateBlock;
@property (assign, nonatomic) BOOL resetingContent;
@property (readonly, nonatomic) NSInteger numberOfSections;
@property (strong, nonatomic) NSMutableArray *headers; // this will move to .m file 

// load
- (void)loadContentWithProgress:(ZaloLoadingProgress*_Nullable)progress;
- (void)loadContent;
- (void)registerReusableViewsWithCollectionView:(UICollectionView*)collectionView;
- (ZaloLayoutSection*)snapShotSectionInfoAtIndex:(NSInteger)sectionIndex; // snapshot header; footer; placeholder. cell later

//read
- (NSArray<ZaloActionView*>*_Nullable)actionsForItemAtIndexPath:(NSIndexPath*_Nullable)indexPath;
- (BOOL)canEditItemAtIndexPath:(NSIndexPath*_Nullable)indexPath;
- (BOOL)canDeleteItemAtIndexPath:(NSIndexPath*_Nullable)indexPath;
- (ZaloDataSource*)dataSourceForSectionAtIndex:(NSInteger)sectionIndex;
- (NSString*)reuseIdentifierForCellAtIndexPath:(NSIndexPath*)indexPath;
- (void) findSupplementaryItemAtIndexPath:(NSIndexPath*)indexPath withBlock:(void(^)(ZaloLayoutSupplementaryItem *, ZaloDataSource *, NSIndexPath *localIndexPath)) block;

//update
- (void)removeItemAtIndexPath:(NSIndexPath*_Nullable)indexPath;
- (void)insertItem:(id _Nullable )item atIndexPath:(NSIndexPath*_Nullable)indexPath;
- (void)updateItem:(id _Nullable )item atIndexPath:(NSIndexPath*_Nullable)indexPath;
- (void)removeItemsAtIndexPaths:(NSArray<NSIndexPath*>*_Nullable)indexPaths;

- (void)endLoadContentWithState:(NSString*)state error:(NSError*)error block:(ZaloUpdateBlock)block;
- (void)performUpdate:(dispatch_block_t _Nullable )blockUpdate completion:(dispatch_block_t _Nullable )completion;
- (void)whenLoaded:(dispatch_block_t _Nullable )block;
- (ZaloLayoutSupplementaryItem*)newHeaderForKey:(NSString*)key;
@end
