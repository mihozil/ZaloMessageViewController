//
//  ZaloMessageDataSource.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/30/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloChatMessageDataSource.h"
#import "ZaloCollectionViewLayoutAttributes.h"
#import "ZaloCollectionViewLayout.h"
#import "ZaloCollectionViewController.h"
#import "ZaloSuggestionCollectionSupplementaryView.h"
#import "ZaloDataAccessManager.h"
#import "ZaloChatMessegeModel.h"
#import "ZaloMessengeCollectionViewCell.h"
#import "ZaloSuggestionDataSource.h"
#import "ZaloMessageFoundations.h"
#import "ZaloSuggestionCollectionViewModel.h"
#import "ZaloSuggestionCollectionViewCell.h"
#import "ZaloCollectionViewLayout_Internal.h"

@interface ZaloChatMessageDataSource ()

@property (strong, nonatomic) ZaloSuggestionDataSource *suggestionDataSource;

@end

@implementation ZaloChatMessageDataSource {
    
}

// in dataSource, it load the data it self and is gonna show up when all the load finished
// a state machine control the load state: successful or fail or error or loading
// collectionView.dataSource = datasource & what about loading or error?
- (instancetype)init {
    self = [super init];
    if (self) {
        [self createSuggestionObjects];
        // registerReuse...
    }
    return self;
}

- (void)createSuggestionObjects {
    // remember to register
    self.suggestionDataSource = [[ZaloSuggestionDataSource alloc]init];
}
// note: if things go right, there a block load content. than completion -> update

#pragma mark load
- (void)loadContentWithProgress:(ZaloLoadingProgress*)progress {
    
    __block NSMutableArray *models = [NSMutableArray new];
    __block dispatch_group_t loadGroup = dispatch_group_create();
    __block NSError *loadError = nil;
    __weak ZaloChatMessageDataSource *weakSelf = self;
    
    dispatch_group_enter(loadGroup);
    void (^loadChatsCompletion) (NSArray<id<ZaloMessageModelProtocol>>*chatModels, NSError*error) = ^(NSArray<id<ZaloMessageModelProtocol>>*chatModels, NSError*error){
        
        if (error) {
            loadError = error;
        }  else
            if (!chatModels || chatModels.count == 0) {
                
            } else {
                [models addObjectsFromArray:chatModels];
            }
        
        dispatch_group_leave(loadGroup);
    };
    
    dispatch_group_enter(loadGroup);
    void (^loadSuggestionCompletion) (NSArray<id<ZaloSuggestionCollectionViewModelProtocol>>*suggestionModels, NSError*error) = ^(NSArray<id<ZaloSuggestionCollectionViewModelProtocol>>*suggestionModels, NSError*error){
        if (error) {
            
        } else
            if (!suggestionModels || suggestionModels.count == 0) {
                
            } else {
                weakSelf.suggestionDataSource.models = suggestionModels;
                [models addObject:weakSelf.suggestionDataSource];
            }
        
        dispatch_group_leave(loadGroup);
    };
    
    dispatch_group_notify(loadGroup, dispatch_get_main_queue(), ^{
        
        if (loadError) {
            [progress loadCompletionWithError:loadError];
        } else if (models.count == 0) {
            [progress loadCompletionWithNoContent];
        } else {
            [weakSelf reArrangeModels:models];
            [progress loadCompletionWithUpdate:^(ZaloChatMessageDataSource *me){
                [me setModels:models];
            }];
        }
        
    });
    
    [[ZaloDataAccessManager sharedInstance]fetchChatsWithCompletionHandle:loadChatsCompletion];
    [[ZaloDataAccessManager sharedInstance]fetchSuggestionWithCompletionHandle:loadSuggestionCompletion];
}


#pragma mark CollectionViewDataSource


- (NSArray<ZaloActionView *> *)actionsForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZaloActionView *deleteAction = [[ZaloActionView alloc]initWithTitle:@"Delete" selector:@selector(deleteActionFromCell:)];
    ZaloActionView *muteAction = [[ZaloActionView alloc]initWithTitle:@"Mute" selector:@selector(muteActionFromCell:)];
    ZaloActionView *hideAction = [[ZaloActionView alloc]initWithTitle:@"Hide" selector:@selector(hideActionFromCell:)];
    return @[deleteAction,muteAction,hideAction];
}

#pragma mark subClass
// set models already alright in super

- (BOOL)canDeleteItemAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (BOOL)canEditItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.suggestionDataSource.models && pinSuggestion == indexPath.row) {
        return false;
    }
    return true;
}

- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView {
    [super registerReusableViewsWithCollectionView:collectionView];
    [collectionView registerClass:[ZaloMessengeCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ZaloMessengeCollectionViewCell class])];
    [collectionView registerClass:[ZaloSuggestionCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ZaloSuggestionCollectionViewCell class])];
}

- (NSString *)reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == pinSuggestion && self.suggestionDataSource.models)
        return NSStringFromClass([ZaloSuggestionCollectionViewCell class]);
    else
        return NSStringFromClass([ZaloMessengeCollectionViewCell class]);
}

- (void)reArrangeModels:(NSMutableArray*)models {
    if (self.suggestionDataSource && self.suggestionDataSource.models.count>0) {
        [models removeObject:self.suggestionDataSource];
        pinSuggestion = MIN(models.count, pinSuggestion);
        [models insertObject:self.suggestionDataSource atIndex:pinSuggestion];
    }
}

// update placeHolder : 
- (void)snapShotDataSourceToSection:(ZaloLayoutSection *)sectionInfo {
    if (self.placeHolder) {
        ZaloLayoutPlaceHolder *placeHolder = [[ZaloLayoutPlaceHolder alloc]init];
        placeHolder.sectionIndex = sectionInfo.sectionIndex;
        placeHolder.itemIndex = 0; // temporary put this
        
        [sectionInfo setPlaceholderInfo:placeHolder];
    } else {
        
    }
    
    [sectionInfo enumerateItemInfoWithCompletionBlock:^(ZaloLayoutCell*itemInfo, BOOL *stop){
        if (self.suggestionDataSource.models && itemInfo.itemIndex == pinSuggestion){
            itemInfo.isSuggestionCell = true;
        }
        
    }];
}

- (void)removeItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [super removeItemsAtIndexPaths:indexPaths]; // super just delete, move operation here
    
    id<ZaloDataSourceDelegate> delegate = self.delegate;
    if (![delegate respondsToSelector:@selector(dataSource:didMoveItemFromIndexPath:toIndexPath:)])
        return;
    
    NSMutableArray *models = [self.models mutableCopy];
    if ([self.models containsObject:self.suggestionDataSource]) { // containSuggestion
        NSInteger newPinSuggestion = MIN(models.count-1, pinSuggestion); // get newPinIndexPathAfterDelete
        [models removeObject:self.suggestionDataSource];
        [models insertObject:self.suggestionDataSource atIndex:newPinSuggestion];
        [super updateModels:[models copy]];
        
        [delegate dataSource:self didMoveItemFromIndexPath:[NSIndexPath indexPathForItem:pinSuggestion inSection:0] toIndexPath:[NSIndexPath indexPathForItem:newPinSuggestion inSection:0]];
        
        pinSuggestion = newPinSuggestion;
    }
    
}

@end
