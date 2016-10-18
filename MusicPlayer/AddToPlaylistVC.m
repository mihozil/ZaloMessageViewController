//
//  AddToPlaylistVC.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/5/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "AddToPlaylistVC.h"

@interface AddToPlaylistVC ()

@end

@implementation AddToPlaylistVC{
    NSMutableArray *playlists;
    NSIndexPath *currentIndexpath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_tableView registerNib:[UINib nibWithNibName:playlistCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:playlistCellIdentifier];
    
    playlists = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"myPlaylists"]];
    if (!playlists) playlists = [[NSMutableArray alloc]init];
    currentIndexpath = nil;
    [self initVC];
    [self addShadow];
}
- (void) initVC{
    _tableView.separatorColor = [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
}
- (void) addShadow{
    _navigationBar.layer.shadowColor = [[UIColor colorWithRed:178 green:178 blue:178 alpha:1]CGColor];
    _navigationBar.layer.shadowOffset = CGSizeMake(0.0, 3);
    _navigationBar.layer.shadowOpacity = 0.8;
    _navigationBar.layer.masksToBounds = NO;
    _navigationBar.layer.shouldRasterize = YES;
    
    UIColor *color = [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
    [_navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:color   ,
                                                                      NSFontAttributeName:[UIFont fontWithName:@"SFUIDisplay-Semibold" size:17]}];
}

- (void)viewDidAppear:(BOOL)animated{
    [_tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return playlists.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.row == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"playlistCell"];
        }
        cell.imageView.image = [UIImage imageNamed:@"plus"];
        return cell;
    }else{
        CustomPlaylistCell*cell = (CustomPlaylistCell*)[tableView dequeueReusableCellWithIdentifier:playlistCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[CustomPlaylistCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:playlistCellIdentifier];
        }
        NSDictionary  *dic = playlists[indexPath.row-1];
        
        if (dic[@"image"])
            [cell.imgView setImageWithURL:[NSURL URLWithString:dic[@"image"]] placeholderImage:[UIImage imageNamed:@"musicplay.png"]];
        else cell.imgView.image= [UIImage imageNamed:@"musicplay.png"];
        
        cell.playlistLabel.text = dic[@"name"];
        cell.detailLabel.text = [NSString stringWithFormat:@"%lu Videos",[dic[@"items"] count]];
        [cell.tickImg setHidden:YES];
        return cell;
    }
    
}
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row>0)
        [self animatedSelectRow:indexPath];
    else [self addPlaylistAlert];
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) addPlaylistAlert{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New Playlist" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        
        UITextField *textField = alertController.textFields[0];
        [self addNewPlaylist:textField.text];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action){
        
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void) addNewPlaylist:(NSString*)name{
    if(![name isEqualToString:@""]){
        NSDictionary *playlist = @{@"name":name};
        [playlists addObject:playlist];
        [[NSUserDefaults standardUserDefaults]setObject:playlists forKey:@"myPlaylists"];
        [_tableView reloadData];
    }
    
}
- (void) animatedSelectRow:(NSIndexPath*)indexPath{
        [self deSelectCell:currentIndexpath];
        
        if (indexPath!=currentIndexpath)
            [self selectCell:indexPath];
        else currentIndexpath = nil;
    
}
- (void) deSelectCell:(NSIndexPath*)indexPath{
    if (currentIndexpath){
        CustomPlaylistCell*cell = (CustomPlaylistCell*)[_tableView cellForRowAtIndexPath:indexPath];
        if (cell){
            [cell.tickImg setHidden:YES];
        }
    }
}
- (void) selectCell:(NSIndexPath*)indexPath{
    CustomPlaylistCell*cell = (CustomPlaylistCell*)[_tableView cellForRowAtIndexPath:indexPath];
    if (cell){
        [cell.tickImg setHidden:NO];
    }
    currentIndexpath= indexPath;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (IBAction)onDone:(id)sender {
    if (currentIndexpath){
        NSDictionary *playlist = playlists[currentIndexpath.row-1];
        [self addItemToPlaylist:playlist];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) addItemToPlaylist:(NSDictionary*)playlist{
    NSMutableDictionary *updatedPlaylist = [NSMutableDictionary dictionaryWithDictionary:playlist];
    
    if (!updatedPlaylist[@"items"]){
        [updatedPlaylist setObject:@[_item] forKey:@"items"];
    }
    else{
        NSMutableArray *items = [NSMutableArray arrayWithArray:updatedPlaylist[@"items"]];
        [items removeObject:_item];
        [items addObject:_item];
        [updatedPlaylist removeObjectForKey:@"items"];
        [updatedPlaylist setObject:items forKey:@"items"];
    }
    
    if (!updatedPlaylist[@"image"]){
         NSString *path = _item[@"snippet"][@"thumbnails"][@"high"][@"url"];
        updatedPlaylist[@"image"] = path;
    }
    
    [playlists removeObject:playlist];
    [playlists insertObject:updatedPlaylist atIndex:currentIndexpath.row-1];
    [[NSUserDefaults standardUserDefaults]setObject:playlists forKey:@"myPlaylists"];
    
    
}
- (void) updatePlaylistImage:(NSDictionary*)updatedPlaylist{
   
    
    
}
@end
