//
//  SimpleTableCell.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/11/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *const simpleCellIdentifier;
@interface SimpleTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UIImageView *playingImage;

@end
