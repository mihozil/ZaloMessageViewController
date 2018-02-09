//
//  ZaloCollectionViewCell.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/26/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZaloActionsView.h"
#import "ZaloDataSource.h"

#define zaloCollectionViewCellId @"ZaloCollectionViewCell"
// the collectionViewCell supporting swipe, long gesture
@interface ZaloCollectionViewCell : UICollectionViewCell

#pragma mark swipe
- (void)panDidBegin:(CGPoint)position; 
- (void)panDidChange:(CGPoint)position;
- (void)panDidEnd:(CGPoint)position velocity:(CGPoint)velocity;

#pragma mark public
@property (strong, nonatomic)NSArray*editingActions;
@property (strong, nonatomic)dispatch_block_t removedAction;
@property (strong, nonatomic)id model;
@property (assign, nonatomic)BOOL toDeleteSelected;
- (void)handleAction:(SEL)selector;
- (void)shutActionPane;
@end
