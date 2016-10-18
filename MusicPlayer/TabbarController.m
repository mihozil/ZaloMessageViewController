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
    
   
}

- (void)viewDidAppear:(BOOL)animated{
    MySingleton *mysingleton = [MySingleton sharedInstance];
    mysingleton.restrictRotation = YES;
    
}




@end
