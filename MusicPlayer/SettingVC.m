//
//  SettingVC.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/7/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "SettingVC.h"
#import <MessageUI/MessageUI.h>
#import "ListOfferViewController.h"

@interface SettingVC ()

@end

@implementation SettingVC{
    NSMutableArray *tableItems;
    MFMailComposeViewController *mailController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     tableItems =[NSMutableArray arrayWithArray:@[@"✏️ Review",@"✒️ Feedback"]];
    
    _tableView.separatorColor = [UIColor clearColor];
    [self initVC];
    [self addShadow];
    
    [[IAPHelper sharedHelper]requestProducts];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAds) name:@"Purchased" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedAd) name:@"receivedAds" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(productsLoadedNewDevice:) name:kProductsLoadedNotification object:nil];
    
}
- (BOOL) isPurchased{
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:@"Purchase"];
    NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return [arr[0] intValue];
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
    [tracker set:kGAIScreenName value:@"SettingVC"];
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
    
    _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-bannerView.frame.size.height);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tableItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = tableItems[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
    cell.textLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:15];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case 0:
            [self writeReview];
            break;
        
        case 1:
            [self feedBack];
            break;
            
        case 2:
            [self proVersion]; // remove ads
            break;
            
        case 3:
            [self restorePurchase];
            break;
            
        default:
            break;
    }
    
}
- (void) writeReview{
    [iRate sharedInstance].ratedThisVersion = YES;
    [[iRate sharedInstance] openRatingsPageInAppStore];
    
    
}
- (void) feedBack{
    if (![MFMailComposeViewController canSendMail]) {
        // do something
        return;
    }
    mailController = [[MFMailComposeViewController alloc]init];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:@"MusicPlayer - Feedback"];
    [mailController setToRecipients:@[@"help.bmx2015@gmail.com"]];
    [mailController setMessageBody:@"Music Player" isHTML:NO];
    [self presentViewController:mailController animated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
                [MySingleton sharedInstance].playingView.hidden = YES;
        });
        
    }];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [mailController dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MySingleton sharedInstance].playingView.hidden = NO;
        });
        
    }];
    
}

- (void) proVersion{
    if (([IAPHelper sharedHelper].products.count>0) && ([IAPHelper sharedHelper].purchasedProducts.count==0 )){
        [[IAPHelper sharedHelper] buyProductIdentifier:[[IAPHelper sharedHelper].products firstObject]];
    }

}

- (void) restorePurchase{
    [[IAPHelper sharedHelper]restoreCompletedTransaction];
}
//- (void) specialOffers{
//    ListOfferViewController *offerVC = [[ListOfferViewController alloc]initWithNibName:@"ListOfferViewController" bundle:nil];
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:offerVC];
//    [self presentViewController:nav animated:YES completion:nil];
//}

- (void)receivedAd{

}

- (void)removeAds{
    NSData *_data = [[NSUserDefaults standardUserDefaults] objectForKey:@"Purchase"];
    NSMutableArray *_dataArchive = [NSKeyedUnarchiver unarchiveObjectWithData:_data];
    if (_dataArchive.count>0)
    {
        BOOL Purchase = YES;
        NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithBool:Purchase], nil];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:arr]
                                                  forKey:@"Purchase"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // remove add
    MySingleton *mySingleton = [MySingleton sharedInstance];
    [mySingleton.bannerView removeFromSuperview];
    mySingleton.bannerView = nil;
    // update tableview
    [_bottomLayout setConstant:mySingleton.bannerView.frame.size.height];
    
    if ([tableItems count]>2){
        [tableItems removeObjectAtIndex:4];
        [tableItems removeObjectAtIndex:3];
        [tableItems removeObjectAtIndex:2];
    }
    
    [_tableView reloadData];
    
}

-(void)productsLoadedNewDevice:(NSNotification *)notification
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"Purchase"];
    NSMutableArray *arrArchive = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSNumber *number = [arrArchive objectAtIndex:0];
    BOOL isPurchase = [number boolValue];
    
    if ([IAPHelper sharedHelper].products.count > 0)
    {
        if(([IAPHelper sharedHelper].products.count > 0) && ([IAPHelper sharedHelper].purchasedProducts.count == 0) && (!isPurchase))
        {
            if (![tableItems containsObject:@"✨ Remove Ads"]){
                [tableItems addObject:@"✨ Remove Ads"];
                [tableItems addObject:@"👌 Restore Purchase"];
                
                 [_tableView reloadData];
            }
        }
        
       
    }
}


@end
