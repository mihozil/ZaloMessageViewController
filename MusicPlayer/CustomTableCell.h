//
//  CustomTableCell.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/23/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const cellIdentifier;

@interface CustomTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *cellButton;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UILabel *cellTextLabel;

@end
