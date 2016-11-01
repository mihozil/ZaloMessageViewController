//
//  MySingleton.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/23/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
@import GoogleMobileAds;

@interface MySingleton : NSObject <GADBannerViewDelegate, GADInterstitialDelegate>

@property (nonatomic, assign) int tableCellHeight;
@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerVC;
@property (nonatomic, strong) UIView *playingView;
@property (nonatomic, assign) int maxSongs;
@property (nonatomic, assign) BOOL restrictRotation;
@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, strong) GADInterstitial * intestitial;
@property (nonatomic, assign) int playingViewCount;

@property (nonatomic, strong) UIView *blackView;
@property (nonatomic, assign) BOOL isPurchased;
@property (nonatomic, assign) BOOL pauseTouch;



+(instancetype)sharedInstance;

@end
