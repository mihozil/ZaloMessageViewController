//
//  TabbarController.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/24/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "TabbarController.h"
#import "VideoPlayingViewController.h"
#import "MySingleton.h"
#import "IOSRequest.h"

@interface TabbarController ()

@end

@implementation TabbarController{
    UIPanGestureRecognizer *panGesture;
    UITapGestureRecognizer *tap;
    UIView *playingView;
    UIView *surfaceView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBar.tintColor = trueBlue;
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAds) name:@"Purchased" object:nil];
    
   
}
//- (void) addAds{
//    MySingleton *mySingleton = [MySingleton sharedInstance];
//    GADBannerView *bannerView = mySingleton.bannerView;
//    
//    float screenHeight = self.view.frame.size.height;
//    float bannerY = screenHeight - 49 - bannerView.frame.size.height;
//    bannerView.frame = CGRectMake( bannerView.frame.origin.x, bannerY, bannerView.frame.size.width, bannerView.frame.size.height);
//    
//    
//    [self.view addSubview:bannerView];
//}
//- (void) removeAds{
//    // remove ads
//    MySingleton *mySingleton = [MySingleton sharedInstance];
//    [mySingleton.bannerView removeFromSuperview];
//    mySingleton.bannerView = nil;
//    
//}

- (void)viewWillAppear:(BOOL)animated{
    
}
- (void)viewDidAppear:(BOOL)animated{
    MySingleton *mysingleton = [MySingleton sharedInstance];
    mysingleton.restrictRotation = YES;
    
//    [self addAds];
    
}




@end
