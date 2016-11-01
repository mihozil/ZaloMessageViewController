
//  VideoPlayingViewController.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/23/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "VideoPlayingViewController.h"
#import "IOSRequest.h"
#import "MySingleton.h"
#import "MySlider.h"
#import "MPMoviePlayerController+BackgroundPlayback.h"
#import "MyActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

float const controlHeight = 64;

@interface VideoPlayingViewController ()


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

@end

@implementation VideoPlayingViewController{
    

    float videoWidth, videoHeight;
    
    NSMutableArray *items;
    UIButton *pauseBt,*nextBt,*backBt,*randomBt,*repeatBt,*zoomBt,*dismissBt, *qualityBt;
    UIView *transparentView;
    MySlider *slider;
    NSTimer *sliderTimer;
    UITapGestureRecognizer *tap, *tap2;
    UIPanGestureRecognizer *pan;
    int disappearCount;
    float currentPlaying;
    UILabel *runningTime,*endTime;
    UIAlertController *alertController;
    NSDictionary *addedItem, *currentItem;
    CGPoint endPan;
    MyActivityIndicatorView *activityIndicatorView;
    MyActivityIndicatorView *tableActivityIndicator;
    
    NSMutableDictionary *songInfo;
    
    float sliderEndTime, unupdatedVideoTime;
    int timerCount ;
    BOOL saveHidden;
    
    int trialCount ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    trialCount=0;
    
    [_tableView registerNib:[UINib nibWithNibName:simpleCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:simpleCellIdentifier];
    [self initBt];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAds) name:@"Purchased" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didConnectInternet) name:@"InternetConnected" object:nil];
    
    unupdatedVideoTime = -1;
     _tableView.separatorColor = [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
    
}
- (void) initBt{
    _playingListBt.layer.cornerRadius = 5;
    _playingListBt.layer.borderWidth = 0.5;
    _playingListBt.layer.borderColor = trueBlue.CGColor;
    _relatedBt.layer.cornerRadius = 5;
    _relatedBt.layer.borderWidth = 0.5;
    _relatedBt.layer.borderColor = trueBlue.CGColor;
    
}

- (void) addScreenTracking{
    id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
    [tracker set:kGAIScreenName value:@"VideoPlayingViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                   
}

- (void)viewWillAppear:(BOOL)animated{
    // this is for zoom video from small screen
//    [MySingleton sharedInstance].restrictRotation = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onOrientationChange) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];

    [self addScreenTracking];
    if (_appearBottom){
        [self appearFromBottom];
        _appearBottom = NO;
    }
    [self addAds];
    
}
- (void) appearFromBottom{
    
//    float screenWidth = MIN([UIScreen mainScreen].bounds.size.width,[[UIScreen mainScreen]bounds].size.height);
//    float screenHeight = MAX([UIScreen mainScreen].bounds.size.width,[[UIScreen mainScreen]bounds].size.height);
//    
//    float newWidth = screenWidth/2.5;
//    float newHeight = newWidth/16*9;
//    float adsHeight;
//    if (IDIOM==IPAD) adsHeight = 90;
//    else adsHeight = 50;
//    if ([self isPurchased]) adsHeight=0;
//    float newY = screenHeight-newHeight-50- adsHeight - ((screenWidth/16*9) - newHeight);
//    self.view.frame =  CGRectMake(screenWidth-newWidth, newY, screenWidth, screenHeight);
    
}

- (void) addAds{
    MySingleton *mySingleton = [MySingleton sharedInstance];
    GADBannerView *bannerView = mySingleton.bannerView;
    
    float bannerY = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) - bannerView.frame.size.height;
    
    bannerView.frame = CGRectMake( bannerView.frame.origin.x, bannerY, bannerView.frame.size.width, bannerView.frame.size.height);
 
    [self.view addSubview:bannerView];
    [_bottomLayout setConstant:bannerView.frame.size.height];
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

//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onOrientationChange) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    [[UIDevice currentDevice]beginGeneratingDeviceOrientationNotifications];
    
    [_tableView registerClass:[UITableViewCell self] forCellReuseIdentifier:@"Cell"];
    
     items = [[NSUserDefaults standardUserDefaults]objectForKey:@"playlistitems"];
    [self reloadTableView];
    
}


+ (instancetype)shareInstance{
    static VideoPlayingViewController *shareInstance = nil;
    if (shareInstance == nil) {
        shareInstance = [[self alloc]init];
    }
    return shareInstance;
}

- (void)playDidPlaybackEnd:(NSNotification *)notification{
      [self stopActivityIndicator];
    
      int index = [self findCurrentPlayingIndex];
    
    MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    if (finishReason == MPMovieFinishReasonPlaybackError){
        [self alertVideoError:index];
    } else {
        [self updatePlayEnd:index];
    }
}

- (void) updatePlayEnd:(int)index{
  
    if (repeatBt.tag ==1){
        [self replay];
        
    } else  // 0
        [self automaticNext:index];
        
}
- (void) automaticNext:(int) index{
    if (randomBt.tag ==0) {
        [self playNext:(index+1)% items.count];
        
    }
    else {
        int newIndex;
        do {
            newIndex = arc4random()% items.count;
        } while (newIndex==index);
        [self playNext:newIndex];
    }
}

- (void) alertVideoError:(int) index{
    alertController = [UIAlertController alertControllerWithTitle:@"Error Playing Video" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        NSString *connection = [[NSUserDefaults standardUserDefaults]objectForKey:@"internet"];
        if ([connection intValue] == 1)
              [self automaticNext:index];
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:^{
         NSString *connection = [[NSUserDefaults standardUserDefaults]objectForKey:@"internet"];
        if ([connection intValue] == 1)
             [self performSelector:@selector(automaticDismissAlert:) withObject:[NSNumber numberWithInt:index] afterDelay:8];
        
    }];
}

- (void) automaticDismissAlert:(NSNumber*)index{
    
    if (alertController){
        [alertController dismissViewControllerAnimated:YES completion:^{
            [self automaticNext:[index intValue]];
        }];
    }
}

