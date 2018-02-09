//
//  ZaloDataSourceMapping.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/12/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloDataSourceMapping.h"


@interface ZaloDataSourceMapping()

@property (strong, nonatomic)NSMutableDictionary *localSectionsToGlobalSection,*globalSectionsToLocalSection;

@end

@implementation ZaloDataSourceMapping

- (instancetype)initWithDataSource:(ZaloDataSource*)dataSource startGlobalSection:(NSInteger)globalSection {
    self = [self initWithDataSource:dataSource];
    if (self) {
        self.dataSource = dataSource;
        self.localSectionsToGlobalSection = [NSMutableDictionary new];
        self.globalSectionsToLocalSection = [NSMutableDictionary new];
        
        [self updateMappingStartGlobalIndex:globalSection withBlock:^(NSInteger globalSection){        }];
    }
    return self;
}

- (instancetype)initWithDataSource:(ZaloDataSource *)dataSource {
    self = [super init];
    if (self) {
        self.dataSource = dataSource;
        self.localSectionsToGlobalSection = [NSMutableDictionary new];
        self.globalSectionsToLocalSection = [NSMutableDictionary new];
    }
    return self;
}

- (void)mapLocalSection:(NSInteger)localSection toGlobalSection:(NSInteger)globalSection {
    NSNumber *numLocal = @(localSection);
    NSNumber *numGlobal = @(globalSection);
    _localSectionsToGlobalSection[numLocal] = numGlobal;
    _globalSectionsToLocalSection[numGlobal] = numLocal; // this doesn't seem to be true
}

#pragma mark map indexPaths

- (NSIndexPath*)localIndexPathFromGlobalIndexPath:(NSIndexPath*)globalIndexPath {
    NSInteger localSection = [self.globalSectionsToLocalSection[@(globalIndexPath.section)] integerValue];
    if (localSection == NSNotFound)
        return nil;
    return [NSIndexPath indexPathForItem:globalIndexPath.item inSection:localSection];
}

- (NSArray<NSIndexPath*> *)localIndexPathsFromGlobalIndexPaths:(NSArray <NSIndexPath*>*)globalIndexPaths {
    NSMutableArray *localIndexPaths = [NSMutableArray new];
    for (NSIndexPath *globalIndexPath in globalIndexPaths) {
        NSIndexPath *localIndexPath = [self localIndexPathFromGlobalIndexPath:globalIndexPath];
        
        if (localIndexPath)
            [localIndexPaths addObject:localIndexPath];
    }
    return localIndexPaths;
}

- (NSIndexPath *)globalIndexPathFromLocalIndexPath:(NSIndexPath *)localIndexPath {
    NSInteger globalSection = [self.localSectionsToGlobalSection[@(localIndexPath.section)] integerValue];
    if (globalSection == NSNotFound)
        return nil;
    return [NSIndexPath indexPathForItem:localIndexPath.item inSection:globalSection];
}

- (NSArray<NSIndexPath*>*)globalIndexPathsFromLocalIndexPaths:(NSArray<NSIndexPath*>*)localIndexPaths {
    NSMutableArray *globalIndexPaths = [NSMutableArray array];
    for (NSIndexPath *localIndexPath in localIndexPaths) {
        NSIndexPath *globalIndexPath = [self globalIndexPathFromLocalIndexPath:localIndexPath];
        
        if (globalIndexPath!=nil)
            [globalIndexPaths addObject:globalIndexPath];
    }
    return globalIndexPaths;
}

- (NSInteger)globalSectionFromLocalSection:(NSInteger)localSection {
    NSNumber *numGlobal = _localSectionsToGlobalSection[@(localSection)];
    if (numGlobal) {
        return [numGlobal integerValue];
    } else
        return NSNotFound;
}

- (NSInteger)localSectionFromGlobalSection:(NSInteger)globalSection {
    NSNumber *numLocal = _globalSectionsToLocalSection[@(globalSection)];
    if (numLocal) {
        return [numLocal integerValue];
    } else
        return NSNotFound;
}

#pragma mark update

- (void)updateMappingStartGlobalIndex:(NSInteger)globalSection withBlock:(void(^)(NSInteger))block {
    _numberOfSections = self.dataSource.numberOfSections;
    
    [self.globalSectionsToLocalSection removeAllObjects];
    [self.localSectionsToGlobalSection removeAllObjects];
    for (NSInteger localSection =0; localSection<_numberOfSections; localSection++) {
        [self mapLocalSection:localSection toGlobalSection:globalSection];
         if (block) {
             block(globalSection++);
         }
    }
}

@end
