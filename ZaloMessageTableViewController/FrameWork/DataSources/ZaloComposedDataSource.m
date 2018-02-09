//
//  ZaloComposedDataSource.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/8/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloComposedDataSource.h"
#import "ZaloDataSourceMapping.h"

@interface ZaloComposedDataSource()<ZaloDataSourceDelegate>

@property (strong, nonatomic) NSMutableArray *dataSources;

@property (strong, nonatomic) NSMapTable *dataSourceToMapping;
@property (strong, nonatomic) NSMutableArray *mappings;
@property (strong, nonatomic) NSMutableDictionary *globalSectionsToMappings;

@end

@implementation ZaloComposedDataSource {
    NSInteger _numberOfSections;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataSourceToMapping = [[NSMapTable alloc]initWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableStrongMemory capacity:1];
        _mappings = [NSMutableArray new];
        _globalSectionsToMappings = [NSMutableDictionary new];
        
    }
    return self;
}

- (NSMutableArray *)dataSources {
    if (_dataSources)
        return _dataSources;
    _dataSources = [NSMutableArray array];
    return _dataSources;
}

- (void)addDataSource:(ZaloDataSource *)dataSource {
    
    ZaloDataSourceMapping *map = [[ZaloDataSourceMapping alloc]initWithDataSource:dataSource];
    [self.mappings addObject:map];
    [_dataSourceToMapping setObject:map forKey:dataSource];
    [self updateMappings];
    
    dataSource.delegate = self;
    [self.dataSources addObject:dataSource];
    
    NSMutableIndexSet *addededSections = [NSMutableIndexSet new];
    for (NSInteger localSection = 0; localSection<map.numberOfSections; localSection++) {
        NSInteger globalSection = [map globalSectionFromLocalSection:localSection];
        [addededSections addIndex:globalSection];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataSource:didInsertSections:)]) {
        [self.delegate dataSource:self didInsertSections:addededSections];
    }
}

//note: addRemoveDataSource

#pragma mark load

- (void)loadContentWithProgress:(ZaloLoadingProgress *)progress {
    // firstly, loadcontentOfChildDataSource
    [self.dataSources enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL*stop){
        ZaloDataSource *dataSource = (ZaloDataSource*)object;
        if (![object isKindOfClass:[ZaloDataSource class]])
            return;
        
        [dataSource loadContent];
    }];
    // load neccessary content of composedDataSource. or in just case, just done and will move to endLoadContent
    [progress done];
}

- (void)endLoadContentWithState:(NSString *)state error:(NSError *)error block:(ZaloUpdateBlock)block {
    // this means if the subClass of composedDataSource return Error or noContent -> return no matter what the child dataSource returns
    
    if (state == ZaloLoadingStateError || state == ZaloLoadingStateNoContent) {
        self.loadingState = state;
        return;
    }
    
    // it means that the datasource's loadingState should beLoaded
    NSAssert(state == ZaloLoadingStateLoaded, @"state should be loaded");
    
    // wait for all the dataSource to done loading
    __block dispatch_group_t groupLoading = dispatch_group_create();
    
    NSArray *dataSources = [self.dataSources mutableCopy];
    
    for (ZaloDataSource *dataSource in dataSources) {
        
        if (dataSource.loadingState != ZaloLoadingStateLoading && dataSource.loadingState != ZaloLoadingStateRefreshing) {
            continue;
        };
        
        dispatch_group_enter(groupLoading);
        
        [dataSource whenLoaded:^{
            
            dispatch_group_leave(groupLoading);
        }];
    }
    
    
    dispatch_group_notify(groupLoading, dispatch_get_main_queue(), ^{
        NSLog(@"notify");
        NSMutableSet *loadingStateSet = [NSMutableSet new];
        for (ZaloDataSource *dataSource in dataSources) {
            [loadingStateSet addObject:dataSource.loadingState];
        }
        
        NSString *finalState = state;
        
        if (loadingStateSet.count == 1 &&
            [loadingStateSet.anyObject isEqualToString: ZaloLoadingStateNoContent]) {
            finalState = ZaloLoadingStateNoContent;
        }
        
        [super endLoadContentWithState:finalState error:error block:block];
        
    });
    
}


#pragma mark dataSourceDelegate
- (void)dataSource:(ZaloDataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    ZaloDataSourceMapping *mapping = [self.dataSourceToMapping objectForKey:dataSource];
    NSIndexPath *globalFromIndexPath = [mapping globalIndexPathFromLocalIndexPath:fromIndexPath];
    NSIndexPath *globalToIndexPath = [mapping globalIndexPathFromLocalIndexPath:toIndexPath];
    
    if ([self.delegate respondsToSelector:@selector(dataSource:didMoveItemFromIndexPath:toIndexPath:)]
        && globalToIndexPath && globalFromIndexPath) {
        [self.delegate dataSource:self didMoveItemFromIndexPath:globalFromIndexPath toIndexPath:globalToIndexPath];
    }
}

