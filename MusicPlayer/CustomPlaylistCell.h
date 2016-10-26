//
//  CustomPlaylistCell.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/5/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const playlistCellIdentifier;

@interface CustomPlaylistCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *playlistLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tickImg;


@end
