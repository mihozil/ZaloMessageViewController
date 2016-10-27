//
//  SearchVC.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/3/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "SearchVC.h"
#import "IOSRequest.h"
#import "CustomTableCell.h"
#import "VideoPlayingViewController.h"

@interface SearchVC ()

@end

@implementation SearchVC{
    SearchResultController *searchResult;
    NSMutableArray *items;
    NSDictionary *addedItem;
    MyActivityIndicatorView *activityIndicator;
    NSString *currentSearch, *nextPageToken;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_tableView registerNib:[UINib nibWithNibName:@"CustomTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CustomTableCell"];
    [self addShadow];
    [self initVC];
    [self createSearchBar];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAds) name:@"Purchased" object:nil];
}
- (void) removeAds{
    // remove ads
    MySingleton *mySingleton = [MySingleton sharedInstance];
    [mySingleton.bannerView removeFromSuperview];
    mySingleton.bannerView = nil;
    
    // update tableview
    [_bottomLayout setConstant:0];
}

- (void) startActivityIndicatorView{
    [self stopActivityIndicatorView];
    
    activityIndicator = [[MyActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    activityIndicator.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}
- (void) stopActivityIndicatorView{
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
}
//-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
//        [self stopActivityIndicatorView];
//    }
//}

- (void) addShadow{
    self.navigationController.navigationBar.layer.shadowColor = [[UIColor colorWithRed:178 green:178 blue:178 alpha:1]CGColor];
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0.0, 3);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.8;
    self.navigationController.navigationBar.layer.masksToBounds = NO;
    self.navigationController.navigationBar.layer.shouldRasterize = YES;
    
    UIColor *color = [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:color   ,
                                                                      NSFontAttributeName:[UIFont fontWithName:@"SFUIDisplay-Semibold" size:17]}];
    
}
- (void) initVC{
    _tableView.separatorColor = [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
    items = [[NSMutableArray alloc]init];
}

- (void)viewDidAppear:(BOOL)animated{
    [self createSearchBar];
}
- (void) addScreenTracking{
    id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
    [tracker set:kGAIScreenName value:@"SearchVC"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

}

- (void)viewWillAppear:(BOOL)animated{
    [self addScreenTracking];
    [self addAds];
}
- (void) addAds{
    MySingleton *mySingleton = [MySingleton sharedInstance];
    GADBannerView *bannerView = mySingleton.bannerView;
    float bannerY = self.view.frame.size.height - 49 - bannerView.frame.size.height;
    bannerView.frame = CGRectMake( bannerView.frame.origin.x, bannerY, bannerView.frame.size.width, bannerView.frame.size.height);
    [self.view addSubview:bannerView];
    
    [_bottomLayout setConstant:bannerView.frame.size.height];
}

- (void) createSearchBar{
    searchResult = [[SearchResultController alloc]init];
    searchResult.delegate = self;
    
    _searchController = [[UISearchController alloc]initWithSearchResultsController:searchResult];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = YES;
    if (!currentSearch)
        _searchController.searchBar.placeholder = @"Search here";
    else {
        currentSearch = [currentSearch stringByRemovingPercentEncoding];
     _searchController.searchBar.text = currentSearch;
     
    }
    _searchController.searchBar.delegate = self;
    _searchController.hidesNavigationBarDuringPresentation = YES;
    [_searchController.searchBar sizeToFit];
    self.definesPresentationContext = YES;
    
    _tableView.tableHeaderView = self.searchController.searchBar;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[NSUserDefaults standardUserDefaults]setObject:items forKey:@"playlistitems"];
    // take care of this, the playlist items can be mixed by eachother and lead to mistake
    
    NSDictionary *item = items[indexPath.row];
    NSString *idVideo = item[@"snippet"][@"resourceId"][@"videoId"];
    if (!idVideo) idVideo = item[@"id"][@"videoId"];
    
    [[NSUserDefaults standardUserDefaults]setObject:idVideo forKey:@"idVideo"];
    [[NSUserDefaults standardUserDefaults]setObject:item forKey:@"playingItem"];
    [[NSUserDefaults standardUserDefaults]setObject:item[@"snippet"][@"title"] forKey:@"titleVideo"];
    
    NSString *path = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=contentDetails,statistics&id=%@&key=AIzaSyDUknhXUA_YnOef5RY3VCT6IuEhWylTi3M",idVideo];
    [IOSRequest requestPath:path onCompletion:^(NSDictionary *json, NSError*error){
        if ((!error) && ([json[@"items"] count]>0)){
            NSDictionary *item = json[@"items"][0];
            NSString *view = item[@"statistics"][@"viewCount"];
            [[NSUserDefaults standardUserDefaults]setObject:view forKey:@"viewCount"];
        }
    }];
    
    [self playNonFull:idVideo];
    
}
- (void) playNonFull:(NSString*)idVideo{
    MySingleton *mySingleton = [MySingleton sharedInstance];
    mySingleton.playingViewCount = (mySingleton.playingViewCount +1)%8;
    
    [VideoPlayingViewController shareInstance].idVideo = idVideo;
    [VideoPlayingViewController shareInstance].playingView = mySingleton.playingView;
      [VideoPlayingViewController shareInstance].didDismiss = NO; // remember to add this to other VC 
    [[VideoPlayingViewController shareInstance]playVideo];
    float width = [[UIScreen mainScreen]bounds].size.width;
    float height = width/16*9;
    [self switchVideowithX:0 andY:0 andWidth:width andHeight:height];
    
    [MySingleton sharedInstance].restrictRotation = NO;
    
    [[[[UIApplication sharedApplication]keyWindow] rootViewController] presentViewController: [VideoPlayingViewController shareInstance] animated:YES completion:^{
       
        [[VideoPlayingViewController shareInstance]createPlayingControl];
        [[VideoPlayingViewController shareInstance]updatePlayingControl];
        [[VideoPlayingViewController shareInstance]addDismissBt];
    }];
}

- (void) switchVideowithX:(float)x andY:(float)y andWidth:(float)width andHeight:(float)height{
    MySingleton *mySingleton = [MySingleton sharedInstance];
    UIView *_playingView = mySingleton.playingView;
    
    [UIView animateWithDuration:0.0 animations:^{
        _playingView.frame = CGRectMake(x, y, width, height);
    }completion:^(BOOL finish){
         [[VideoPlayingViewController shareInstance] updateActivityIndicatorPosition];
    }];
    
    [[[UIApplication sharedApplication]keyWindow] bringSubviewToFront:_playingView];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CustomTableCell *cell = (CustomTableCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell){
        cell = [[CustomTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *item = items[indexPath.row];
    cell.cellTextLabel.text = item[@"snippet"][@"title"];
    
    [cell.cellImage setImageWithURL:[NSURL URLWithString:item[@"snippet"][@"thumbnails"][@"high"][@"url"]] placeholderImage:[UIImage imageNamed:@"musicplay"]];
    
    [cell.cellButton addTarget:self action:@selector(onButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    cell.cellButton.tag = indexPath.row;
    
    if ((indexPath.row == items.count -1) && (nextPageToken) && (currentSearch))
        [self updateTable];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return items.count;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
}
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchText = searchController.searchBar.text;
    
    NSString *encodeSearch = [searchText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString*path2 = [NSString stringWithFormat:@"https://suggestqueries.google.com/complete/search?ds=yt&hjson=t&client=firefox&alt=json&ie=utf_8&oe=utf_8&q=%@",encodeSearch];
    
    [IOSRequest requestPath2:path2 onCompletion:^(NSArray*json, NSError*error){
        if (!error){
            searchResult.searchResultArray = json[1];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                    [searchResult.tableView reloadData];
            });
        
        }
    }];
}


- (void) updateTable{
    NSString *currentSearchEncode = [currentSearch stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *path = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=%d&q=%@&type=video&key=AIzaSyDUknhXUA_YnOef5RY3VCT6IuEhWylTi3M&pageToken=%@",maxSongsNumber,currentSearchEncode,nextPageToken];
    [self addTableItems:path];
}

- (void) addTableItems:(NSString*)path{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startActivityIndicatorView];
    });
    
    [IOSRequest requestPath:path onCompletion:^(NSDictionary*json, NSError*error){
        if (!error){
            
            [items addObjectsFromArray:json[@"items"]];

            nextPageToken = json[@"nextPageToken"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
                
            });
            
        } else {
            
            items = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
                [self alertError:@"Error Searching" andMessenge:[NSString stringWithFormat:@"%@",error.localizedDescription]];
            });
            
        
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopActivityIndicatorView];
        });
    }];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.text){
        currentSearch = searchBar.text;
        [self didChoseText:searchBar.text];
    }
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
    currentSearch = [currentSearch stringByRemovingPercentEncoding];
    
    searchBar.text = currentSearch;
    
}