- (void)dataSource:(ZaloDataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths {
    
    ZaloDataSourceMapping *mapping = [self.dataSourceToMapping objectForKey:dataSource];
    NSArray *globalIndexPaths = [mapping globalIndexPathsFromLocalIndexPaths:indexPaths];
    
    if ([self.delegate respondsToSelector:@selector(dataSource:didRemoveItemsAtIndexPaths:)]
        && globalIndexPaths.count>0) {
        
        [self.delegate dataSource:self didRemoveItemsAtIndexPaths:globalIndexPaths];
    }
}

- (void)dataSource:(ZaloDataSource *)dataSource perFormBatchUpdate:(dispatch_block_t)update completion:(dispatch_block_t)completion{
    
    [self performUpdate:update completion:completion];
}

- (void)dataSource:(ZaloDataSource *)dataSource didShowActivityIndicatorAtSections:(NSIndexSet *)sections {
    id<ZaloDataSourceDelegate>delegate = self.delegate;
    if (!delegate || ![delegate respondsToSelector:@selector(dataSource:didShowActivityIndicatorAtSections:)])
        return;
    
    ZaloDataSourceMapping *map = [_dataSourceToMapping objectForKey:dataSource];
    NSMutableIndexSet *globalSections = [NSMutableIndexSet new];
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop){
        NSInteger globalSection = [map globalSectionFromLocalSection:section];
        [globalSections addIndex:globalSection];
    }];
    
    [delegate dataSource:self didShowActivityIndicatorAtSections:globalSections];
}

- (void)dataSource:(ZaloDataSource *)dataSource notifyDidLoadContentWithError:(NSError *)error {
    
}

- (void)dataSource:(ZaloDataSource *)dataSource didInsertSections:(NSIndexSet *)sections {
    
    ZaloDataSourceMapping *map = [_dataSourceToMapping objectForKey:dataSource];
    NSMutableIndexSet *globalSections = [NSMutableIndexSet new];
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop){
        NSInteger globalSection = [map globalSectionFromLocalSection:section];
        [globalSections addIndex:globalSection];
    }];
    
    if ([self.delegate respondsToSelector:@selector(dataSource:didInsertSections:)]
        && globalSections.count>0) {
        [self.delegate dataSource:self didInsertSections:globalSections];
    }
    
    [self updateMappings];
    
}

- (void)dataSource:(ZaloDataSource *)dataSource didRefreshSections:(NSIndexSet *)sections { //
    
    ZaloDataSourceMapping *map  = [_dataSourceToMapping objectForKey:dataSource]; // just dataSource -> need table
    NSMutableIndexSet *globalSections = [NSMutableIndexSet new];
    [sections enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
        NSInteger globalSection = [map globalSectionFromLocalSection:index];
        [globalSections addIndex:globalSection];
    }];
    
    if ([self.delegate respondsToSelector:@selector(dataSource:didRefreshSections:)]
        && globalSections.count>0) {
        [self.delegate dataSource:self didRefreshSections:globalSections];
    }
    
    [self updateMappings];
}

#pragma mark collectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    [self updateMappings];
    
    ZaloDataSourceMapping *mapping = [self.globalSectionsToMappings objectForKey:@(section)];
    ZaloDataSource *childDataSource = mapping.dataSource;
    NSInteger localSection = [mapping localSectionFromGlobalSection:section];
    
    return [childDataSource collectionView:collectionView numberOfItemsInSection:localSection];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZaloDataSourceMapping *mapping = [self.globalSectionsToMappings objectForKey:@(indexPath.section)];
    ZaloDataSource *childDataSource = mapping.dataSource;
    NSIndexPath *localIndexPath = [mapping localIndexPathFromGlobalIndexPath:indexPath];
    
    return [childDataSource collectionView:collectionView cellForItemAtIndexPath:localIndexPath];
}

#pragma mark helper
- (void)updateMappings {
    _numberOfSections = 0;
    
    for (ZaloDataSourceMapping *mapping in self.mappings) { // globalIndex to localIndex for mapping and vice verse
        [mapping updateMappingStartGlobalIndex:_numberOfSections withBlock:^(NSInteger globalSection){
            self.globalSectionsToMappings[@(globalSection)] = mapping;
        }];
        _numberOfSections += mapping.numberOfSections;
    }
}

#pragma mark dataSourceAPI
- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView {
    
    [super registerReusableViewsWithCollectionView:collectionView];
    [self.dataSources enumerateObjectsUsingBlock:^(ZaloDataSource*dataSource, NSUInteger idx, BOOL*stop){
        [dataSource registerReusableViewsWithCollectionView:collectionView];
    }];
    
}

- (BOOL)canEditItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZaloDataSourceMapping *mapping = [_globalSectionsToMappings objectForKey:@(indexPath.section)];
    ZaloDataSource *dataSource = mapping.dataSource;
    NSIndexPath *localIndexPath = [mapping localIndexPathFromGlobalIndexPath:indexPath];
    
    return [dataSource canEditItemAtIndexPath:localIndexPath];
}

