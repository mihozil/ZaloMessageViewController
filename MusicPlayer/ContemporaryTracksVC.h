//
//  ContemporaryTracksVC.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/3/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddToPlaylistVC.h"

@interface ContemporaryTracksVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSString *playlistId;
@property (nonatomic, strong) NSString *playlistName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;
@property (nonatomic, assign) BOOL reloadData;

@end
