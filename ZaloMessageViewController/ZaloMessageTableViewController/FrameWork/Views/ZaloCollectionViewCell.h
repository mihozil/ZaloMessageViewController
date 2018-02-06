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

@property (strong, nonatomic)NSArray*editingActions;
@property (strong, nonatomic)dispatch_block_t removedAction;
@property (strong, nonatomic)id model;
@property (assign, nonatomic)BOOL toDeleteSelected;

// the swipe controller told to move ...
// the cell
- (void)panDidBegin:(CGPoint)position; // just to show the actionviews
- (void)panDidChange:(CGPoint)position;// move and update cellView
- (void)panDidEnd:(CGPoint)position velocity:(CGPoint)velocity; // to hide actionViews<if close>

- (void)handleAction:(SEL)selector;
- (void)shutActionPane;


@end
