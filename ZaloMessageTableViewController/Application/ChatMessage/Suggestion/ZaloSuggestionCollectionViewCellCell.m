//
//  ZaloSuggestionCollectionViewCellCell.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/17/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloSuggestionCollectionViewCellCell.h"
#import "ZaloMessageFoundations.h"
#import "ZaloSuggestionCollectionViewModel.h"

@interface ZaloSuggestionCollectionViewCellCell()

@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation ZaloSuggestionCollectionViewCellCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSuggestionCollectionViewCellCell];
    }
    return self;
}

- (void)setUpSuggestionCollectionViewCellCell {
    _iconImageView = [[UIImageView alloc]init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    _iconImageView.clipsToBounds = true;
    [self.contentView addSubview:_iconImageView];
    [_iconImageView makeConstraints:^(MASConstraintMaker*make){
        make.top.equalTo(@2);
        make.left.equalTo(@11);
        make.right.equalTo(@-11);
        make.width.equalTo(self.iconImageView.height);
    }];
    
    _titleLabel = [[UILabel alloc]init];
    [_titleLabel setFont:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    [_titleLabel makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(_iconImageView.bottom).with.offset(3);
        make.left.equalTo(@2);
        make.right.equalTo(@-2);
        make.height.equalTo(@17);
    }];
}

- (void)setModel:(id)model {
    if ([model respondsToSelector:@selector(icon)]) {
        NSString *icon = (NSString*)[model icon];
        self.iconImageView.image = [UIImage imageNamed:icon];
    }
    if ([model respondsToSelector:@selector(title)]) {
        NSString *title = (NSString*)[model title];
        self.titleLabel.text = title;
    }
}

@end
