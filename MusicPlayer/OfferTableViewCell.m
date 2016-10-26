//
//  OfferTableViewCell.m
//  CloudMusicWorld
//
//  Created by BMX-05 on 5/7/16.
//  Copyright © 2016 BMX-05. All rights reserved.
//

#import "OfferTableViewCell.h"

@implementation OfferTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageApp.layer.cornerRadius = 10;
    self.imageApp.clipsToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
