//
//  AppDelegate.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/22/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "AppDelegate.h"
#import "IOSRequest.h"
#import <AVFoundation/AVFoundation.h>
#import "MySingleton.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "VideoPlayingViewController.h"
#import "MPMoviePlayerController+BackgroundPlayback.h"
#import <iRate/iRate.h>
#import "Reachability.h"
#import <MessageUI/MessageUI.h>

@interface AppDelegate ()
@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, strong) UIView *playingView;
@end

@implementation AppDelegate{
    NSMutableArray *items;
    XCDYouTubeVideoPlayerViewController *videoVC;
    UITapGestureRecognizer *tap;
    UIPanGestureRecognizer *pan;
    CGPoint startPan, endPan;
    UIAlertController *alertLostInternet;
    
    Reachability *internetReachableFoo;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    [self becomeFirstResponder];
    
    [VideoPlayingViewController shareInstance].modalPresentationStyle = UIModalPresentationOverCurrentContext;

    [self getPlaylistData];
    [self setRandomRepeat];
    
    [self initBannerAds];
    [self initIntestitialAds];
    [self testInternetConnection];
    
    [self createPlayingView];
    
    [self initGoogleAnalytic];
    
    [self initilizeAppRate];
    
      [[NSUserDefaults standardUserDefaults]setObject:@"Auto" forKey:@"videoquality"];
    
    [self createNotification];
    [self initMediaPlayingInfoCenter];
    
    return YES;
}

- (void) initMediaPlayingInfoCenter {
    [[MPRemoteCommandCenter sharedCommandCenter].playCommand addTarget:self action:@selector(remoteNextPrevTrackCommandReceived:)];
    [[MPRemoteCommandCenter sharedCommandCenter].nextTrackCommand addTarget:self action:@selector(remoteNextPrevTrackCommandReceived:)];
    [[MPRemoteCommandCenter sharedCommandCenter].previousTrackCommand addTarget:self action:@selector(remoteNextPrevTrackCommandReceived:)];
    
    [[MPRemoteCommandCenter sharedCommandCenter].togglePlayPauseCommand setEnabled:YES];
    [[MPRemoteCommandCenter sharedCommandCenter].playCommand setEnabled:YES];
    [[MPRemoteCommandCenter sharedCommandCenter].pauseCommand setEnabled:YES];
    [[MPRemoteCommandCenter sharedCommandCenter].nextTrackCommand setEnabled:YES];
    [[MPRemoteCommandCenter sharedCommandCenter].previousTrackCommand setEnabled:YES];
    [[MPRemoteCommandCenter sharedCommandCenter].seekForwardCommand setEnabled:YES];
    [[MPRemoteCommandCenter sharedCommandCenter].seekBackwardCommand setEnabled:YES];
}

- (void) remoteNextPrevTrackCommandReceived:(id)sender{
}

- (void) routeChange:(NSNotification*) noti{
    NSNumber *reason = [noti.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey];
    if ([reason intValue] == AVAudioSessionRouteChangeReasonNewDeviceAvailable){
        // plugin
        
        int pauseState = [[[NSUserDefaults standardUserDefaults]objectForKey:@"pause"]intValue];
        if (pauseState ==1)
            if (![MySingleton sharedInstance].pauseTouch)
               [[VideoPlayingViewController shareInstance]onPause];
        
        
    }else if ([reason intValue] == AVAudioSessionRouteChangeReasonOldDeviceUnavailable){
        int pauseState = [[[NSUserDefaults standardUserDefaults]objectForKey:@"pause"] intValue];
        if (pauseState ==0) {
            // plug out; if playing will pause
            [[VideoPlayingViewController shareInstance] onPause];
            [MySingleton sharedInstance].pauseTouch = NO;
        }
        
    }
}

- (void) initGoogleAnalytic{
    NSError *configError;
    [[GGLContext sharedInstance]configureWithError:&configError];
    NSAssert(!configError, @"Error configuring Google services: %@", configError);
    
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;
    gai.logger.logLevel = kGAILogLevelVerbose;
    
}

