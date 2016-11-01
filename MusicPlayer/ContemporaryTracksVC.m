//
//  ContemporaryTracksVC.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/3/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "ContemporaryTracksVC.h"
#import "IOSRequest.h"
#import "CustomTableCell.h"
#import "VideoPlayingViewController.h"



@interface ContemporaryTracksVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ContemporaryTracksVC{
    NSMutableArray *items;
    NSDictionary *addedItem;
    MyActivityIndicatorView *activityIndicator;
    NSString *nextPageToken;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.playlistName;
    items = [[NSMutableArray alloc]init];

    [_tableView registerNib:[UINib nibWithNibName:@"CustomTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CustomTableCell"];
    
    [self customBackBt];
    
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
- (void) customBackBt{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"backbar"] forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(10.5,31.5,12.5,31);
    [leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
}
- (void) backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) startActivityIndicatorView{
    activityIndicator = [[MyActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityIndicator.color = [UIColor darkGrayColor];
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
- (void) initVC{
    _tableView.separatorColor = [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
}
- (void) addScreenTracking{
    id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
    [tracker set:kGAIScreenName value:@"ContemporaryTracksVC"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self addScreenTracking];
    
    if (items.count==0) [self getTopTemporaryChart];
    
    [self initVC];
    
    [self addAds];
}
- (void) addAds{
    self.navigationController.edgesForExtendedLayout = UIRectEdgeAll;
    
    MySingleton *mySingleton = [MySingleton sharedInstance];
    GADBannerView *bannerView = mySingleton.bannerView;
    float bannerY = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) -64 - 49 - bannerView.frame.size.height;
    bannerView.frame = CGRectMake( bannerView.frame.origin.x, bannerY, bannerView.frame.size.width, bannerView.frame.size.height);
    [self.view addSubview:bannerView];
    
    [_bottomLayout setConstant:bannerView.frame.size.height];
}

- (void) addTableItems:(NSString*)path{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startActivityIndicatorView];
    });
    
    [IOSRequest requestPath:path onCompletion:^(NSDictionary*json, NSError*error){
        if (!error){
            [items addObjectsFromArray: json[@"items"]];
            nextPageToken = json[@"nextPageToken"];
            
            [[NSUserDefaults standardUserDefaults]setObject:items forKey:@"temporaryPlaylistitems"];
            
            [[NSUserDefaults standardUserDefaults]setObject:@(0) forKey:@"outGenres"];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [_tableView reloadData];
            });
        } else NSLog(@"error");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopActivityIndicatorView];
        });
        
    }];
    
}

- (void) getTopTemporaryChart{
    //
    if (!_reloadData){
        items = [[NSUserDefaults standardUserDefaults] objectForKey:@"temporaryPlaylistitems"]; // change to temporary playlist items
          [[NSUserDefaults standardUserDefaults]setObject:@(0) forKey:@"outGenres"];
        [_tableView reloadData];
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=%d&playlistId=%@&key=AIzaSyDUknhXUA_YnOef5RY3VCT6IuEhWylTi3M",maxSongsNumber,_playlistId];
    [self addTableItems:path];
    
}
- (void) updateTable{
    NSString *path = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=%d&playlistId=%@&key=AIzaSyDUknhXUA_YnOef5RY3VCT6IuEhWylTi3M&pageToken=%@",maxSongsNumber,_playlistId,nextPageToken];
    [self addTableItems:path];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CustomTableCell";
    CustomTableCell *cell = (CustomTableCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [[CustomTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *item = items[indexPath.row];
    cell.cellTextLabel.text = item[@"snippet"][@"title"];
    
    [cell.cellImage setImageWithURL:[NSURL URLWithString:item[@"snippet"][@"thumbnails"][@"high"][@"url"]] placeholderImage:[UIImage imageNamed:@"musicplay"]];
    
    [cell.cellButton addTarget:self action:@selector(onButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
     cell.cellButton.tag = indexPath.row;
    
    if ((indexPath.row == items.count-1) && (nextPageToken))
         [self updateTable];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[NSUserDefaults standardUserDefaults]setObject:items forKey:@"playlistitems"]; // this is very true
    // take care of this: it can be mistaken withtop chart
    
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

- (void) onButtonTouch:(id) sender{
    int index = (int)[sender tag] ;
    addedItem = items[index];
    [self showOptionALert:index];
}
- (void) showOptionALert:(int) index{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *addPlaylistAction = [UIAlertAction actionWithTitle:@"Add To Playlist" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        [self addPlaylist];
    }];
//    UIAlertAction *addShareAction  = [UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
//        [self addShare:index];
//    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    CustomTableCell *cell = (CustomTableCell*)[_tableView cellForRowAtIndexPath:indexPath];
    alertController.popoverPresentationController.sourceView = cell.contentView;
    alertController.popoverPresentationController.sourceRect = cell.contentView.frame;
    
    
    [alertController addAction:addPlaylistAction];
//    [alertController addAction:addShareAction];
    [alertController addAction:cancelAction];
  
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