- (void) onOrientationChange{
    
    if (([[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeRight ) || ([[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeLeft)) {
        if ([self.presentedViewController isKindOfClass:[UIAlertController class]]) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [self willZoomOut];
        
    }else if ([[UIDevice currentDevice]orientation] == UIDeviceOrientationPortrait){
        [self willZoomIn];
    
    }
    [self updateActivityIndicatorPosition];
}
- (void) updateActivityIndicatorPosition{
    activityIndicatorView.center = CGPointMake(_playingView.frame.size.width/2, _playingView.frame.size.height/2);
}

- (void)viewDidAppear:(BOOL)animated{
    
    MySingleton *mySingleton = [MySingleton sharedInstance];
    _videoPlayerViewController = mySingleton.videoPlayerVC;
    [self initVC]; // add notification to orientation
    
//    [self createPlayingControl];
//    [self updatePlayingControl];
//    [self addDismissBt];
    
    [self pickedPlayingList];
    [self updateSongName];
    [self updateSongView];
    
    [self addBlackView];
    
    //    [self onOrientationChange]; // this is for in case vertical and it will change inmediately
    // take care of this, i might have to turn it on in some case
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    disappearCount = 1;
    [self performSelector:@selector(barDisappear) withObject:nil afterDelay:4];
    
    _videoPlayerViewController.moviePlayer.view.userInteractionEnabled = YES;
    [self updateIntestitialAds];
    

}


- (void) updateIntestitialAds{
    if ([self isPurchased]) return;
    
//    MySingleton *mySingleton = [MySingleton sharedInstance];
//    mySingleton.playingViewCount = (mySingleton.playingViewCount +1) % 9;
    
    if ([MySingleton sharedInstance].playingViewCount ==0){
        [MySingleton sharedInstance].playingViewCount =8;
        [self addIntestitialAds];
    }
}

- (void) addIntestitialAds{

    MySingleton *mySingleton = [MySingleton sharedInstance];
    if ([mySingleton.intestitial isReady]){
         mySingleton.intestitial.delegate = self;
        [mySingleton.intestitial presentFromRootViewController:self];
    }
        GADRequest *request = [GADRequest request];
        mySingleton.intestitial = [[GADInterstitial alloc]initWithAdUnitID:INTERSTITIAL_ID]; // take care of this, should not alloc init here
        [mySingleton.intestitial loadRequest:request];
}
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    
//    [self updateRotation];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if ((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight)) {
            dismissBt.hidden = YES;
        }
    
    if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight)){
        dismissBt.hidden = YES;
    }
}



- (void) updatePlayingControl{
    [self getEndingTime];
}

- (void) updateSongName{
    _titleVideo.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"titleVideo"];
}
- (void) updateSongView{
    
    _viewLb.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"viewCount"];
    _viewLb.text = [self rewriteNumber:_viewLb.text];
    _viewLb.text = [NSString stringWithFormat:@"%@ views",_viewLb.text];
}
- (NSString*) rewriteNumber:(NSString*)number{
    NSMutableString *str = [NSMutableString stringWithString:number];
    NSInteger originalLength = [str length];
    if (originalLength>3){
        [str insertString:@" " atIndex:originalLength-3];
    }
    if (originalLength>6){
        [str insertString:@" " atIndex:originalLength - 6];
    }
    if (originalLength>9){
        [str insertString:@" " atIndex:originalLength - 9];
    }
    return str;
    
}

- (void) didConnectInternet{
   
  if (_videoPlayerViewController)
      if (pauseBt.tag == 0) {
          
          switch (_videoPlayerViewController.moviePlayer.playbackState) {
              case MPMoviePlaybackStatePaused:
                  [_videoPlayerViewController.moviePlayer play];
                  break;
                  
              case MPMoviePlaybackStatePlaying:
                  [_videoPlayerViewController.moviePlayer play];
                  break;
            
              default:
                  [self playVideo];
                  break;
          }
    
    }
    
}

- (void) playVideo{
    
    if (!_videoPlayerViewController){
        MySingleton *mySingleton = [MySingleton sharedInstance];
        _videoPlayerViewController = mySingleton.videoPlayerVC;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayerViewController.moviePlayer];
     [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:_videoPlayerViewController.moviePlayer];
    [_videoPlayerViewController.moviePlayer.view removeFromSuperview];
    
    _videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc]initWithVideoIdentifier:_idVideo];

     [self setVideoQuality];
    
    
    [_videoPlayerViewController presentInView:_playingView];
    
    [_videoPlayerViewController.moviePlayer play];
    [_videoPlayerViewController.moviePlayer prepareToPlay];
    _videoPlayerViewController.moviePlayer.shouldAutoplay = YES;
    _videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = YES;
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playDidPlaybackEnd:) name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayerViewController.moviePlayer];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playDidChangeNoti:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:_videoPlayerViewController.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:_videoPlayerViewController.moviePlayer];
    
    MySingleton *mySingleton =[MySingleton sharedInstance];
    mySingleton.videoPlayerVC = _videoPlayerViewController;
    
    if (!_didDismiss) [self addGesturetoVideo];
    [self updateMovieInteraction];
    
    [self startActivityIndicator];
    
    
    if (_playingView.subviews.count ==2 ) {
        [_playingView bringSubviewToFront:_playingView.subviews.firstObject];
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"pause"];
    

    songInfo = [[NSMutableDictionary alloc] init];
    
    NSDictionary *item = [[NSUserDefaults standardUserDefaults]objectForKey:@"playingItem"];
    NSString *imgPath = item[@"snippet"][@"thumbnails"][@"high"][@"url"];
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgPath]];
    MPMediaItemArtwork *albumArt;
    
    if (imgData)  {
      albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:imgData]];
          [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
    }
    
    [songInfo setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"titleVideo" ] forKey:MPMediaItemPropertyTitle];
    
//    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.songInfo = songInfo;
    NSLog(@"songInfo: %@",songInfo);
}


