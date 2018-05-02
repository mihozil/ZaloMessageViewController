//
//  ZaloDataSource.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/25/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloDataSource.h"
#import "ZaloLoadingProgress.h"
#import "ZaloCollectionViewLayout_Internal.h"
#import "ZaloPlaceholderView.h"
#import "ZaloSectionHeaderView.h"

NSString *const ZaloDataSourceTitleHeaderKey = @"ZaloDataSourceTitleHeaderKey";

@interface ZaloDataSourcePlaceholder()

+(instancetype)placeholderWithActivityIndicator;
@end


@interface ZaloDataSource() < ZaloStateMachineDelegate>

@property (strong, nonatomic)ZaloLoadingStateMachine *stateMachine;
@property (strong, nonatomic) ZaloDataSourcePlaceholder *placeHolder;
@property (strong, nonatomic) NSMutableArray *headers; 

@end

@implementation ZaloDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        self.collectionSuggetionIndex = -1;// default
    }
    return self;
}

#pragma mark loadContent
// temporary: the composedDataSource will be handle later

// note: should have setNeedLayoutContent to cancel unneccessary loadcontent

- (void)loadContent {
    // completion block
    NSString *loadingState = self.loadingState;
    self.loadingState = (loadingState == ZaloLoadingStateInitial || loadingState == ZaloLoadingStateLoading) ? ZaloLoadingStateLoading : ZaloLoadingStateRefreshing;
    
    ZaloLoadingProgress *loadingProgress = [ZaloLoadingProgress initializeLoadingProcessWithCompletionHandle:^(NSString *state, NSError*error, ZaloUpdateBlock block){
        
        [self endLoadContentWithState:state error:error block:block];
        
    }]; // completionBlock
    
    [self loadContentWithProgress:loadingProgress];
    
}

// subclass
- (void)loadContentWithProgress:(ZaloLoadingProgress*)progress {
    [progress done];
}

- (void)endLoadContentWithState:(NSString*)state error:(NSError*)error block:(ZaloUpdateBlock)block {
    self.loadingState = state;
    if (error)
        self.loadingError = error;
    
    dispatch_block_t pendingUpdate = self.pendingUpdateBlock;
    self.pendingUpdateBlock = nil;
    
    dispatch_block_t blockUpdate;
    blockUpdate = ^{
        if (pendingUpdate)
            pendingUpdate();
        
        if (block)
            block(self);
    };

    [self performUpdate:blockUpdate completion:nil];
    
    [self notifyEndLoadingWithError:error];
}

- (NSString *)loadingState {
    if (!_stateMachine) {
        return ZaloLoadingStateInitial;
    } else return _stateMachine.currentState;
}

- (void)setLoadingState:(NSString *)loadingState {
    ZaloLoadingStateMachine *stateMachine = self.stateMachine;
    if (stateMachine.currentState!=loadingState) {
        stateMachine.currentState = loadingState;
    }
}

- (void)didEnterLoadingState {
    [self presentActivityIndicatorForSections:nil];
}

- (void)didExitLoadingState {
    [self dismissPlaceHolderForSections:nil];
}

- (void)didEnterLoadedState {
    
}

- (void)didEnterErrorState {
    if (self.loadErrorPlaceholder)
        [self presentPlaceHolder:self.loadErrorPlaceholder forSection:nil];
    
}

- (void)didExitErrorState {
    if (self.loadErrorPlaceholder)
        [self dismissPlaceHolderForSections:nil];
}

- (void)didEnterNoContentState {
    if (self.noContentPlaceholder)
        [self presentPlaceHolder:self.noContentPlaceholder forSection:nil];
}

- (void)didExitNoContentState {
    if (self.noContentPlaceholder)
        [self dismissPlaceHolderForSections:nil];
}

#pragma mark update

- (void)performUpdate:(dispatch_block_t)blockUpdate completion:(dispatch_block_t)completion{
    
    if ([self.loadingState isEqualToString:ZaloLoadingStateLoading] || [self.loadingState isEqualToString:ZaloLoadingStateRefreshing]) {
        __weak ZaloDataSource *weakSelf = self;
        [self enqueueBlock:^{
            [weakSelf performUpdate:blockUpdate completion:completion];
        }];
        return;
    }
    
    [self performInternalUpdate:blockUpdate completion:completion];
}


