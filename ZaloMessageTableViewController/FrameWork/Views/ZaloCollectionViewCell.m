//
//  ZaloCollectionViewCell.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/26/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloCollectionViewCell.h"
#import "ZaloActionsView.h"
#import "ZaloMessageFoundations.h"
#import "ZaloCollectionViewLayoutAttributes.h"
#import "ZaloCollectionViewController.h"

@interface ZaloCollectionViewCell ()

@property (strong, nonatomic) UIView* privateContentView;
@property (strong, nonatomic) ZaloActionsView *actionsView; // underContainerView

@property (strong, nonatomic) UIButton *removedButton;
@property (assign, nonatomic) BOOL editing;

@end

@implementation ZaloCollectionViewCell {
    CGPoint _previousPanPoint;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self= [super initWithFrame:frame];
    if (self) {
        [self setUpZaloCollectionViewCell];
    }
    return self;
}

#pragma mark UIcollectionViewCellAPI

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    
    if ([layoutAttributes isKindOfClass:[ZaloCollectionViewLayoutAttributes class]]) {
        
        ZaloCollectionViewLayoutAttributes *attributes = (ZaloCollectionViewLayoutAttributes*)layoutAttributes;
        
        if (_editing!=attributes.editing) {
            // resetlayout: set removeButton's image to initial
            [_removedButton setImage:[UIImage imageNamed:@"cellRemoveUnSelected"] forState:UIControlStateNormal];
            
            _editing = attributes.editing;
            if (attributes.editing) {
                [self showEditingControl];
            } else {
                [self hideEditingControl];
            }
        }
    } else {
//        NSAssert(NO, @"applyLayoutAttributes: doesn't come here");
    }
}

#pragma mark helpers

- (void)showEditingControl { // animation
    UIView *contentView = [super contentView];
    
    [_removedButton remakeConstraints:^(MASConstraintMaker*make){
        make.top.equalTo(@12);
        make.left.equalTo(@0);
        make.bottom.equalTo(@-12);
        make.height.equalTo(_removedButton.width);
    }];
    [_removedButton addTarget:self action:@selector(handleRemovedButton) forControlEvents:UIControlEventTouchDown];
    [_privateContentView remakeConstraints:^(MASConstraintMaker*make){
        make.top.and.bottom.and.right.equalTo(@0);
        make.left.equalTo(_removedButton.right).with.offset(0).with.priority(999);
    }];
    [UIView animateWithDuration:0.1 animations:^{
        [contentView layoutIfNeeded];
    }];
}

- (void)hideEditingControl {
    UIView *contentView = [super contentView];
    
    [_removedButton remakeConstraints:^(MASConstraintMaker*make){
        make.top.equalTo(@12);
        make.bottom.equalTo(@-12);
        make.right.equalTo(contentView.left).with.offset(0);
        make.height.equalTo(_removedButton.width);
    }];
    
    [_privateContentView remakeConstraints:^(MASConstraintMaker*make){
        make.top.and.bottom.right.and.left.equalTo(@0);
    }];
    [UIView animateWithDuration:0.1 animations:^{
        [contentView layoutIfNeeded];
    }];
}

- (void)setUpZaloCollectionViewCell {
    UIView *superContentView = [super contentView];
    superContentView.clipsToBounds = true;
    
    _removedButton = [[UIButton alloc]init];
    [_removedButton setImage:[UIImage imageNamed:@"cellRemoveUnSelected"] forState:UIControlStateNormal];
    [_removedButton addTarget:self action:@selector(didSelectRemovedButton) forControlEvents:UIControlEventTouchDown];
    [superContentView addSubview:_removedButton];
    [_removedButton makeConstraints:^(MASConstraintMaker*make){
        make.top.equalTo(@12);
        make.bottom.equalTo(@-12);
        make.right.equalTo(superContentView.left).with.offset(0);
        make.width.equalTo(_removedButton.height);
    }];
    
    _privateContentView = [[UIView alloc]initWithFrame:superContentView.frame];
    _privateContentView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    [superContentView addSubview:_privateContentView];
    [_privateContentView makeConstraints:^(MASConstraintMaker *make){
        make.right.and.top.and.bottom.and.left.equalTo(@0);
    }];
    
    // initActionView here. suppose every cell has a actionView
    _actionsView = [[ZaloActionsView alloc]init];
    _actionsView.cell = self;
    [superContentView insertSubview:_actionsView belowSubview:_privateContentView];
    [_actionsView makeConstraints:^(MASConstraintMaker*make){
        make.top.and.bottom.and.right.equalTo(@0);
        make.width.equalTo(@(actionsViewWidth));
    }];
}