- (void) movieLoadDidChange:(NSNotification*)notify{
    
    if (notify.object == _videoPlayerViewController.moviePlayer){
        if (_videoPlayerViewController.moviePlayer.loadState == MPMovieLoadStatePlayable) {
          
            [_videoPlayerViewController.moviePlayer play];
            
            
        }
        if (_videoPlayerViewController.moviePlayer.loadState == MPMovieLoadStatePlaythroughOK){
            [_videoPlayerViewController.moviePlayer play];
            
          
        }
    }
}
- (void) startActivityIndicator{
    
    activityIndicatorView  = [[MyActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityIndicatorView.center = _playingView.center;
//    [_playingView addSubview:activityIndicatorView];
//    [_playingView bringSubviewToFront:activityIndicatorView];
    [_videoPlayerViewController.moviePlayer.view addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
}

- (void) updateMovieInteraction{
    if (_didDismiss) _videoPlayerViewController.moviePlayer.view.userInteractionEnabled = NO;
    else _videoPlayerViewController.moviePlayer.view.userInteractionEnabled = YES;
}

- (void) setVideoQuality{
    NSString *quality = [[NSUserDefaults standardUserDefaults]objectForKey:@"videoquality"];
    if ([quality isEqualToString:@"Auto"]){
           _videoPlayerViewController.preferredVideoQualities = @[ XCDYouTubeVideoQualityHTTPLiveStreaming, @(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240)];
    }
    if ([quality isEqualToString:@"720"]){
         _videoPlayerViewController.preferredVideoQualities = @[  @(XCDYouTubeVideoQualityHD720)];
    }
    if ([quality isEqualToString:@"360"]){
         _videoPlayerViewController.preferredVideoQualities = @[ @(XCDYouTubeVideoQualityMedium360)];
    };
    if ([quality isEqualToString:@"240"]){
      _videoPlayerViewController.preferredVideoQualities = @[ @(XCDYouTubeVideoQualitySmall240)];
    }
}

- (void) addGesturetoVideo{
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    [_videoPlayerViewController.moviePlayer.view addGestureRecognizer:tap];
    
    pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPan:)];
    [pan translationInView:_videoPlayerViewController.moviePlayer.view];
    pan.minimumNumberOfTouches = 1;
    [_videoPlayerViewController.moviePlayer.view addGestureRecognizer:pan];
    // remember to remove after ...
    
}
- (void) onPan:(UIPanGestureRecognizer*)gesture{
    
    if (_playingView.frame.size.width> MIN([[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)) return;
    
    CGPoint translate = [gesture translationInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    if ([gesture state] == UIGestureRecognizerStateBegan){
        _startPan = translate;
        
        
    }
    
    else if ([gesture state] == UIGestureRecognizerStateEnded){
        [self endPan];
    }
    else
    {
        [self updateFromPan:translate];
    }
    [_playingView bringSubviewToFront:_videoPlayerViewController.moviePlayer.view];
}

- (void) addBlackView{
    [self.presentingViewController.view addSubview:[MySingleton sharedInstance].blackView];
    [MySingleton sharedInstance].blackView.alpha = 0;
}

- (void) endPan{
    
    float yCoordinate = _playingView.frame.origin.y;
    float yFix = [self smallVideoY]/2;
    if (yCoordinate>yFix) [self zoomSmallVideo];
    else [self backPreviousPosition];
    
}

- (void) backPreviousPosition{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _playingView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width/16*9);
        self.view.alpha = 1;
         [self updateActivityIndicatorPosition];
        
        [MySingleton sharedInstance].blackView.alpha = 1;
    } completion:^(BOOL complete){
        [self layoutControlBar];
        _controlBar.hidden = NO;
    }];
    
}

- (void) zoomSmallVideo{
    [self onDismiss];
}

- (float) getVector{
    float newWidth = MIN([UIScreen mainScreen].bounds.size.width,[[UIScreen mainScreen]bounds].size.height) /2.5;
    float newHeight = newWidth/16*9;
    float adsHeight;
    if (IDIOM==IPAD) adsHeight = 90;
    else adsHeight = 50;
    if ([self isPurchased]) adsHeight=0;
    
    return (self.view.frame.size.width-newWidth) / (self.view.frame.size.height-newHeight-50- adsHeight);

}
- (float) smallVideoY{
    float newWidth = MIN([UIScreen mainScreen].bounds.size.width,[[UIScreen mainScreen]bounds].size.height) /2.5;
    float newHeight = newWidth/16*9;
    float adsHeight;
    if (IDIOM==IPAD) adsHeight = 90;
    else adsHeight = 50;
    if ([self isPurchased]) adsHeight=0;
    
    return self.view.frame.size.height-newHeight-50- adsHeight;
}

- (void) updateFromPan:(CGPoint)currentPan{
    float vector = [self getVector];
    
    float newY =  currentPan.y-_startPan.y;
    float newX = newY*vector;
    
    float newWidth = self.view.frame.size.width - newX;
    float newHeight = newWidth/16*9;
    
    float newViewY = newY - ((self.view.frame.size.width/16*9) - newHeight);
    
    if (newY>=[self smallVideoY]-10) return;
    if (currentPan.y<=_startPan.y) return;
    
    [UIView animateWithDuration:0.01 animations:^{
        
        _playingView.frame = CGRectMake(newX, newY, newWidth, newHeight);
        self.view.frame = CGRectMake(newX, newViewY, self.view.frame.size.width, self.view.frame.size.height);
        self.view.alpha = 1 - (currentPan.y - _startPan.y) / [self smallVideoY];
        [MySingleton sharedInstance].blackView.alpha = 1 - (currentPan.y - _startPan.y) / [self smallVideoY];
              [self updateActivityIndicatorPosition];
    } completion:^(BOOL finish){

    }];
}

- (void) playDidChangeNoti:(NSNotificationCenter*)noti{
    
    if ([_videoPlayerViewController.moviePlayer playbackState] == MPMoviePlaybackStatePlaying){
        [self stopActivityIndicator];
        [self getEndingTime];
        
        if (currentPlaying>0) {
            _videoPlayerViewController.moviePlayer.currentPlaybackTime = currentPlaying;
            currentPlaying=0;
        }
    }
    
    if ([_videoPlayerViewController.moviePlayer playbackState] == MPMoviePlaybackStateSeekingForward){
        [self stopActivityIndicator];
        [self startActivityIndicator];
    }
    
//    if ([_videoPlayerViewController.moviePlayer playbackState] == MPMoviePlaybackStatePaused ) {
//        int state = [[[NSUserDefaults standardUserDefaults]objectForKey:@"pause"]intValue];
//        if (state ==0) [_videoPlayerViewController.moviePlayer play];
//    }
}
- (void) stopActivityIndicator{
    
    [activityIndicatorView stopAnimating];
    [activityIndicatorView removeFromSuperview];
}

- (void) getEndingTime{
    int playingTime = [_videoPlayerViewController.moviePlayer duration];
    slider.maximumValue = playingTime;
    
    endTime.text = [self timeFormat:playingTime];
    
    [songInfo setObject:@(playingTime) forKey: MPMediaItemPropertyPlaybackDuration];
//    [songInfo setObject:[NSNumber numberWithInt:10] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void) barAppear{
    
    [_playingView bringSubviewToFront:_controlBar];
    [_playingView bringSubviewToFront:dismissBt];
}

- (void) barDisappear{
    
    if (disappearCount == 1){
        if ((slider.state != UIGestureRecognizerStateBegan) && (slider.state != UIGestureRecognizerStateChanged))
           [_playingView bringSubviewToFront:_videoPlayerViewController.moviePlayer.view];
    }
    
    disappearCount-=1;
    
}

- (void) onTap:(id)sender{
    
    if ([[[_playingView subviews]lastObject] isEqual:_videoPlayerViewController.moviePlayer.view]){
        [self barAppear];
        [self handleAfterBarAppear];
      
    }else {
        
        [_playingView bringSubviewToFront:_videoPlayerViewController.moviePlayer.view];
    }
}

- (void) handleAfterBarAppear{
    disappearCount+=1;
    [self performSelector:@selector(barDisappear) withObject:nil afterDelay:4];
}

- (void) onZoomBt:(id)sender{
    
    switch (zoomBt.tag) {
        case 1: // in small state
            [self changeOrientationtoPotrait];
            break;
        
        case 0: // full screen state
            [self changeOrientationtoLandscapeRight];
            break;
            
        default:
            break;
    }
}
- (void) willZoomOut{
    zoomBt.tag = 1;
    [zoomBt setImage:[UIImage imageNamed:@"zoomin"] forState:UIControlStateNormal];
    
    float screenWidth = MAX(self.view.frame.size.width, self.view.frame.size.height);
    float screenHeight = MIN(self.view.frame.size.width, self.view.frame.size.height);
    [self switchVideowithX:0 andY:0 andWidth:screenWidth andHeight:screenHeight];
    
    if (!dismissBt) saveHidden = YES;
    dismissBt.hidden = YES;
    
}
- (void) willZoomIn{
    
    zoomBt.tag = 0;
    [zoomBt setImage:[UIImage imageNamed:@"zoomout"] forState:UIControlStateNormal];
    
    float screenWidth = MIN(self.view.frame.size.width, self.view.frame.size.height);
    [self switchVideowithX:0 andY:0 andWidth:screenWidth andHeight:screenWidth/16*9];
    
    dismissBt.hidden = NO;
}

- (void) changeOrientationtoPotrait{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice]setValue:value forKey:@"orientation"];
    
    dismissBt.hidden = NO;
}