- (void)didChoseText:(NSString *)text{
    text = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    currentSearch = [NSString stringWithString:text];
    NSString *path = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=%d&q=%@&type=video&key=AIzaSyDUknhXUA_YnOef5RY3VCT6IuEhWylTi3M",maxSongsNumber,text];
    
    items = [[NSMutableArray alloc]init];
    [self addTableItems:path];
    
        _searchController.active = false;
}

- (void) alertError:(NSString*)title andMessenge:(NSString*)messenge{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messenge preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) onButtonTouch:(id) sender{
    int index = (int)[sender tag] ;
    addedItem = items[index];
    [self showOptionALert:(int)[sender tag]];
}

- (void) showOptionALert:(int) index{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *addPlaylistAction = [UIAlertAction actionWithTitle:@"Add To Playlist" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        [self addPlaylist];
    }];
//    UIAlertAction *addShareAction  = [UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
//        [self addShare:index];
//    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:addPlaylistAction];
//    [alertController addAction:addShareAction];
    [alertController addAction:cancelAction];
    
//    alertController.modalPresentationStyle = UIModalPresentationPopover;
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//    CustomTableCell *cell = (CustomTableCell*)[_tableView cellForRowAtIndexPath:indexPath];
//    alertController.popoverPresentationController.sourceView = cell.contentView;
//    alertController.popoverPresentationController.sourceRect = cell.contentView.frame;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) addShare:(int) index{
    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/app//id%@",APPID];
    NSString *title = [NSString stringWithFormat:@"Greate Song! Listen it: %@ Available in: %@",addedItem[@"snippet"][@"title"],url];
    
    NSArray *dataShare = @[title];
    UIActivityViewController *activityController = [[UIActivityViewController alloc]initWithActivityItems:dataShare applicationActivities:nil];
    if ( [activityController respondsToSelector:@selector(popoverPresentationController)] ) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        CustomTableCell *cell = (CustomTableCell*)[_tableView cellForRowAtIndexPath:indexPath];
        activityController.popoverPresentationController.sourceView = cell.contentView;
        activityController.popoverPresentationController.sourceRect = cell.contentView.frame;
    }
    
    activityController.excludedActivityTypes = @[UIActivityTypeAirDrop];
    [self presentViewController:activityController animated:YES completion:nil];
    
}
- (void) addPlaylist{
    AddToPlaylistVC *addToPlaylist = [self.storyboard instantiateViewControllerWithIdentifier:@"addtoplaylistvc"];
    addToPlaylist.item = addedItem;
    [self presentViewController:addToPlaylist animated:YES completion:nil];
    
}

@end
