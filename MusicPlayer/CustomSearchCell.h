//
//  CustomSearchCell.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/4/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const searchCellIdentifier;

@interface CustomSearchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *resultTextLabel;

@end