- (void) changeOrientationtoLandscapeRight{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice]setValue:value forKey:@"orientation"];
    dismissBt.hidden = YES;
}

- (void) changeOrientationtoLandscapeLeft{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice]setValue:value forKey:@"orientation"];
    
    dismissBt.hidden = YES;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return items.count;
}

#pragma mark UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    SimpleTableCell *cell = (SimpleTableCell*)[tableView dequeueReusableCellWithIdentifier:simpleCellIdentifier forIndexPath:indexPath];
    if (!cell){
        cell = [[SimpleTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleCellIdentifier];
    }
    NSDictionary *item = items[indexPath.row];
    
    cell.cellTextLabel.text = item[@"snippet"][@"title"];
    [cell.cellImage setImageWithURL:[NSURL URLWithString:item[@"snippet"][@"thumbnails"][@"medium"][@"url"]] placeholderImage:[UIImage imageNamed:@"musicplay"]];
    
    NSString *currentId = item[@"snippet"][@"resourceId"][@"videoId"];
    if (!currentId) currentId = item[@"id"][@"videoId"];
    
    if ([_idVideo isEqualToString:currentId]) {
        cell.playingImage.image = [UIImage imageNamed:@"playingvideo"];
    } else cell.playingImage.image = nil;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary*item = items[indexPath.row];
    currentItem = item;
    [self updatePlayingView:item];
}

- (void) updatePlayingView:(NSDictionary*)item{
    [self pickedPlayingList];
    
    NSString *id1 = item[@"snippet"][@"resourceId"][@"videoId"];
    if (!id1) id1 = item[@"id"][@"videoId"];
    _idVideo = id1;
    [[NSUserDefaults standardUserDefaults]setObject:id1 forKey:@"idVideo"];
    [[NSUserDefaults standardUserDefaults]setObject:item forKey:@"playingItem"];
    
    _titleVideo.text = item[@"snippet"][@"title"];
    [[NSUserDefaults standardUserDefaults] setObject:_titleVideo.text forKey:@"titleVideo"];
    [self updateViewCount];
    
    [self playVideo];
    
    items = [[NSUserDefaults standardUserDefaults]objectForKey:@"playlistitems"];
    [self reloadTableView];
    
    [_playingView bringSubviewToFront:_controlBar];
    [_playingView bringSubviewToFront:dismissBt];
    [self handleAfterBarAppear];
    
    
     pauseBt.tag =0; [pauseBt setImage:[UIImage imageNamed:@"playing"] forState:UIControlStateNormal];
    // it can be that we must add pause to nsuserdefault here
}

- (void) updateViewCount{
    NSString *path = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=contentDetails,statistics&id=%@&key=AIzaSyDUknhXUA_YnOef5RY3VCT6IuEhWylTi3M",_idVideo];
    
    [IOSRequest requestPath:path onCompletion:^(NSDictionary *json, NSError*error){
        if ((!error) && ([json[@"items"] count]>0)){
            NSDictionary *item = json[@"items"][0];
            NSString *view = item[@"statistics"][@"viewCount"];
            _viewLb.text = [NSString stringWithFormat:@"%@ views",[self rewriteNumber:view]];
            
            [[NSUserDefaults standardUserDefaults]setObject:view forKey:@"viewCount"];
        }
    }];
}

- (IBAction)onPlaylistBt:(id)sender {
    items = [[NSUserDefaults standardUserDefaults]objectForKey:@"playlistitems"];
    [self reloadTableView];
    [self pickedPlayingList];
}

- (void) reloadTableView{
    [self stopTableActivityIndicatorView];
    [self startTableActivityIndicatorView];
    [_tableView reloadData];
}

- (IBAction)onRelatedBt:(id)sender {
    NSString *idVideo = [[NSUserDefaults standardUserDefaults]objectForKey:@"idVideo"];
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&relatedToVideoId=%@&type=video&maxResults=%d&key=AIzaSyDUknhXUA_YnOef5RY3VCT6IuEhWylTi3M",idVideo,maxSongsNumber];
    [IOSRequest requestPath:urlString onCompletion:^(NSDictionary*json, NSError*error){
        if (!error){
            items = json[@"items"];
            dispatch_async(dispatch_get_main_queue(),^{
                
                    [self reloadTableView];
            });
        }
    }];
    [self pickedRelated];
}

