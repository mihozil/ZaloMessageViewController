//
//  ZaloPlaceholderView.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/13/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZaloDataSource.h"

@interface ZaloPlaceholderView : UICollectionReusableView

@property (strong, nonatomic) ZaloDataSourcePlaceholder *model;

@end
