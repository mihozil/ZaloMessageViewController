//
//  PlaylistDetailVC.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/5/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "PlaylistDetailVC.h"
#import "VideoPlayingViewController.h"

@interface PlaylistDetailVC ()

@end

@implementation PlaylistDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAds) name:@"Purchased" object:nil];
    
    [_tableView registerNib:[UINib nibWithNibName:simpleCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:simpleCellIdentifier];
    self.title = self.name;
    [self initVC];
    [self addShadow];
    [self customBackBt];
    
}

- (void) removeAds{
    // remove ads
    MySingleton *mySingleton = [MySingleton sharedInstance];
    [mySingleton.bannerView removeFromSuperview];
    mySingleton.bannerView = nil;
    
    // update tableview
    [_bottomLayout setConstant:0];
}

- (void) initVC{
    _tableView.separatorColor = [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
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
- (void) addScreenTracking{
    id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
    [tracker set:kGAIScreenName value:@"PlaylistDetailVC"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self addScreenTracking];
    [self addAds];
    
    NSArray *playlists = [[NSUserDefaults standardUserDefaults]objectForKey:@"myPlaylists"];
    _items = playlists[_index][@"items"];
    
    [_tableView reloadData];
}
- (void) addAds{
    MySingleton *mySingleton = [MySingleton sharedInstance];
    GADBannerView *bannerView = mySingleton.bannerView;
    float bannerY = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) - 64 - 49 - bannerView.frame.size.height;
    
    bannerView.frame = CGRectMake( bannerView.frame.origin.x, bannerY, bannerView.frame.size.width, bannerView.frame.size.height);
    [self.view addSubview:bannerView];
    
       [_bottomLayout setConstant:bannerView.frame.size.height];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_items count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    CustomTableCell *cell = (CustomTableCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    if (!cell){
//        cell = [[CustomTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
    SimpleTableCell *cell = (SimpleTableCell*)[tableView dequeueReusableCellWithIdentifier:simpleCellIdentifier forIndexPath:indexPath];
    if (!cell){
        cell = [[SimpleTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleCellIdentifier];
    }
    
    NSDictionary *item = _items[indexPath.row];
    cell.cellTextLabel.text = item[@"snippet"][@"title"];
    
    [cell.cellImage setImageWithURL:[NSURL URLWithString:item[@"snippet"][@"thumbnails"][@"high"][@"url"]] placeholderImage:[UIImage imageNamed:@"musicplay.png"]];
    cell.playingImage = nil;
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-  (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray *updatedItems = [NSMutableArray arrayWithArray:_items];
        [updatedItems removeObjectAtIndex:indexPath.row];
        _items = updatedItems;
        [_tableView reloadData];
        
        
        [self removeItematIndex:(int)indexPath.row];
        
        
    }
}
- (void) removeItematIndex:(int) itemIndex{
    NSMutableArray *playlists = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"myPlaylists"]];
    NSMutableDictionary *playlist = [NSMutableDictionary dictionaryWithDictionary:playlists[_index]];
    [playlists removeObject:playlist];
    
    if (_items.count>0){
        playlist[@"items"] = _items;
        NSDictionary *firstItem = playlist[@"items"][0];
        playlist[@"image"] =  firstItem[@"snippet"][@"thumbnails"][@"high"][@"url"];
       
    } else {
        playlist[@"items"] = _items;
        playlist[@"image"] = nil;
    }
    
      [playlists insertObject:playlist atIndex:_index];
      [[NSUserDefaults standardUserDefaults]setObject:playlists forKey:@"myPlaylists"];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[NSUserDefaults standardUserDefaults]setObject:_items forKey:@"playlistitems"];
    
    NSDictionary *item = _items[indexPath.row];
    NSString *idVideo = item[@"snippet"][@"resourceId"][@"videoId"];
    if (!idVideo) idVideo = item[@"id"][@"videoId"];
    
    [[NSUserDefaults standardUserDefaults]setObject:idVideo forKey:@"idVideo"];
    [[NSUserDefaults standardUserDefaults]setObject:item forKey:@"playingItem"];
    [[NSUserDefaults standardUserDefaults]setObject:item[@"snippet"][@"title"] forKey:@"titleVideo"];
    
    NSString *path = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=contentDetails,statistics&id=%@&key=AIzaSyDUknhXUA_YnOef5RY3VCT6IuEhWylTi3M",idVideo];
    
    [IOSRequest requestPath:path onCompletion:^(NSDictionary *json, NSError*error){
        if ((!error) && ([json[@"items"] count]>0)) {     
            
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




@end
