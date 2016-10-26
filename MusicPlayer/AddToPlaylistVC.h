//
//  AddToPlaylistVC.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/5/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPlaylistCell.h"
#import "SimpleTableCell.h"

@interface AddToPlaylistVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *item;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;

@end