- (void) pickedPlayingList{
    [_playingListBt setTitleColor:trueBlue forState:UIControlStateNormal];
    [_relatedBt setTitleColor:gray forState:UIControlStateNormal];
    
    _playingListBt.layer.borderColor = trueBlue.CGColor;
    _relatedBt.layer.borderColor = gray.CGColor;
    
}
- (void) pickedRelated{
    [_playingListBt setTitleColor:gray forState:UIControlStateNormal];
    [_relatedBt setTitleColor:trueBlue forState:UIControlStateNormal];
    
    _playingListBt.layer.borderColor = gray.CGColor;
    _relatedBt.layer.borderColor = trueBlue.CGColor;
}

- (void) addDismissBt{
    
    dismissBt = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 40, 40)];
    dismissBt.showsTouchWhenHighlighted = YES;
    [dismissBt setImage:[UIImage imageNamed:@"dismiss"] forState:UIControlStateNormal];
    [dismissBt addTarget:self action:@selector(onDismiss) forControlEvents:UIControlEventTouchUpInside];
    [_playingView addSubview:dismissBt];
    
    if (_playingView.frame.size.width <MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)){
        [_playingView bringSubviewToFront:_videoPlayerViewController.moviePlayer.view];
    }
    
    if (saveHidden) {
        saveHidden = NO;
        dismissBt.hidden = YES;
    }
}

- (BOOL) checkLandscape{
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight)) {
        return YES;
    }
    
    if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight)){
        return YES;
    }
    
    return NO;
}

- (void) onDismiss{
    
    if ([self checkLandscape]) return;
    
    if ([self.presentedViewController isKindOfClass:[UIAlertController class]]) return;
    
    float newWidth = MIN([UIScreen mainScreen].bounds.size.width,[[UIScreen mainScreen]bounds].size.height) /2.5;
    float newHeight = newWidth/16*9;
    float adsHeight;
    if (IDIOM==IPAD) adsHeight = 90;
    else adsHeight = 50;
    if ([self isPurchased]) adsHeight=0;
    
    [self changeOrientationtoPotrait];
    [self switchVideowithX:self.view.frame.size.width - newWidth  andY:self.view.frame.size.height-newHeight-50- adsHeight andWidth:newWidth andHeight:newHeight];
    [self dismissVC];
    
    [tap removeTarget:self action:@selector(onTap:)];

    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
//    [[NSUserDefaults standardUserDefaults]setObject:@(pauseBt.tag) forKey:@"pause"]; // verydangerous, take care of this, should it really be removed
    
    [_videoPlayerViewController.moviePlayer.view removeGestureRecognizer:tap];
    [_videoPlayerViewController.moviePlayer.view removeGestureRecognizer:pan];
    
    _videoPlayerViewController.moviePlayer.view.userInteractionEnabled = NO;
    _didDismiss = YES;
    
}

- (BOOL) isPurchased{
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:@"Purchase"];
    NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return [arr[0] intValue];
}


-  (void) createPlayingControl{
    // auto constrain here
    _controlBar = [[UIView alloc]initWithFrame:CGRectMake(0, _playingView.frame.size.height - controlHeight, _playingView.frame.size.width, controlHeight)];
   
    [_controlBar setBackgroundColor:[UIColor clearColor]];
    
    [_playingView addSubview:_controlBar];
    if (_playingView.frame.size.width>=MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height))
        [_playingView bringSubviewToFront:_controlBar];
    else [_playingView bringSubviewToFront:_videoPlayerViewController.moviePlayer.view];
    
    
    
    [self addConstrainToControl];
//    [self addTransparentView];
    
    [self addSlider];
    [self addQuality];
    [self addZoom];
    [self addTime];
    [self addPause];
    [self addNext];
    [self addBack];
    [self addRandom];
    [self addRepeat];
    
   
    [self layoutControlBar];
}
- (void) addTransparentView{
    transparentView = [[UIView alloc]init];
    transparentView.backgroundColor = [UIColor blackColor];
    transparentView.alpha = 0.35;
    [_controlBar addSubview:transparentView];
}