- (UIView *)contentView {
    return _privateContentView;
}

#pragma mark actions

- (void)handleRemovedButton {
    if (self.removedAction) {
        self.removedAction();
    }
}

- (void)handleAction:(SEL)selector {
    id sender = self;
    id target = sender;
    
    while (target && ![target canPerformAction:selector withSender:sender]) {
        target = [target nextResponder];
    }
    
    if (!target)
        return;
    
    [[UIApplication sharedApplication] sendAction:selector to:target from:sender forEvent:nil];
}

- (void)didSelectRemovedButton {
    [self handleAction:@selector(didSelectRemoveButtonFromCell:)];
}


#pragma mark swipe
- (void)panDidBegin:(CGPoint)position {
//    NSLog(@"panDidBegin topSubView: %@",self.contentView.subviews.firstObject);
    _previousPanPoint = position;
    // get the actions
    
    // note: the list of actions and what we do with action will be define some where else like in dataSource. Cell has nothing to do with it !
    // set up view
}

- (void)panDidChange:(CGPoint)position {
    UIView *superContentView = [super contentView];
    
    CGPoint oldContainerViewOrigin = self.privateContentView.frame.origin;
    CGPoint newContainerViewOrigin = CGPointMake(Boundi(oldContainerViewOrigin.x + (position.x-_previousPanPoint.x), -actionsViewWidth, 0), 0);
    
    [self.privateContentView updateConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(@(newContainerViewOrigin.x));
        make.right.equalTo(@(newContainerViewOrigin.x));
    }];
    [UIView animateWithDuration:0.005 animations:^{
        [superContentView layoutIfNeeded];
    }];
    
    _previousPanPoint = position;
}

- (void)panDidEnd:(CGPoint)position velocity:(CGPoint)velocity {
    UIView *superContentView = [super contentView];
    
    CGFloat containerViewLeftLayout;
    if (velocity.x>0) {
        containerViewLeftLayout = 0;
    } else {
        containerViewLeftLayout = -actionsViewWidth;
    }
    
    [self.privateContentView updateConstraints:^(MASConstraintMaker*make){
        make.left.equalTo(@(containerViewLeftLayout));
        make.right.equalTo(@(containerViewLeftLayout));
    }];
    [UIView animateWithDuration:0.1 animations:^{
        [superContentView layoutIfNeeded];
    }];
}

#pragma mark publics
// subclass
- (void)setModel:(id)model {
    
}

- (void)setToDeleteSelected:(BOOL)toDeleteSelected {
    if (_toDeleteSelected != toDeleteSelected) {
        _toDeleteSelected = toDeleteSelected;
        
        UIImage *removeImage;
        removeImage = toDeleteSelected? [UIImage imageNamed:@"cellRemoveSelected"] : [UIImage imageNamed:@"cellRemoveUnSelected"];
        [self.removedButton setImage:removeImage forState:UIControlStateNormal];
    }
}

- (void)shutActionPane {
    [self panDidEnd:CGPointZero velocity:CGPointMake(1.0, 0.0)];
}

- (void)setEditingActions:(NSArray *)editingActions {
    _editingActions = editingActions;
    _actionsView.editingActions = editingActions;
}

- (void)setRemovedAction:(dispatch_block_t)removedAction {
    _removedAction = removedAction;
}


@end
