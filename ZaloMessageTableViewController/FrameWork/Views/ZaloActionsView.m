//
//  ZaloActionsView.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/26/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloActionsView.h"
#import "ZaloCollectionViewCell.h"

// need to define a list of actions
// then just follow it
@implementation ZaloActionsView

- (void)setEditingActions:(NSArray<ZaloActionView*> *)editingActions {
    
    _editingActions = editingActions;
    
    CGSize actionSize = CGSizeMake(actionsViewWidth/editingActions.count, self.frame.size.height) ;
    CGFloat originX = 0;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    for (ZaloActionView*actionView in editingActions) {
        [actionView setFrame:CGRectMake(originX, 0, actionSize.width,actionSize.height)];
        [self addSubview:actionView];
        originX+=actionSize.width;
        
        actionView.button.tag = [editingActions indexOfObject:actionView];
        [actionView.button addTarget:self action:@selector(handleActionViewButtonAction:) forControlEvents:UIControlEventTouchDown];
    }
}

- (void)handleActionViewButtonAction:(UIButton*)button {
    ZaloActionView *actionView = [self actionViewForButton:button];
    [self.cell handleAction:actionView.selector];
}

- (ZaloActionView*)actionViewForButton:(UIButton*)button {
    NSInteger index = button.tag;
    return [_editingActions objectAtIndex:index];
}

@end

@implementation ZaloActionView

- (instancetype)initWithTitle:(NSString*)title selector:(SEL)selector {
    self = [super init];
    if (self) {
        self.selector = selector;
        
        _button = [[UIButton alloc]init];
        [_button setTitle:title forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button setBackgroundColor:[UIColor grayColor]];
        [self addSubview:_button];
        [_button makeConstraints:^(MASConstraintMaker*make){
            make.top.and.right.and.left.and.bottom.equalTo(@0);
        }];
    }
    return self;
    
}


@end