- (void)enqueueBlock:(dispatch_block_t)blockUpdate {
    dispatch_block_t oldPendingBlock = self.pendingUpdateBlock;
    self.pendingUpdateBlock = ^{
        if (oldPendingBlock)
            oldPendingBlock();
        if (blockUpdate)
            blockUpdate();
    };
}

// note: remember to add enqueue
- (void)performInternalUpdate:(dispatch_block_t)blockUpdate completion:(dispatch_block_t)completion{
    id<ZaloDataSourceDelegate>delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(dataSource:perFormBatchUpdate:completion:)]) {
        [delegate dataSource:self perFormBatchUpdate:blockUpdate completion:completion];
    } else {
        if (blockUpdate)
            blockUpdate();
        if (completion)
            completion();
    }
}

- (void)notifyEndLoadingWithError:(NSError*)error {
    dispatch_block_t loadingCompletionBlock = self.loadingCompletionBlock;
    self.loadingCompletionBlock = nil;
    if (loadingCompletionBlock)
        loadingCompletionBlock();
    
    if ([self.delegate respondsToSelector:@selector(dataSource:notifyDidLoadContentWithError:)])
        [self.delegate dataSource:self notifyDidLoadContentWithError:error];
}

- (void)whenLoaded:(dispatch_block_t)block {
    dispatch_block_t oldCompletionBlock = self.loadingCompletionBlock;
    self.loadingCompletionBlock = ^{ // when loadingCompletionBlock trigger, block trigger
        if (oldCompletionBlock)
            oldCompletionBlock();
        
        if (block)
            block();
    };
}

#pragma mark dataSourceAPI
- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView {
    // placeholder
    [collectionView registerClass:[ZaloPlaceholderView class] forSupplementaryViewOfKind:ZaloCollectionElementKindPlaceHolder withReuseIdentifier:NSStringFromClass([ZaloPlaceholderView class])];
    
    for (ZaloLayoutSupplementaryItem *item in self.headers) {
        
        [collectionView registerClass:item.supplementaryViewClass forSupplementaryViewOfKind:item.elementKind withReuseIdentifier:NSStringFromClass(item.supplementaryViewClass)];
    }
}

- (NSArray<ZaloActionsView*> *)actionsForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

- (BOOL)canEditItemAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (BOOL)canDeleteItemAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (ZaloDataSource *)dataSourceForSectionAtIndex:(NSInteger)sectionIndex {
    return self;
}

#pragma mark zaloSectionInfo
- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfHeadersForSectionAtIndex:(NSInteger)index includeChildDataSource:(BOOL)includeChildDataSource {
    NSInteger numberOfHeaders = _headers.count;
    if (includeChildDataSource) {
        
    }
    return numberOfHeaders;
}

- (void)presentActivityIndicatorForSections:(NSIndexSet*)sections {
    if (!sections)
        sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)];
    
    ZaloDataSourcePlaceholder *placeHolder = [ZaloDataSourcePlaceholder placeholderWithActivityIndicator];
    dispatch_block_t block = ^{
        
        self.placeHolder = placeHolder;
        
        if ([self.delegate respondsToSelector:@selector(dataSource:didShowActivityIndicatorAtSections:)]) {
            [self.delegate dataSource:self didShowActivityIndicatorAtSections:sections];
        }
    };
    
    [self performInternalUpdate:block completion:nil];
}


- (void)presentPlaceHolder:(ZaloDataSourcePlaceholder*)placeHolder forSection:(NSIndexSet*)sections{
    
    if (!sections)
        sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)];
    
    dispatch_block_t block = ^{
        self.placeHolder = placeHolder;
        
        if ([self.delegate respondsToSelector:@selector(dataSource:didRefreshSections:)])
            [self.delegate dataSource:self didRefreshSections:sections];
    };
    
    [self performUpdate:block completion:nil];
}

- (void)dismissPlaceHolderForSections:(NSIndexSet*)sections {
    
    if (!sections) {
        sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)];
    }
    
    dispatch_block_t blockUpdate = ^{
        self.placeHolder = nil;
        
        if ([self.delegate respondsToSelector:@selector(dataSource:didRefreshSections:)]) {
            [self.delegate dataSource:self didRefreshSections:sections];
        }
    };
    [self performUpdate:blockUpdate completion:nil];
}