- (void) addQuality{
    qualityBt = [[UIButton alloc]init];
    qualityBt.showsTouchWhenHighlighted = YES;
    
    [qualityBt addTarget:self action:@selector(onQuality) forControlEvents:UIControlEventTouchUpInside];
    NSString *quality = [[NSUserDefaults standardUserDefaults]objectForKey:@"videoquality"];
//    [qualityBt setImage:[UIImage imageNamed:quality] forState:UIControlStateNormal];
    [qualityBt setTitle:quality forState:UIControlStateNormal];
    [qualityBt setTitleColor:[UIColor colorWithRed:(237/255.5) green:(39/255.0) blue:(147/255.0) alpha:1] forState:UIControlStateNormal];
    qualityBt.titleLabel.font= [UIFont fontWithName:@"SFUIText-Regular" size:11.5];
    [_controlBar addSubview:qualityBt];

}
- (void) resetVideo:(NSString*)quality{
    pauseBt.tag = 0;
    [[NSUserDefaults standardUserDefaults]setObject:@(pauseBt.tag) forKey:@"pause"];
    [pauseBt setImage:[UIImage imageNamed:@"playing"] forState:UIControlStateNormal];
    [pauseBt setTitle:quality forState:UIControlStateNormal];
//    [qualityBt setImage:[UIImage imageNamed:quality] forState:UIControlStateNormal];
    [qualityBt setTitle:quality forState:UIControlStateNormal];
    
    currentPlaying = slider.value;
    [self playVideo];
    
}
- (void) onQuality{
    NSString *quality = [[NSUserDefaults standardUserDefaults]objectForKey:@"videoquality"];
    
    alertController = [UIAlertController alertControllerWithTitle:@"Switch Video Quality" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action720 = [UIAlertAction actionWithTitle:@"720p" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
     
        [[NSUserDefaults standardUserDefaults]setObject:@"720p" forKey:@"videoquality"];
        [self resetVideo:@"720p"];
    }];
    if ([quality isEqualToString:@"720p"]) action720 = [UIAlertAction actionWithTitle:@"720p" style:UIAlertActionStyleDestructive handler:nil];

    
    UIAlertAction *action360 = [UIAlertAction actionWithTitle:@"360p" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
     
        [[NSUserDefaults standardUserDefaults]setObject:@"360p" forKey:@"videoquality"];
        [self resetVideo:@"360p"];
    }];
    if ([quality isEqualToString:@"360p"]) action360 = [UIAlertAction actionWithTitle:@"360p" style:UIAlertActionStyleDestructive handler:nil];
    
    UIAlertAction *action240 = [UIAlertAction actionWithTitle:@"240p" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        
        [[NSUserDefaults standardUserDefaults]setObject:@"240p" forKey:@"videoquality"];
        [self resetVideo:@"240p"];
    }];
    if ([quality isEqualToString:@"240p"]) action240 = [UIAlertAction actionWithTitle:@"240p" style:UIAlertActionStyleDestructive handler:nil];

    
    UIAlertAction *actionAuto = [UIAlertAction actionWithTitle:@"Auto" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){

        [[NSUserDefaults standardUserDefaults]setObject:@"Auto" forKey:@"videoquality"];
        [self resetVideo:@"Auto"];
    }];
    if ([quality isEqualToString:@"Auto"]) actionAuto = [UIAlertAction actionWithTitle:@"Auto" style:UIAlertActionStyleDestructive handler:nil];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    
    [alertController addAction:action240];
    [alertController addAction:action360];
    [alertController addAction:action720];
    [alertController addAction:actionAuto];
    [alertController addAction:actionCancel];
    
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popOver = [alertController popoverPresentationController];
    popOver.sourceView = qualityBt;
    popOver.sourceRect = qualityBt.bounds;
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (void) addTime{
    runningTime = [[UILabel alloc]init];
    runningTime.text = @"00.00";
    runningTime.textColor = [UIColor whiteColor] ;
    runningTime.font = [UIFont fontWithName:@"SFUIText-Regular" size:7];
    runningTime.textAlignment = NSTextAlignmentCenter;
    
    
    endTime = [[UILabel alloc]init];
    endTime.text = @"00.00";
    endTime.textColor = [UIColor whiteColor];
    endTime.font = [UIFont fontWithName:@"SFUIText-Regular" size:7];
    endTime.textAlignment = NSTextAlignmentCenter;
    
    [_controlBar addSubview:runningTime];
    [_controlBar addSubview:endTime];
    
}
- (void) addZoom{
    zoomBt = [[UIButton alloc] init];
    zoomBt.showsTouchWhenHighlighted = YES;
    zoomBt.tag = 0;
    [_controlBar addSubview:zoomBt];
    [zoomBt setImage:[UIImage imageNamed:@"zoomout"] forState:UIControlStateNormal];
    [zoomBt addTarget:self action:@selector(onZoomBt:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) addSlider{
    slider = [[MySlider alloc]init];

    [slider addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(onSlider:) forControlEvents:UIControlEventValueChanged];
    
    [slider addTarget:self action:@selector(onSliderEnded) forControlEvents:UIControlEventTouchUpInside];
//    [slider addTarget:self action:@selector(onSliderEnded) forControlEvents:UIControlEventTouchDragExit];
    [slider addTarget:self action:@selector(onSliderEnded) forControlEvents:UIControlEventTouchCancel];
    [slider addTarget:self action:@selector(onSliderEnded) forControlEvents:UIControlEventTouchUpOutside];

    slider.continuous = YES;
    slider.minimumValue = 0;
    
    if (_videoPlayerViewController.moviePlayer.duration>0){
        slider.maximumValue = _videoPlayerViewController.moviePlayer.duration;
        slider.value = _videoPlayerViewController.moviePlayer.currentPlaybackTime;
    }else {
        slider.maximumValue = 0;
        slider.value = 0;
    }
    
    [_controlBar addSubview:slider];
    [self startTimer];
    UIImage *thumbImage = [UIImage imageNamed:@"thumb"];
    slider.tintColor = [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
    
    [slider setThumbImage:thumbImage forState:UIControlStateNormal];
    
}

- (void) startTimer{
    timerCount = 0;
    [sliderTimer invalidate]; sliderTimer = nil;
      sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimer:) userInfo:nil repeats:true];
}

- (UIImage *)generateHandleImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 40, 40);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectInset(rect, 10.f, 10.f));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void) onSlider:(id)sender{
    [sliderTimer invalidate]; sliderTimer = nil;

    _videoPlayerViewController.moviePlayer.currentPlaybackTime = slider.value;
    runningTime.text = [self timeFormat:slider.value];

}

- (void) touchDown{
    [sliderTimer invalidate];sliderTimer = nil;
     [_videoPlayerViewController.moviePlayer pause];

}

- (void) onSliderEnded{

    _videoPlayerViewController.moviePlayer.currentPlaybackTime = slider.value;
    
    [_videoPlayerViewController.moviePlayer play];
    
     runningTime.text = [self timeFormat:slider.value];
    
    [pauseBt setImage:[UIImage imageNamed:@"playing"] forState:UIControlStateNormal];
    pauseBt.tag=0;
    [[NSUserDefaults standardUserDefaults]setObject:@(pauseBt.tag) forKey:@"pause"];
    
    [self startTimer];
    
    [self handleAfterBarAppear];
}


