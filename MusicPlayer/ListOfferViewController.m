//
//  ListOfferViewController.m
//  CloudMusicWorld
//
//  Created by BMX-05 on 5/7/16.
//  Copyright © 2016 BMX-05. All rights reserved.
//

#import "ListOfferViewController.h"
#import <AdSupport/AdSupport.h>
#import "OfferTableViewCell.h"
#import <UIImageView+AFNetworking.h>
#import "MBProgressHUD.h"

@interface ListOfferViewController ()
{
    NSMutableArray *arrOffers;
    AppDelegate *appDelegate;
    NSString *stringUrl;
    UIView *viewBG;
}
@end

@implementation ListOfferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Special Offers",nil)];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.opaque = YES;
    arrOffers = [[NSMutableArray alloc]init];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Done",nil)]
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(btnDonePressed)];
    [self.navigationItem setLeftBarButtonItem:btnDone];
    
    UIBarButtonItem *btnRefresh = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Refresh",nil)]
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(btnRefreshPressed)];
    [self.navigationItem setRightBarButtonItem:btnRefresh];
    
    [_btnActive setTitle:[NSString stringWithFormat:NSLocalizedString(@"Active Pro Version",nil)] forState:UIControlStateNormal];
    
    [_tableView registerNib:[UINib nibWithNibName:@"OfferTableViewCell" bundle:nil] forCellReuseIdentifier:@"OfferTableViewCell"];
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    refreshControl.tintColor = [UIColor colorWithRed:1 green:0.047 blue:0.6313 alpha:1];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    [self.tableView sendSubviewToBack:refreshControl];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture)];
    
    viewBG = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height)];
    viewBG.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    viewBG.backgroundColor = [UIColor blackColor];
    viewBG.alpha = 0.6;
    [viewBG addGestureRecognizer:tapGesture];
    [self.navigationController.view addSubview:viewBG];
    viewBG.hidden = YES;
    
    self.viewInstallApp.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width *8/10, [UIScreen mainScreen].bounds.size.height *6/10);
    
    self.viewInstallApp.center = CGPointMake(self.navigationController.view.frame.size.width/2, self.navigationController.view.frame.size.height/2);
    self.viewInstallApp.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.viewInstallApp.layer.cornerRadius = 5;
    self.viewInstallApp.clipsToBounds = YES;
    
    self.btnCancel.frame = CGRectMake(self.viewInstallApp.frame.size.width / 2 - 120, self.btnCancel.frame.origin.y, 110, 44);
    self.btnInstall.frame = CGRectMake(self.viewInstallApp.frame.size.width / 2 + 10, self.btnInstall.frame.origin.y, 110, 44);
    
    self.imageApp.layer.cornerRadius = 10;
    self.imageApp.clipsToBounds = YES;
    
    self.btnInstall.layer.cornerRadius = 5;
    self.btnInstall.clipsToBounds = YES;
    self.btnCancel.layer.cornerRadius = 5;
    self.btnCancel.clipsToBounds = YES;
    
    [self.navigationController.view addSubview:self.viewInstallApp];
    self.viewInstallApp.hidden = YES;
    
    [self loadListOffer];
    // Do any additional setup after loading the view from its nib.
}

- (void)tapGesture{
    self.viewInstallApp.hidden = YES;
    viewBG.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    MySingleton *mySingleton = [MySingleton sharedInstance];
    mySingleton.restrictRotation = YES;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"ListOfferView"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)refreshView:(UIRefreshControl*)refresh{
    arrOffers = [[NSMutableArray alloc]init];
    [self.tableView reloadData];
    [self loadListOffer];
    [refresh endRefreshing];
}

- (void)btnRefreshPressed{
    arrOffers = [[NSMutableArray alloc]init];
    [self.tableView reloadData];
    [self loadListOffer];
}

- (void)btnDonePressed{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadListOffer{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    UIDevice *deviceInfo = [UIDevice currentDevice];
    
    NSString *model = deviceInfo.model;
    NSString *os_version = deviceInfo.systemVersion;
    
    NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                         APPID, @"app_id",
                         @"ios", @"platform",
                         os_version, @"os_version",
                         idfaString, @"device_id",
                         model, @"device_model",
                         nil];
    
    NSError *error;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSString *strUrl = [NSString stringWithFormat:@"https://%@/offers",Domain];
    NSURL *urlRequest = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    [request setHTTPBody:postData];
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            if (response)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                });
                NSMutableArray *arrayResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *dict = (NSMutableDictionary *)arrayResponse;
                arrOffers = [dict objectForKey:@"offers"];
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:self waitUntilDone:YES];
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            });
        }
    }];
    [postDataTask resume];
    
}