- (void)testInternetConnection
{
    __weak typeof(self) weakself = self;
    __weak typeof (UIAlertController) *weakAlert = alertLostInternet;
    
    
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself requestAds];
            [weakAlert dismissViewControllerAnimated:NO completion:nil];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"InternetConnected" object:nil];
            [[NSUserDefaults standardUserDefaults]setObject:@(1) forKey:@"internet"];
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults]setObject:@(0) forKey:@"internet"];
            [weakself alertLostConnection];
        });
    };
    [internetReachableFoo startNotifier];
}
- (void) alertLostConnection{

    UIViewController *currentVC = self.window.rootViewController.presentedViewController;
    if (!currentVC) currentVC = self.window.rootViewController;
    
    alertLostInternet = [UIAlertController alertControllerWithTitle:@"Internet Error" message:@"Please check the connection again" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertLostInternet addAction:okAction];
    [currentVC presentViewController:alertLostInternet animated:YES completion:nil];
}

- (void) createNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productRestore:) name:kProductRestoredNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productLoadFailed:) name:kProductsLoadedFailNotification object: nil];
}
- (void) initilizeAppRate{
    [iRate sharedInstance].applicationBundleID = @"wrr.MusicPlayer";
    [iRate sharedInstance].appStoreID = [APPID integerValue]; // take care of this. integer value ? 
    [iRate sharedInstance].usesUntilPrompt = 2;
    [iRate sharedInstance].daysUntilPrompt = 0;
    
}
- (void) initBannerAds{
//    float width = [UIScreen mainScreen].bounds.size.width;
    MySingleton *mySingleton = [MySingleton sharedInstance];
    
    mySingleton.bannerView = [[GADBannerView alloc]init];
    mySingleton.bannerView.adUnitID = BANNER_ID;
    mySingleton.bannerView.rootViewController = self.window.rootViewController;
    mySingleton.bannerView.backgroundColor = [UIColor whiteColor];
    
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height;
    if (width>height) {
        float mid = width;width=height;height=mid;
    }
    
    float adsHeight;
    if (IDIOM == IPAD) adsHeight = 90;
    else adsHeight = 50;
    mySingleton.bannerView.frame = CGRectMake(0, height-49-adsHeight, width, adsHeight);
    
}
- (void) requestAds{
    GADRequest *request = [GADRequest request];
    [[MySingleton sharedInstance].bannerView loadRequest:request];
}

- (void) initIntestitialAds{
    MySingleton *mySingleton = [MySingleton sharedInstance];
    mySingleton.intestitial = [[GADInterstitial alloc]initWithAdUnitID:INTERSTITIAL_ID];
    mySingleton.intestitial.delegate = self;
    GADRequest *request = [GADRequest request];
    [mySingleton.intestitial loadRequest:request];
}
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    
}
#pragma mark Purchase

-(void)productsLoaded:(NSNotification *)notification
{
    
}

-(void)productPurchased:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *productIdentifier = (NSString*) notification.object;
    if([productIdentifier isEqualToString:purchaseIdentifier])
    {
        BOOL isPurchase = YES;
        NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithBool:isPurchase], nil];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:arr]
                                                  forKey:@"Purchase"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Purchased" object:nil];
    }
    // create product identifier in store 
}

-(void)productRestore:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *productIdentifier = (NSString*) notification.object;
    if([productIdentifier isEqualToString:purchaseIdentifier])
    {
        BOOL isPurchase = YES;
        NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithBool:isPurchase], nil];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:arr]
                                                  forKey:@"Purchase"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Purchased" object:nil];
    }
}

