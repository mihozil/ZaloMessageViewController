//
//  GenresVC.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/3/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "GenresVC.h"
#import "ContemporaryTracksVC.h"
#import "VideoPlayingViewController.h"

@interface GenresVC ()

@end

@implementation GenresVC{
    NSArray *playlists;
    int picking;
    UIImageView *tickView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addShadow];
    [self initVC];
    
    picking = -1;
    
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
}
- (void)viewWillAppear:(BOOL)animated{
    NSString *outGenres = [[NSUserDefaults standardUserDefaults]objectForKey:@"outGenres"];
    
    if ((!outGenres) || ([outGenres intValue] == 1)) picking = -1;
    
    playlists = [[NSUserDefaults standardUserDefaults]objectForKey:@"playlists"];
    [_tableView reloadData];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return playlists.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CellGenres"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellGenres"];
    }
    
    NSDictionary *playList = playlists[indexPath.row];
    cell.textLabel.text = playList[@"name"];
    cell.textLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:15];
    cell.textLabel.textColor = [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
    
    if (picking == indexPath.row){
        [tickView removeFromSuperview];
        
        tickView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bluetick.png"]];
        float size = cell.frame.size.height-30;
        tickView.frame = CGRectMake(cell.frame.size.width - size - 10, 15, size, size);
        [cell.contentView addSubview:tickView];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary *playList = playlists[indexPath.row];
    
    ContemporaryTracksVC *tracksVC = [self.storyboard instantiateViewControllerWithIdentifier:@"contemporarytracks"];
    tracksVC.playlistId =playList[@"playlistId"];
    tracksVC.playlistName =  playList[@"name"];
    
    if (picking == indexPath.row){
        tracksVC.reloadData = NO;
    } else tracksVC.reloadData = YES;
    picking = (int)indexPath.row;
    
    [self.navigationController pushViewController:tracksVC animated:YES ];
}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults]setObject:@(1) forKey:@"outGenres"];
    [tickView removeFromSuperview];
}



@end