- (IBAction)btnCheckProVersion:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    UIDevice *deviceInfo = [UIDevice currentDevice];
    NSString *deviceName = deviceInfo.name;
    NSString *model = deviceInfo.model;
    NSString *os_version = deviceInfo.systemVersion;
    
    NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                         APPID, @"app_id",
                         version, @"app_version",
                         @"ios", @"platform",
                         os_version, @"os_version",
                         idfaString, @"device_id",
                         model, @"device_model",
                         deviceName, @"device_name",
                         bundleIdentifier, @"app_bundle_id",
                         nil];
    
    NSError *error;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSString *strUrl = [NSString stringWithFormat:@"https://%@/pro",Domain];
    NSURL *urlRequest = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            if (response)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                });
                NSLog(@"dataAsString %@", [NSString stringWithUTF8String:[data bytes]]);
                NSMutableArray *arrayResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSDictionary*dict = (NSMutableDictionary *)arrayResponse;
                
                BOOL isPro = [[dict objectForKey:@"pro"]boolValue];
                long remainDay = [[dict objectForKey:@"remain_days"]longValue];
                
                
//                NSDate *date = [NSDate date];
                
                if (!isPro) {
                    NSString *message = [NSString stringWithFormat:@"You are not eligible to use the PRO version. Please complete the missions to activate the PRO version."];
                    UIAlertController *viewMessage = [UIAlertController alertControllerWithTitle:@"Sorry!"
                                                                                              message:message
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction
                                                   actionWithTitle:@"OK"
                                                   style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action)
                                                   {
                                                       
                                                   }];
                    
                    [viewMessage addAction:cancelAction];
                    [self presentViewController:viewMessage animated:YES completion:nil];
                }else{
                    NSString *title = @"Congratulations!";
                    NSString *message = [NSString stringWithFormat:@"You have successfully activated the PRO version. You have %ld days remain using Pocket Music PRO version.",remainDay];
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                             message:message
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction
                                                   actionWithTitle:@"OK"
                                                   style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action)
                                                   {
                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                   }];
                    
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"iNestAppPro" object:nil];
                }
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            });
            NSString *message = [NSString stringWithFormat:@"Data failed to load. Please check your Internet connection and try again!!!"];
            UIAlertController *viewMessageError = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                      message:message
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               //
                                           }];
            
            [viewMessageError addAction:cancelAction];
            [self presentViewController:viewMessageError animated:YES completion:nil];
        }
    }];
    [postDataTask resume];
}

- (void)showViewInstallApp:(id)obj{
    self.lbNameApp.text = [obj objectForKey:@"name"];
    NSString *embedHTML = [obj objectForKey:@"requirement"];
    [self.infoView loadHTMLString:embedHTML baseURL:nil];
    [self.imageApp setImageWithURL:[NSURL URLWithString:[obj objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"iconApp"]];
    stringUrl = [obj objectForKey:@"url"];
    self.viewInstallApp.hidden = NO;
    viewBG.hidden = NO;
}

- (IBAction)btnCancelPressed:(id)sender {
    self.viewInstallApp.hidden = YES;
    viewBG.hidden = YES;
}

- (IBAction)btnInstallPressed:(id)sender {
    self.viewInstallApp.hidden = YES;
    viewBG.hidden = YES;
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark UITableView Data Source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id obj = [arrOffers objectAtIndex:indexPath.row];
    [self showViewInstallApp:obj];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrOffers.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *stringIdentifier = @"OfferTableViewCell";
    OfferTableViewCell *cell = (OfferTableViewCell*)[tableView dequeueReusableCellWithIdentifier:stringIdentifier];
    if (!cell) {
        cell = [[OfferTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringIdentifier];
    }
    
    id obj = [arrOffers objectAtIndex:indexPath.row];
    cell.lbNameApp.text = [obj objectForKey:@"name"];
    [cell.imageApp setImageWithURL:[NSURL URLWithString:[obj objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"iconApp"]];
    BOOL isCompleted = [[obj objectForKey:@"completed"]boolValue];
    
    if (isCompleted) {
        UILabel *lbText;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            lbText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
            lbText.font = [UIFont boldSystemFontOfSize:16];
        }else{
            lbText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 30)];
            lbText.font = [UIFont boldSystemFontOfSize:12];
        }
        lbText.text = @"Completed";
        lbText.textAlignment = NSTextAlignmentCenter;
        lbText.layer.cornerRadius = 5;
        lbText.clipsToBounds = YES;
        lbText.textColor = [UIColor whiteColor];
        lbText.backgroundColor = [UIColor colorWithRed:0 green:0.5019 blue:0 alpha:1];
        cell.accessoryView = lbText;
    }else{
        cell.accessoryView = nil;
    }
    
    return cell;
}

#pragma mark NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:Domain]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