- (ZaloLayoutSection *)snapShotSectionInfoAtIndex:(NSInteger)sectionIndex {
    ZaloLayoutSection *sectionInfo = [[ZaloLayoutSection alloc]init];
    // header
    if (sectionIndex == 0) {
        if (self.headers.count>0)
            [self.headers enumerateObjectsUsingBlock:^(ZaloLayoutSupplementaryItem*header, NSUInteger idx, BOOL *stop){
                [sectionInfo addNewHeaderFromHeader:header];
            }];
    }
    
    // placeholder
    if (self.placeHolder)
        sectionInfo.placeHolder = self.placeHolder;
    
    // items
    sectionInfo.collectionSuggestionIndex = self.collectionSuggetionIndex;
    
    return sectionInfo;
}

- (ZaloLayoutSupplementaryItem *)newHeaderForKey:(NSString *)key { // key temporary not to use
    ZaloLayoutSupplementaryItem *header = [[ZaloLayoutSupplementaryItem alloc]init];
    header.elementKind = ZaloCollectionElementKindHeader;
    
    if (!self.headers)
        self.headers = [NSMutableArray array];
    [self.headers addObject:header];
    return header;
}

- (void) findSupplementaryItemAtIndexPath:(NSIndexPath*)indexPath withBlock:(void(^)(ZaloLayoutSupplementaryItem *, ZaloDataSource *, NSIndexPath *localIndexPath)) block {
    
    NSInteger numberOfHeaders = self.headers.count;
    
    if (indexPath.section == 0) {
        if (indexPath.item<numberOfHeaders) { // the header taken is from right this dataSource
            if (block)
                block(self.headers[indexPath.item],self,indexPath);
        }
    }
    
    
};

#pragma mark collectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    // temporary just see only placeholder
    if ([kind isEqualToString:ZaloCollectionElementKindPlaceHolder]) {
        ZaloDataSourcePlaceholder *dataSourcePlaceholder = self.placeHolder;
        ZaloPlaceholderView *placeHolderView = (ZaloPlaceholderView*)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([ZaloPlaceholderView class]) forIndexPath:indexPath];
        
        [placeHolderView setModel:dataSourcePlaceholder];
        return placeHolderView;
    }
    
    if ([kind isEqualToString:ZaloCollectionElementKindHeader]) {
        
        __block ZaloLayoutSupplementaryItem *foundHeader;
        __block ZaloDataSource *foundDataSource;
        __block NSIndexPath *foundIndexPath;
        
        [self findSupplementaryItemAtIndexPath:indexPath withBlock:^(ZaloLayoutSupplementaryItem *item, ZaloDataSource*dataSource, NSIndexPath *localIndexPath){
            
            foundHeader = item;
            foundDataSource = dataSource;
            foundIndexPath = localIndexPath;
        }];
        
        
        ZaloSectionHeaderView *headerView = (ZaloSectionHeaderView*)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([ZaloSectionHeaderView class]) forIndexPath:indexPath];
        if (foundHeader.configureView)
            foundHeader.configureView(headerView, foundDataSource, foundIndexPath);
        
        return headerView;
    }
    
    return nil;
}


#pragma mark stateMachine

- (ZaloLoadingStateMachine *)stateMachine {
    if (_stateMachine)
        return _stateMachine;
    _stateMachine = [[ZaloLoadingStateMachine alloc]init];
    _stateMachine.delegate = self;
    return _stateMachine;
}

- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState {
    // reset content
    // but at the moment i haven't implement the reseting content
    if (_resetingContent && [toState isEqualToString:ZaloLoadingStateInitial]) {
        return toState;
    }
    return nil;
}

@end

@implementation ZaloDataSourcePlaceholder

- (instancetype)initWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image activityIndicator:(BOOL)showActivityIndicator {
    self = [super init];
    if (self) {
        self.title = title;
        self.message = message;
        self.image = image;
        self.showActivityIndicator = showActivityIndicator;
    }
    return self;
}

+ (instancetype)placeholderWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)image {
    return [[self alloc]initWithTitle:title message:message image:image activityIndicator:false];
}

+ (instancetype)placeholderWithActivityIndicator {
    return [[self alloc] initWithTitle:nil message:nil image:nil activityIndicator:true];
}

@end