-(void)productPurchaseFailed:(NSNotification *)notification
{
    SKPaymentTransaction *transaction = (SKPaymentTransaction*) notification.object;
    if (transaction.error.code != SKErrorPaymentCancelled) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase failed" message:transaction.error.localizedDescription
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

-(void)productLoadFailed:(NSNotification *)notification
{
    NSError*err=(NSError*)notification.object;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:err.localizedDescription delegate:nil
                                          cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void) createPlayingView{
    
    float videoWidth = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) ;
    float videoHeight = videoWidth/16*9;
    
    _playingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, videoWidth, videoHeight)];
    _playingView.backgroundColor = [UIColor colorWithRed:24/255.0 green:25/255.0 blue:27/255.0 alpha:1];
    [self.window addSubview:_playingView];
    
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap)];
    tap.delegate = self;
    [_playingView addGestureRecognizer:tap];
    
    pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPan:)];
    pan.minimumNumberOfTouches = 1;
    pan.delegate = self;
    [_playingView addGestureRecognizer:pan];
    
    MySingleton *mySingleton = [MySingleton sharedInstance];
    mySingleton.playingView = _playingView;
}

#pragma onPan

- (void) onPan:(id) sender{
    
    float screenWidth = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if ([MySingleton sharedInstance].playingView.frame.size.width >= screenWidth) return;

    
    if ([sender state] == UIGestureRecognizerStateBegan){
        
        if ([self.window.rootViewController.presentedViewController isKindOfClass:[UIAlertController class]])
            [self.window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        
        startPan.y = [sender locationInView:self.window.rootViewController.view].y - [self smallVideoY];
        [VideoPlayingViewController shareInstance].appearBottom = YES;
        [VideoPlayingViewController shareInstance].startPan = startPan;
        [VideoPlayingViewController shareInstance].view.alpha = 0;
        
        UIViewController *currentView = self.window.rootViewController.presentedViewController;
        if ([currentView isKindOfClass:[UIAlertController class]])  currentView = nil;
        if (!currentView) currentView = self.window.rootViewController;
        
        [currentView presentViewController:[VideoPlayingViewController shareInstance] animated:NO completion:^{
            
            [[VideoPlayingViewController shareInstance]createPlayingControl];
            [[VideoPlayingViewController shareInstance]updatePlayingControl];
            [[VideoPlayingViewController shareInstance]addDismissBt];
            
            [VideoPlayingViewController shareInstance].didDismiss = NO;
            [[VideoPlayingViewController shareInstance]addGesturetoVideo];
            [VideoPlayingViewController shareInstance].controlBar.hidden = YES;
            
            [MySingleton sharedInstance].restrictRotation = NO;
            
        }];
        
    } else if ([sender state] == UIGestureRecognizerStateEnded){
        [[VideoPlayingViewController shareInstance] endPan];

        
        
    }else{
        [[VideoPlayingViewController shareInstance]updateFromPan:[sender locationInView:self.window.rootViewController.view]];
    }
    
    [[MySingleton sharedInstance].playingView bringSubviewToFront:[MySingleton sharedInstance].videoPlayerVC.moviePlayer.view];
    
}

- (BOOL) isPurchased{
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:@"Purchase"];
    NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return [arr[0] intValue];
}
- (float) smallVideoY{
    float screenWidth = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    float screenHeight = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    float newWidth = screenWidth /2.5;
    float newHeight = newWidth/16*9;
    float adsHeight;
    if (IDIOM==IPAD) adsHeight = 90;
    else adsHeight = 50;
    if ([self isPurchased]) adsHeight=0;
    
    return screenHeight-newHeight-50- adsHeight;
}


