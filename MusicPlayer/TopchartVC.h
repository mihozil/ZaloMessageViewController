//
//  TopchartVC.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/22/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IOSRequest.h"
#import "CustomTableCell.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
@import GoogleMobileAds;

@interface TopchartVC : UIViewController <UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate,GADInterstitialDelegate>
@property (nonatomic, strong) GADBannerView *bannerView;

@end
