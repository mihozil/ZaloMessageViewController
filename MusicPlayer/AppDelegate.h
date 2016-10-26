//
//  AppDelegate.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/22/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMobileAds;


@interface AppDelegate : UIResponder <UIApplicationDelegate, UIGestureRecognizerDelegate, GADInterstitialDelegate, GADBannerViewDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

