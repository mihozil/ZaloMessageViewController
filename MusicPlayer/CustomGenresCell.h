//
//  CustomGenresCell.h
//  MusicPlayer
//
//  Created by ME086ll on 10/21/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const genresCellIdentifier;

@interface CustomGenresCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *tickImg;
@property (weak, nonatomic) IBOutlet UILabel *genresTextLabel;

@end
