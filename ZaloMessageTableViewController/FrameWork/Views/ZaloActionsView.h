//
//  ZaloActionsView.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/26/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import <UIKit/UIKit.h>
#define MAS_SHORTHAND
#import "Masonry.h"

#define kMuteAction @"ZaloActionMute"
#define kDeleteAction @"ZaloDeleteAction"
#define kHideAction @"ZaloHideAction"
#define kBlockAction @"ZaloBlockAction"
#define actionsViewWidth 200

@class ZaloCollectionViewCell;

@interface ZaloActionView : UIView

@property (strong, nonatomic) UIColor *backgroundColor, *textColor;
@property (strong, nonatomic) NSString *title;
@property (nonatomic) SEL selector;
@property (strong, nonatomic) UIButton *button;

- (instancetype)initWithTitle:(NSString*)title selector:(SEL)selector;
@end

// the actionView shown when swipe collectionViewCell
@interface ZaloActionsView : UIView

@property (strong, nonatomic)NSArray<ZaloActionView*> *editingActions;
@property (weak, nonatomic) ZaloCollectionViewCell *cell;

@end
