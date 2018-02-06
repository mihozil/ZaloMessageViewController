//
//  ZaloDataSourceMapping.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/12/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZaloDataSource.h"

// mapping local sections to global Sections
@interface ZaloDataSourceMapping : NSObject

@property (strong, nonatomic)ZaloDataSource *dataSource;
@property (readonly, nonatomic)NSInteger numberOfSections;

- (NSInteger)globalSectionFromLocalSection:(NSInteger)localSection;
- (NSInteger)localSectionFromGlobalSection:(NSInteger)globalSection;

- (NSIndexPath*)localIndexPathFromGlobalIndexPath:(NSIndexPath*)globalIndexPath;
- (NSArray<NSIndexPath*>*)localIndexPathsFromGlobalIndexPaths:(NSArray<NSIndexPath*>*)globalIndexPaths;

- (NSIndexPath*)globalIndexPathFromLocalIndexPath:(NSIndexPath*)localIndexPath;
- (NSArray<NSIndexPath*>*)globalIndexPathsFromLocalIndexPaths:(NSArray<NSIndexPath*>*)localIndexPaths;

- (instancetype)initWithDataSource:(ZaloDataSource*)dataSource startGlobalSection:(NSInteger)globalSection;
- (instancetype)initWithDataSource:(ZaloDataSource*)dataSource;

- (void)updateMappingStartGlobalIndex:(NSInteger)globalSection withBlock:(void(^)(NSInteger globalSection))block;

@end
