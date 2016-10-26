//
//  SearchVC.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/3/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultController.h"
#import "AddToPlaylistVC.h"

@interface SearchVC : UIViewController <UISearchControllerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, SearchResultDelegate>

@property (nonatomic, strong) UISearchController *searchController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;


@end
