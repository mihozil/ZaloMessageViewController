//
//  ZaloCollectionViewController.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/25/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZaloCollectionViewCell.h"

// the collectionViewController in support of swipe, long gesture
// swipe down to open chat 
@interface ZaloCollectionViewController : UICollectionViewController <ZaloDataSourceDelegate>

@property (assign, nonatomic)BOOL editing;

- (void)deleteActionFromCell:(ZaloCollectionViewCell*)cell;
- (void)muteActionFromCell:(ZaloCollectionViewCell*)cell;
- (void)hideActionFromCell:(ZaloCollectionViewCell*)cell;
- (void)didSelectRemoveButtonFromCell:(ZaloCollectionViewCell*)cell;

@end

// ZaloDatasource <for collectionView>
// ZaloComposedDataSource
// ZaloCollectionViewLayout

// ZaloMessegeCollectionViewController inherited from ZaloCollectionViewController
// ZaloMessegeDataSource: inherit from ZaloComposedDataSource <friendRequest & ..>


