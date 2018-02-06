//
//  ZaloSectionHeaderView.m
//  ZaloMessageTableViewController
//
//  Created by CPU11806 on 2/2/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloSectionHeaderView.h"
#import "ZaloMessageFoundations.h"

@interface ZaloSectionHeaderView()

@property (strong, nonatomic) UILabel *leftLabel;

@end

@implementation ZaloSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _leftLabel = [[UILabel alloc]init];
        [_leftLabel setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightSemibold]];
        [self addSubview:_leftLabel];
        [_leftLabel makeConstraints:^(MASConstraintMaker*make){
            make.top.and.bottom.equalTo(@0);
            make.left.equalTo(@5);
        }];
    }
    return self;
}

- (void)setLeftText:(NSString *)leftText {
    _leftText = leftText;
    _leftLabel.text = leftText;
}

@end
