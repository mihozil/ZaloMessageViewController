//
//  ZaloCollectionViewLayout.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/26/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import <UIKit/UIKit.h>


// the custom layout for managing layout for collectionView
@interface ZaloCollectionViewLayout : UICollectionViewLayout

@property (assign, nonatomic) BOOL editing;
- (BOOL)canEditItemAtIndexPath:(NSIndexPath*)indexPath;

@end