- (void) addPause{
    pauseBt = [[UIButton alloc]init];
    pauseBt.tag = [[[NSUserDefaults standardUserDefaults]objectForKey:@"pause"] intValue];
    pauseBt.showsTouchWhenHighlighted = YES;
    
    if (pauseBt.tag ==0)  [pauseBt setImage:[UIImage imageNamed:@"playing"] forState:UIControlStateNormal];
    else [pauseBt setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    
    [pauseBt addTarget:self action:@selector(onPauseTouch) forControlEvents:UIControlEventTouchUpInside];
    [_controlBar addSubview:pauseBt];
    
    
}

- (void) addNext{
    nextBt = [[UIButton alloc] init];
    nextBt.showsTouchWhenHighlighted = YES;
    [nextBt setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [nextBt addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    [_controlBar addSubview:nextBt];
}

- (void) addBack{
    backBt = [[UIButton alloc]init];
    backBt.showsTouchWhenHighlighted = YES;
    [backBt setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBt addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [_controlBar addSubview:backBt];
}
- (void) addRandom{
    randomBt = [[UIButton alloc]init];
    randomBt.showsTouchWhenHighlighted = YES;
    randomBt.showsTouchWhenHighlighted = YES;
    randomBt.tag = [[[NSUserDefaults standardUserDefaults]objectForKey:@"random"] intValue];
    [randomBt setImage:[UIImage imageNamed:[NSString stringWithFormat:@"random%ld",(long)randomBt.tag]] forState:UIControlStateNormal];
    [randomBt addTarget:self action:@selector(onRandom:) forControlEvents:UIControlEventTouchUpInside];
    [_controlBar addSubview:randomBt];
}

- (void) addRepeat{
    repeatBt = [[UIButton alloc]init];
    repeatBt.showsTouchWhenHighlighted = YES;
    repeatBt.tag = [[[NSUserDefaults standardUserDefaults]objectForKey:@"repeat"] intValue];
    [repeatBt setImage:[UIImage imageNamed:[NSString stringWithFormat:@"repeat%ld",(long)repeatBt.tag]] forState:UIControlStateNormal];
    [repeatBt addTarget:self action:@selector(onRepeat:) forControlEvents:UIControlEventTouchUpInside];
    [_controlBar addSubview:repeatBt];
}


- (void) onTimer:(NSTimer*)timer{
    
    timerCount+=1;
    if (timerCount<10) {
    }

    
    slider.value = _videoPlayerViewController.moviePlayer.currentPlaybackTime;
    
    runningTime.text = [self timeFormat:slider.value];
    
//    [songInfo setObject:[NSNumber numberWithFloat:_videoPlayerViewController.moviePlayer.currentPlaybackTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
}

- (void) onPauseTouch{
    [self onPause];
    [MySingleton sharedInstance].pauseTouch = YES;
}
- (void) onPause{
    pauseBt.tag = 1- pauseBt.tag;
    if (pauseBt.tag == 0) {
        
        if (_videoPlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateStopped){
            [self replay];
        }else
        [_videoPlayerViewController.moviePlayer play];
        
        [pauseBt setImage:[UIImage imageNamed:@"playing"] forState:UIControlStateNormal];
        
    }else {
        if ([_videoPlayerViewController.moviePlayer playbackState] == MPMoviePlaybackStatePlaying){
            [pauseBt setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            [_videoPlayerViewController.moviePlayer pause];
        }
        
        [songInfo setObject:[NSNumber numberWithFloat:_videoPlayerViewController.moviePlayer.currentPlaybackTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    }
    [[NSUserDefaults standardUserDefaults]setObject:@(pauseBt.tag) forKey:@"pause"];
}
- (int) findCurrentPlayingIndex{
    items = [[NSUserDefaults standardUserDefaults]objectForKey:@"playlistitems"];
    for (int i=0; i< items.count; i++){
        
        NSDictionary *item = items[i];
        NSString *currentId = item[@"snippet"][@"resourceId"][@"videoId"];
        if (!currentId) currentId = item[@"id"][@"videoId"];
        
        if ([_idVideo isEqualToString: currentId]){
            return i;
        }
    }
    return -1;
}
- (void) onNext{
    int index = [self findCurrentPlayingIndex];
    int newIndex;
    switch (randomBt.tag) {
        case 0:
            [self playNext:(index+1)% items.count];
            break;
            
        case 1:
            do {
                newIndex = arc4random()% items.count;
            } while (newIndex == index);
            [self playNext:newIndex];
            break;
            
        default:
            break;
    }
}

- (NSString*) timeFormat:(int)seconds{
    NSString *time;
    NSString *secondStr = [self completeTimeUnit:seconds%60];
    NSString *minuteStr = [self completeTimeUnit:(seconds/60)%60];
    time = [NSString stringWithFormat:@"%@:%@",minuteStr,secondStr];
    
    if ((seconds/60)/60>0){
        NSString *hourStr= [self completeTimeUnit:(seconds/60)/60];
        time = [NSString stringWithFormat:@"%@:%@",hourStr,time];
        
    }
    
    return time;
}
- (NSString*) completeTimeUnit:(int) value{
    if (value>=10) return [NSString stringWithFormat:@"%d",value];
    else return [NSString stringWithFormat:@"0%d",value];
}

- (void) replay{
    [self playVideo];
    [_playingView bringSubviewToFront:_controlBar];
}

- (void) playNext:(int)index{
    
    NSDictionary *item = items[index];
    
    [self updatePlayingView:item];
}

- (void) onBack{
    int index = [self findCurrentPlayingIndex];
    if (index ==-1) index = (int)items.count+1;
    
    int newIndex;
    switch (randomBt.tag) {
        case 0:
            if (index == 0) index = (int)items.count;
            [self playNext:(index-1)% items.count ];
            break;
            
        case 1:
            do {
                newIndex = arc4random()% items.count;
            } while (newIndex == index);
            [self playNext:newIndex];
            break;
            
        default:
            break;
    }
}

- (void) onRandom:(id) sender{
    randomBt.tag = 1- randomBt.tag;
    [randomBt setImage:[UIImage imageNamed:[NSString stringWithFormat:@"random%ld",(long)randomBt.tag]] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults]setValue:@(randomBt.tag) forKey:@"random"];
    
}
- (void) onRepeat:(id) sender{
    repeatBt.tag = 1- repeatBt.tag;
    [repeatBt setImage:[UIImage imageNamed:[NSString stringWithFormat:@"repeat%ld",(long)repeatBt.tag]] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults]setValue:@(repeatBt.tag) forKey:@"repeat"];
}

- (void) layoutControlBar{
    float barWidth = _controlBar.frame.size.width;

    float iconSize =20;
    float playSize = 25;
    float additionalBar = 20;
    
//    zoomBt.frame = CGRectMake(barWidth- 10 - iconSize, 12+additionalBar , iconSize, iconSize);
//    qualityBt.frame = CGRectMake(zoomBt.frame.origin.x - 15 - 30, 12+additionalBar, 30, iconSize);
//    slider.frame = CGRectMake(30, -5+additionalBar, barWidth - 60, 10);
//    
//    pauseBt.frame = CGRectMake(barWidth/2- playSize/2, 9.5+additionalBar, playSize, playSize);
//    nextBt.frame = CGRectMake(pauseBt.frame.origin.x + playSize + 30, 12+additionalBar, iconSize, iconSize);
//    backBt.frame = CGRectMake(pauseBt.frame.origin.x - 30 - iconSize, 12+additionalBar, iconSize, iconSize);
//    
//    runningTime.frame = CGRectMake(0, -6+additionalBar, 30, 12);
//    endTime.frame = CGRectMake(barWidth-30, -6+additionalBar, 30, 12);
//    
//    repeatBt.frame = CGRectMake(10, 12+additionalBar, iconSize, iconSize);
//    randomBt.frame = CGRectMake(repeatBt.frame.origin.x + iconSize +15, 12+additionalBar, iconSize, iconSize);
    
    zoomBt.frame = CGRectMake(barWidth- 10 - iconSize, 12+additionalBar , iconSize, iconSize);
    qualityBt.frame = CGRectMake(10, 12+additionalBar, 30, iconSize);
    pauseBt.frame = CGRectMake(barWidth/2- playSize/2, 9.5+additionalBar, playSize, playSize);
    nextBt.frame = CGRectMake(pauseBt.frame.origin.x + playSize + 30, 12+additionalBar, iconSize, iconSize);
    backBt.frame = CGRectMake(pauseBt.frame.origin.x - 30 - iconSize, 12+additionalBar, iconSize, iconSize);
    repeatBt.frame = CGRectMake(nextBt.frame.origin.x+ iconSize +30 , 12+additionalBar, iconSize, iconSize);
    randomBt.frame = CGRectMake(backBt.frame.origin.x - 30 - iconSize, 12+additionalBar, iconSize, iconSize);
    
    transparentView.frame = CGRectMake(0, additionalBar, barWidth, _controlBar.frame.size.height-additionalBar);
    
    slider.frame = CGRectMake(32.5, -5+additionalBar, barWidth - 65, 10);
    runningTime.frame = CGRectMake(0, -6+additionalBar, 32.5, 12);
        endTime.frame = CGRectMake(barWidth-32.5, -6+additionalBar, 32.5, 12);
}

- (void) addConstrainToControl{
    _controlBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_controlBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_playingView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.f];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_controlBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_playingView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.f];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_controlBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_playingView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.f];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_controlBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.f constant:controlHeight];
    [_playingView addConstraint:leading];
    [_playingView addConstraint:trailing];
    [_playingView addConstraint:bottom];
    
    [_controlBar addConstraint:height];
    
}

- (void) switchVideowithX:(float)x andY:(float)y andWidth:(float)width andHeight:(float)height{
    
    [UIView animateWithDuration:0.2 animations:^{
        _playingView.frame = CGRectMake(x, y, width, height);
        [self updateActivityIndicatorPosition];
    }completion:^(BOOL finish){
        [self layoutControlBar];
    }];
}

- (IBAction)onMoreBt:(id)sender {
    // 2nd

    
    int index = [self findCurrentPlayingIndex];

    if (index>=0){
            addedItem = items[index];
    } else{
        addedItem = currentItem;
    }
    [self showOptionALert];
}

- (void) showOptionALert{
    alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *addPlaylistAction = [UIAlertAction actionWithTitle:@"Add To Playlist" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        [MySingleton sharedInstance].restrictRotation = YES;
        [self addPlaylist];
    }];
    UIAlertAction *addShareAction  = [UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        [self addShare];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:addPlaylistAction];
    [alertController addAction:addShareAction];
    [alertController addAction:cancelAction];
    
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popOver = [alertController popoverPresentationController];
    popOver.sourceView =  _moreBt;
    popOver.sourceRect = _moreBt.bounds;
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void) addShare{
    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/app//id%@",APPID];
    NSString *title = [NSString stringWithFormat:@"Greate Song! Listen it: %@ Available in: %@",addedItem[@"snippet"][@"title"],url];

    NSArray *dataShare = @[title];
    UIActivityViewController *activityController = [[UIActivityViewController alloc]initWithActivityItems:dataShare applicationActivities:nil];
    if ( [activityController respondsToSelector:@selector(popoverPresentationController)] ) {
        activityController.popoverPresentationController.sourceView = _moreBt;
        activityController.popoverPresentationController.sourceRect = _moreBt.bounds;
    }
    
    activityController.excludedActivityTypes = @[UIActivityTypeAirDrop];
    [self presentViewController:activityController animated:YES completion:nil];
    
}

