//
//  ZaloComposedDataSource.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/8/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloDataSource.h"

@interface ZaloComposedDataSource : ZaloDataSource<ZaloDataSourceDelegate>

- (void)addDataSource:(ZaloDataSource*)dataSource;

@end
