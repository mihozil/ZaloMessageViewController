//
//  ZaloFriendRequestsCollectionViewCell.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/26/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloFriendRequestsCollectionViewCell.h"
#import "ZaloFriendRequestModel.h"

@interface ZaloFriendRequestsCollectionViewCell()

@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIButton *makeFriendButton;

@end

@implementation ZaloFriendRequestsCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpFriendRequestsCollectionViewCell];
    }
    return self;
}

- (void)setUpFriendRequestsCollectionViewCell {
    UIView *contentView = self.contentView;
    
    _iconImageView = [[UIImageView alloc]init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [contentView addSubview:_iconImageView];
    [_iconImageView makeConstraints:^(MASConstraintMaker *make){
        make.top.and.left.equalTo(@5);
        make.bottom.equalTo(@-5);
        make.width.equalTo(_iconImageView.height);
    }];
    
    _titleLabel = [[UILabel alloc]init];
    [_titleLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
    [_titleLabel setTextColor:[UIColor blackColor]];
    [contentView addSubview:_titleLabel];
    [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.left.equalTo(_iconImageView.right).with.offset(10);
    }];
    
    _detailLabel = [[UILabel alloc]init];
    [_detailLabel setFont:[UIFont systemFontOfSize:14.5 weight:UIFontWeightRegular]];
    [_detailLabel setTextColor:[UIColor grayColor]];
    [contentView addSubview:_detailLabel];
    [_detailLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.bottom).with.offset(5);
        make.left.equalTo(_iconImageView.right).with.offset(10);
    }];
    
    _makeFriendButton = [[UIButton alloc]init];
    [_makeFriendButton setTitle:@"Add Friend" forState:UIControlStateNormal];
    [_makeFriendButton.titleLabel setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightRegular]];
    [_makeFriendButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    [contentView addSubview:_makeFriendButton];
    [_makeFriendButton makeConstraints:^(MASConstraintMaker*make){
        make.centerY.equalTo(contentView);
        make.right.equalTo(@-10);
    }];
}

- (void)setModel:(id)model {
    if ([model respondsToSelector:@selector(title)]) {
        self.titleLabel.text = [model title];
    }
    if ([model respondsToSelector:@selector(detail)]) {
        self.detailLabel.text = [model detail];
    }
    if ([model respondsToSelector:@selector(icon)]) {
        NSString *iconName = (NSString*)[model icon];
        self.iconImageView.image = [UIImage imageNamed:iconName];
    }
}

@end
