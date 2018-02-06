//
//  ZaloBasicDataSource.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/30/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloDataSource.h"

// the class inherit from ZaloDataSource for the collectionViewController with only section
// items will be loaded at datasource
// this is just a UIFrame work, so ..
// number of section 
@interface ZaloBasicDataSource : ZaloDataSource

// all the things like insertItemsAtIndexPath, remove .. put in to ZaloDataSource, not here because for example delete item at index path concerning composedDataSource

@property (copy, nonatomic) NSArray *models;
- (void)updateModels:(NSArray*)models;

@end
