//
//  PlaylistVC.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/5/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "PlaylistVC.h"
#import "CustomPlaylistCell.h"
#import "PlaylistDetailVC.h"

NSString *const kKeychainItemName = @"YouTubeSample: YouTube";

@interface PlaylistVC ()

@end

@implementation PlaylistVC{
    NSMutableArray *playlists;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_tableView registerNib:[UINib nibWithNibName:playlistCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:playlistCellIdentifier];
    [self initVC];
    [self addShadow];
    
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
- (void) initVC{
    _tableView.separatorColor = [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
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
    [tracker set:kGAIScreenName value:@"PlaylistVC"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self addScreenTracking];
    
    playlists = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"myPlaylists"]];
    if (!playlists) playlists = [[NSMutableArray alloc]init];
    [_tableView reloadData];
    
    [self addAds];

}
- (void)viewDidAppear:(BOOL)animated{
    
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
    return playlists.count+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistCell" forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"plus"];
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        
//        cell.imgView.image = [UIImage imageNamed:@"plus"];
//        cell.playlistLabel.text = @"Add New Playlist";
//        cell.playlistLabel.text = @"";
        return cell;
    }else{
        CustomPlaylistCell*cell = (CustomPlaylistCell*)[tableView dequeueReusableCellWithIdentifier:playlistCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[CustomPlaylistCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:playlistCellIdentifier];
        }
        
        NSDictionary  *dic = playlists[indexPath.row-1];
        
        if (dic[@"image"])
            [cell.imgView setImageWithURL:[NSURL URLWithString:dic[@"image"]] placeholderImage:[UIImage imageNamed:@"musicplay"]];
        else cell.imgView.image= [UIImage imageNamed:@"musicplay"];
        
        cell.playlistLabel.text = dic[@"name"];
        cell.detailLabel.text = [NSString stringWithFormat:@"%lu Videos",[dic[@"items"] count]];
            [cell.tickImg setHidden:YES];
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 0){
        [self addPlaylistAlert];
    } else
    if (playlists[indexPath.row-1][@"items"]){
        
        PlaylistDetailVC *playlistDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistdetailvc"];
        
        playlistDetail.items = playlists[indexPath.row-1][@"items"];
        playlistDetail.name = playlists[indexPath.row-1][@"name"];
        
        playlistDetail.index = (int)indexPath.row-1;
        [self.navigationController pushViewController:playlistDetail animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row>0)
        return YES;
    return NO;
    
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
    }
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewRowAction *actionRename =[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Rename" handler:^(UITableViewRowAction*action, NSIndexPath*indexPath){
        NSDictionary *playlist = playlists[indexPath.row-1];
        [self changePlaylistNameALert:playlist atIndex:(int)indexPath.row-1];
    }];
    actionRename.backgroundColor = [UIColor blueColor];
    
    UITableViewRowAction *actionDelete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction*action, NSIndexPath*indexPath){
        
        [playlists removeObjectAtIndex:indexPath.row-1];
        [[NSUserDefaults standardUserDefaults]setObject:playlists forKey:@"myPlaylists"];
        [_tableView reloadData];
        
    }];
    actionDelete.backgroundColor = [UIColor redColor];
    return @[actionRename,actionDelete];
}

- (void) addPlaylistAlert{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New Playlist" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        
        UITextField *textField = alertController.textFields[0];
        if ([textField.text isEqualToString:@""]) [self displayAlertTitle:@"Error" andMessenge:@"Playlist name is not allowed to be empty"];
        else{
            if ([self playlistNameExist:textField.text]) [self displayAlertTitle:@"Playlist already exists" andMessenge:@"Please try again"];
            else
                [self addNewPlaylist:textField.text];
        }
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action){

    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}
- (BOOL) playlistNameExist:(NSString*)name{
    for (NSDictionary *playlist in playlists){
        if ([name isEqualToString:playlist[@"name"]]) return YES;
    }
    return NO;
}
- (void) displayAlertTitle:(NSString*)title andMessenge:(NSString*)messenge{
    UIAlertController *alertControlelr = [UIAlertController alertControllerWithTitle:title message:messenge preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertControlelr addAction:actionOK];
    [self presentViewController:alertControlelr animated:YES completion:nil];
    
}
- (void) changePlaylistNameALert:(NSDictionary*)playlist atIndex:(int)index{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Rename Playlist" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        
        UITextField *textField = alertController.textFields[0];
        if ([textField.text isEqualToString:@""]) [self displayAlertTitle:@"Error" andMessenge:@"Playlist name is not allowed to be empty"];
        else{
            if ([self playlistNameExist:textField.text]) [self displayAlertTitle:@"Playlist already exists" andMessenge:@"Please try again"];
            else
                 [self renamePlaylist:playlist atIndex:index withName:textField.text];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action){
        
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    [self presentViewController:alertController animated:YES completion:^{
        self.tableView.editing = false;
    }];

}


- (void) addNewPlaylist:(NSString*)name{
    if(![name isEqualToString:@""]){
        
        NSDictionary *playlist = @{@"name":name};
        [playlists addObject:playlist];
        
        [[NSUserDefaults standardUserDefaults]setObject:playlists forKey:@"myPlaylists"];
        [_tableView reloadData];
    }

}

- (void) renamePlaylist:(NSDictionary*)playlist atIndex:(int)index withName:(NSString*)name{
    if (![name isEqualToString:@""]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:playlist];
        dic[@"name"] = name; 
        
        [playlists removeObject:playlist];
        [playlists insertObject:dic atIndex:index];
        
        [[NSUserDefaults standardUserDefaults]setObject:playlists forKey:@"myPlaylists"];
        [_tableView reloadData];
    }
   
    
}


@end
