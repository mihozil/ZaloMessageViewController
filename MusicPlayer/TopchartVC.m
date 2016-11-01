//
//  ;
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/22/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "TopchartVC.h"
#import "MySingleton.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <XCDYouTubeKit/XCDYouTubeVideo.h>
#import "VideoPlayingViewController.h"
#import "AddToPlaylistVC.h"
#import "MyActivityIndicatorView.h"

//https://www.googleapis.com/youtube/v3/search?part=snippet&relatedToVideoId=5rOiW_xY-kc&type=video&key={YOUR_API_KEY}

@interface TopchartVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;

@end

@implementation TopchartVC {
    NSString *playListId;
    NSMutableArray *items;
    NSDictionary *addedItem;
    NSString *nextPageToken;
    
     MyActivityIndicatorView *activityIndicator;
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addShadow];
    [self initVC];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAds) name:@"Purchased" object:nil];
    
//    BOOL isPurchase = YES;
//    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithBool:isPurchase], nil];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:arr]
//                                              forKey:@"Purchase"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"Purchased" object:nil];
    
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

- (void) addScreenTracking{
    id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
    [tracker set:kGAIScreenName value:@"TopchartVC"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}
- (void)viewWillAppear:(BOOL)animated{
    
//    NSLog(@"TOP CHART");
//    int i=-1;
//    NSLog(@"adsf: %@",items[i]);
    
    [self addScreenTracking];
    
    [_tableView registerNib:[UINib nibWithNibName:@"CustomTableCell" bundle:nil] forCellReuseIdentifier:@"CustomTableCell"];
    // Do any additional setup after loading the view.
    if (items.count==0){
        [self getPlaylistID];
        [self getTopChart];
    }
    // remember to remove this 
    [self addAds];
    
}

- (void) initVC{
    _tableView.separatorColor = [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
    items = [[NSMutableArray alloc]init];
}

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

- (void) addAds{
    
    
    MySingleton *mySingleton = [MySingleton sharedInstance];
    GADBannerView *bannerView = mySingleton.bannerView;
    
    float screenHeight = self.view.frame.size.height;
    
    float bannerY = screenHeight - 49 - bannerView.frame.size.height;
    bannerView.frame = CGRectMake( bannerView.frame.origin.x, bannerY, bannerView.frame.size.width, bannerView.frame.size.height);
    
    
    [self.view addSubview:bannerView];
    
    
    [_bottomLayout setConstant:bannerView.frame.size.height];
    
}

- (void) resetFrameTableViewWithAds{
    if ([MySingleton sharedInstance].bannerView ){
        _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-[MySingleton sharedInstance].bannerView.frame.size.height-49);
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [self resetFrameTableViewWithAds];
}

- (void) getPlaylistID{
    NSArray *playLists = [[NSUserDefaults standardUserDefaults]objectForKey:@"playlists"];
    if (!playLists) {
        playListId = @"PLx0sYbCqOb8TBPRdmBHs5Iftvv9TPboYG";
    } else {
        NSDictionary *playList = playLists[0];
        playListId = playList[@"playlistId"];
    }
}


- (void) getTopChart{
        NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=%d&playlistId=%@&key=AIzaSyDUknhXUA_YnOef5RY3VCT6IuEhWylTi3M",maxSongsNumber,playListId];
     [self addTableItems:urlString];

}
- (void) addTableItems:(NSString*)urlString{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startActivityIndicatorView];
    });
    
    [IOSRequest requestPath:urlString onCompletion:^(NSDictionary*json, NSError*error){
        
        if (!error){
            
            [items addObjectsFromArray:json[@"items"]];
            nextPageToken = json[@"nextPageToken"];
            dispatch_async(dispatch_get_main_queue(),^{
                [_tableView reloadData];
            });
            
        }else {
            NSLog(@"error: %@",error.description);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
                [self stopActivityIndicatorView];
        });
        
    }];


}

- (void) updateTable{
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=%d&playlistId=%@&key=AIzaSyDUknhXUA_YnOef5RY3VCT6IuEhWylTi3M&pageToken=%@",maxSongsNumber,playListId,nextPageToken];
    [self addTableItems:urlString];
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
    
    if ((indexPath.row == items.count -1) && (nextPageToken)){
        [self updateTable];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[NSUserDefaults standardUserDefaults]setObject:items forKey:@"playlistitems"];
    
    NSDictionary *item = items[indexPath.row];
    NSString *idVideo = item[@"snippet"][@"resourceId"][@"videoId"];
    
    [[NSUserDefaults standardUserDefaults]setObject:idVideo forKey:@"idVideo"];
    [[NSUserDefaults standardUserDefaults]setObject:item forKey:@"playingItem"];
    [[NSUserDefaults standardUserDefaults]setObject:item[@"snippet"][@"title"] forKey:@"titleVideo"];
    
    NSString *path = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=contentDetails,statistics&id=%@&key=AIzaSyDUknhXUA_YnOef5RY3VCT6IuEhWylTi3M",idVideo];
    
    [IOSRequest requestPath:path onCompletion:^(NSDictionary *json, NSError*error){
        if ((!error) && ([json[@"items"] count]>0)) {      // remember to add this to other VC 
            
            NSDictionary *item = json[@"items"][0];
            NSString *view = item[@"statistics"][@"viewCount"];
            [[NSUserDefaults standardUserDefaults]setObject:view forKey:@"viewCount"];
        }
    }];
    
    [self playNonFull:idVideo];
    
}
- (void) errorPlaying{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Error playing video" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
   
}

- (void) removeCurrentVIDEO{
    UIWindow *window = [[UIApplication sharedApplication]keyWindow];
    if ([[window subviews]count] > 1) {
        [[[window subviews] lastObject] removeFromSuperview];
    }
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
    
    
    [VideoPlayingViewController shareInstance].modalPresentationStyle = UIModalPresentationOverCurrentContext;
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
    [self showOptionALert:(int)[sender tag]];
}

- (void) showOptionALert:(int) index{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *addPlaylistAction = [UIAlertAction actionWithTitle:@"Add To Playlist" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        [self addPlaylist];
    }];
//    UIAlertAction *addShareAction  = [UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
//        [self addShare:(index)];
//        
//    }];
    UIAlertAction *cancelAction  = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:addPlaylistAction];
//    [alertController addAction:addShareAction];
    [alertController addAction:cancelAction];
    
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    CustomTableCell *cell = (CustomTableCell*)[_tableView cellForRowAtIndexPath:indexPath];
    alertController.popoverPresentationController.sourceView = cell.contentView;
    alertController.popoverPresentationController.sourceRect = cell.contentView.frame;
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}


@end