- (void) onTap{
    // when video go from small screen to big screen: need to addgesture to video
    // go from small to big
    
    MySingleton *mySingleton = [MySingleton sharedInstance];
    UIView *playingView = mySingleton.playingView;
    float screenWidth = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if (playingView.frame.size.width >= screenWidth) return;
    
    if ([self.window.rootViewController.presentedViewController isKindOfClass:[UIAlertController class]])
       [self.window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];

    
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = width/16*9;
    
    [UIView animateWithDuration:0.2 animations:^{
        playingView.frame = CGRectMake(0, 0, width, height);
          [[VideoPlayingViewController shareInstance]updateActivityIndicatorPosition];
    } completion:^(BOOL finish){
    
    }];
    
    UIViewController *currentView = self.window.rootViewController.presentedViewController;
    if ([currentView isKindOfClass:[UIAlertController class]])  currentView = nil;
    if (!currentView) currentView = self.window.rootViewController;
    
    mySingleton.restrictRotation = NO;  
    
    [currentView presentViewController:[VideoPlayingViewController shareInstance] animated:NO completion:^{
        [[VideoPlayingViewController shareInstance]createPlayingControl];
        [[VideoPlayingViewController shareInstance]updatePlayingControl];
        [[VideoPlayingViewController shareInstance]addDismissBt];
        
        [VideoPlayingViewController shareInstance].didDismiss = NO;
        [[VideoPlayingViewController shareInstance]addGesturetoVideo];
        
    }];
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    MySingleton *mySingleton = [MySingleton sharedInstance];
    videoVC = mySingleton.videoPlayerVC;
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            [[VideoPlayingViewController shareInstance] onPause];
            break;
            
        case UIEventSubtypeRemoteControlPause:
             [[VideoPlayingViewController shareInstance] onPause];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [[VideoPlayingViewController shareInstance] onNext] ;
            break;
            
        case UIEventSubtypeRemoteControlTogglePlayPause:
            [[VideoPlayingViewController shareInstance]onPause];
            break;
            
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [[VideoPlayingViewController shareInstance]  onBack];
            
            break;
        default:
            break;
    }
}

- (void) play{
    MySingleton *mySingleton = [MySingleton sharedInstance];
    videoVC = mySingleton.videoPlayerVC;
    [videoVC.moviePlayer play];
}


- (void) updateData:(NSDictionary *)item{
    
    NSString *id1 = item[@"snippet"][@"resourceId"][@"videoId"];
    [[NSUserDefaults standardUserDefaults]setObject:id1 forKey:@"idVideo"];
    
    [[NSUserDefaults standardUserDefaults] setObject:item[@"snippet"][@"title"] forKey:@"titleVideo"];
    
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    MySingleton *mySingleton = [MySingleton sharedInstance];
    
    if(mySingleton.restrictRotation)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskAllButUpsideDown;
}
#else
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    MySingleton *mySingleton = [MySingleton sharedInstance];
    
    
    
    if(mySingleton.restrictRotation){
        
        return UIInterfaceOrientationMaskPortrait;
    }
    else{
    
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
}
#endif

- (void) setRandomRepeat{
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"random"];
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"repeat"];
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"pause"];
}

- (void) getPlaylistData{
    [IOSRequest requestPath:@"http://bestapp365.com/playlistdata" onCompletion:^(NSDictionary*json, NSError*error){
        if (!error){
            NSArray *playLists = json[@"data"];
            [[NSUserDefaults standardUserDefaults]setObject:playLists forKey:@"playlists"];
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
//    NSLog(@"app did resign active");
//    [MySingleton sharedInstance].videoPlayerVC.moviePlayer.backgroundPlaybackEnabled = NO;
//    
//        NSLog(@"videoVC: %@",[MySingleton sharedInstance].videoPlayerVC);
    int pauseState = [[[NSUserDefaults standardUserDefaults]objectForKey:@"pause"] intValue];
    if (pauseState ==0){
       [[MySingleton sharedInstance].videoPlayerVC.moviePlayer play];
        [self.songInfo setObject:[NSNumber numberWithFloat:[MySingleton sharedInstance].videoPlayerVC.moviePlayer.currentPlaybackTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];

    }
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    int pauseState = [[[NSUserDefaults standardUserDefaults]objectForKey:@"pause"] intValue];
    
    if (pauseState == 0)
     [[MySingleton sharedInstance].videoPlayerVC.moviePlayer play];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//    NSLog(@"app did become active");
    
//    [MySingleton sharedInstance].videoPlayerVC.moviePlayer.backgroundPlaybackEnabled = YES;
    
//    NSLog(@"videoVC: %@",[MySingleton sharedInstance].videoPlayerVC);
//    [[MySingleton sharedInstance].videoPlayerVC.moviePlayer play];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

@end