- (BOOL)canDeleteItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZaloDataSourceMapping *mapping = [_globalSectionsToMappings objectForKey:@(indexPath.section)];
    ZaloDataSource *dataSource = mapping.dataSource;
    NSIndexPath *localIndexPath = [mapping localIndexPathFromGlobalIndexPath:indexPath];
    
    return [dataSource canDeleteItemAtIndexPath:localIndexPath];
}

- (NSArray<ZaloActionView *> *)actionsForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZaloDataSourceMapping *mapping = [self.globalSectionsToMappings objectForKey:@(indexPath.row)];
    ZaloDataSource *childDataSource = mapping.dataSource;
    NSIndexPath *localIndexPath = [mapping localIndexPathFromGlobalIndexPath:indexPath];
    
    return [childDataSource actionsForItemAtIndexPath:localIndexPath];
}

- (ZaloDataSource *)dataSourceForSectionAtIndex:(NSInteger)sectionIndex {
    ZaloDataSourceMapping *mapping = self.globalSectionsToMappings[@(sectionIndex)];
    
    return mapping.dataSource;
}

#pragma mark sectionInfo
- (NSInteger)numberOfSections {
    [self updateMappings];
    return _numberOfSections;
}

- (ZaloLayoutSection *)snapShotSectionInfoAtIndex:(NSInteger)sectionIndex {
    ZaloDataSourceMapping *mapping = _globalSectionsToMappings[@(sectionIndex)];
    ZaloDataSource *childDataSource = mapping.dataSource;
    NSInteger localSection = [mapping localSectionFromGlobalSection:sectionIndex];
    ZaloLayoutSection *childSectionInfo = [childDataSource snapShotSectionInfoAtIndex:localSection];
    
    ZaloLayoutSection *enclosingSectionInfo = [super snapShotSectionInfoAtIndex:sectionIndex];
    [enclosingSectionInfo applyInformationFromSection:childSectionInfo];
    
    return enclosingSectionInfo;
    
}

- (void)findSupplementaryItemAtIndexPath:(NSIndexPath *)indexPath withBlock:(void (^)(ZaloLayoutSupplementaryItem *, ZaloDataSource *, NSIndexPath *))block {
    NSInteger numberOfHeaders = [self numberOfHeadersForSectionAtIndex:indexPath.section includeChildDataSource:NO];
    NSInteger itemIndex = indexPath.item;
    
    if (indexPath.section == 0) {
        if (indexPath.item<numberOfHeaders) {
            [super findSupplementaryItemAtIndexPath:indexPath withBlock:block];
            return;
        } else {
            itemIndex-=numberOfHeaders;
        }
    }
    
    NSIndexPath *globalIndexPath = [NSIndexPath indexPathForItem:itemIndex inSection:indexPath.section];
    ZaloDataSourceMapping *mapping = self.globalSectionsToMappings[@(globalIndexPath.section)];
    ZaloDataSource *dataSource = mapping.dataSource;
    NSIndexPath *localIndexPath = [mapping localIndexPathFromGlobalIndexPath:globalIndexPath];
    [dataSource findSupplementaryItemAtIndexPath:localIndexPath withBlock:block];
    
}
#pragma mark update
// viewForSupplementary later
- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
    ZaloDataSourceMapping *mapping = [self.globalSectionsToMappings objectForKey:@(indexPath.section)];
    ZaloDataSource *childDataSource = mapping.dataSource;
    NSIndexPath *localIndexPath = [mapping localIndexPathFromGlobalIndexPath:indexPath];
    
    [childDataSource removeItemAtIndexPath:localIndexPath];
}

- (void)removeItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSMutableDictionary *sectionToRemovedIndexPaths = [NSMutableDictionary new];
    for (NSIndexPath *indexPath in indexPaths) {
        NSInteger section = indexPath.section;
        NSMutableArray *toRemoveIndexPaths = sectionToRemovedIndexPaths[@(section)];
        if (!toRemoveIndexPaths)
            toRemoveIndexPaths = [NSMutableArray new];
        if (![toRemoveIndexPaths containsObject:indexPath]) {
            [toRemoveIndexPaths addObject:indexPath];
        }
        [sectionToRemovedIndexPaths setObject:toRemoveIndexPaths forKey:@(section)];
    }
    
    for (NSNumber *section in sectionToRemovedIndexPaths.allKeys) {
        ZaloDataSourceMapping *mapping = [self.globalSectionsToMappings objectForKey:section];
        ZaloDataSource *childDataSource = mapping.dataSource;
        NSMutableArray *toRemoveIndexPaths = sectionToRemovedIndexPaths[section];
        if (!toRemoveIndexPaths) {
            continue;
        }
        
        NSMutableArray *localIndexPaths = [NSMutableArray new];
        for (NSIndexPath *indexPath in toRemoveIndexPaths) {
            NSIndexPath *localIndexPath = [mapping localIndexPathFromGlobalIndexPath:indexPath];
            [localIndexPaths addObject:localIndexPath];
        }
        [childDataSource removeItemsAtIndexPaths:localIndexPaths];
    }
}

@end
