//
//  ZaloPlaceholderView.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/13/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloPlaceholderView.h"
#import "ZaloMessageFoundations.h"

@interface ZaloPlaceholderView()

@property (strong, nonatomic) UILabel *titleLabel, *messageLabel;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ZaloPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}


- (void)setUp {

    self.backgroundImageView = [[UIImageView alloc]init];
    [self addSubview:self.backgroundImageView];
    [self.backgroundImageView makeConstraints:^(MASConstraintMaker*make){
        make.top.and.left.and.bottom.and.right.equalTo(@0);
    }];
    
    self.titleLabel = [[UILabel alloc]init];
    [self.titleLabel setFont:[UIFont systemFontOfSize:23 weight:UIFontWeightMedium]];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    [self addSubview:self.titleLabel];
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make){
        make.top.and.left.equalTo(@30);
        make.right.equalTo(@-30);
    }];
    
    self.messageLabel = [[UILabel alloc]init];
    [self.messageLabel setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightRegular]];
    [self.messageLabel setTextAlignment:NSTextAlignmentCenter];
    self.messageLabel.numberOfLines = 0;
    [self addSubview:self.messageLabel];
    [self.messageLabel makeConstraints:^(MASConstraintMaker*make){
        make.top.equalTo(self.titleLabel.bottom).with.offset(10);
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
    }];
}

- (void)setModel:(ZaloDataSourcePlaceholder *)model {
    self.titleLabel.text = model.title;
    self.messageLabel.text = model.message;
    self.backgroundImageView.image  = model.image;
    if (model.showActivityIndicator) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.tintColor = [UIColor grayColor];
        [self addSubview:activityIndicator];
        [activityIndicator makeConstraints:^(MASConstraintMaker*make){
            make.center.equalTo(self);
        }];
        [activityIndicator startAnimating];
    }
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    
}

@end
