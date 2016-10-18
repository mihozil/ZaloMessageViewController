//
//  PlaylistDetailVC.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/5/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleTableCell.h"

@interface PlaylistDetailVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int index;
@end