- (void) addPlaylist{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddToPlaylistVC *addToPlaylist = [mainStoryboard instantiateViewControllerWithIdentifier:@"addtoplaylistvc"];
    addToPlaylist.item = addedItem;
    [self presentViewController:addToPlaylist animated:YES completion:nil];
    
}

- (void) dismissVC{
    // 1st
    [MySingleton sharedInstance].restrictRotation = YES;
    
    GADBannerView *bannerView = [MySingleton sharedInstance].bannerView;
    if ([self.presentingViewController isKindOfClass:[AddToPlaylistVC class]]){
        bannerView.frame = CGRectMake(bannerView.frame.origin.x, bannerView.frame.origin.y, bannerView.frame.size.width, bannerView.frame.size.height);
        [self.presentingViewController.view addSubview:bannerView];
    }
    if ([self.presentingViewController isKindOfClass:[UITabBarController class]]){
        bannerView.frame = CGRectMake(bannerView.frame.origin.x, bannerView.frame.origin.y - 49, bannerView.frame.size.width, bannerView.frame.size.height);
        [self.presentingViewController.view addSubview:bannerView];
    }
    
    float newWidth = MIN([UIScreen mainScreen].bounds.size.width,[[UIScreen mainScreen]bounds].size.height) /2.5;
    float newHeight = newWidth/16*9;
    float adsHeight;
    if (IDIOM==IPAD) adsHeight = 90;
    else adsHeight = 50;
    if ([self isPurchased]) adsHeight=0;
    
    [_controlBar removeFromSuperview];
    [dismissBt removeFromSuperview];
    
    float newY = self.view.frame.size.height-newHeight-50- adsHeight - ((self.view.frame.size.width/16*9) - newHeight);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectMake(self.view.frame.size.width-newWidth, newY, self.view.frame.size.width, self.view.frame.size.height);
        self.view.alpha = 0;
        [[MySingleton sharedInstance]blackView].alpha = 0;
    }completion:^(BOOL finish){
        
        [self dismissViewControllerAnimated:NO completion:^{
                self.view.alpha = 1;
        }];
        
        [[MySingleton sharedInstance]blackView].alpha = 1;
        
        // dismiss will remove
        [[[MySingleton sharedInstance]blackView]removeFromSuperview];
    }];
    [sliderTimer invalidate]; sliderTimer = nil;
    
}

- (void) startTableActivityIndicatorView{
    
    tableActivityIndicator = [[MyActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    tableActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    tableActivityIndicator.color = [UIColor darkGrayColor];
    tableActivityIndicator.center = CGPointMake(_tableView.center.x, _tableView.center.y+_playingView.frame.size.height);
    tableActivityIndicator.hidesWhenStopped = YES;
    
    [self.view addSubview:tableActivityIndicator];
    [tableActivityIndicator startAnimating];
    
}
- (void) stopTableActivityIndicatorView{
    [tableActivityIndicator stopAnimating];
    [tableActivityIndicator removeFromSuperview];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [self stopTableActivityIndicatorView];
    }
}

@end
