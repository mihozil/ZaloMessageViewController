//
//  VideoPlayingViewController.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/23/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "AddToPlaylistVC.h"
#import "SimpleTableCell.h"
#define trueBlue [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1]
#define gray [UIColor colorWithRed:(191/255.0) green:(195/255.0) blue:(201/255.0) alpha:1]

extern float const controlHeight;


typedef void (^imageCompletion) (UIImage*, NSError*);

@interface VideoPlayingViewController : UIViewController <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, GADInterstitialDelegate, GADBannerViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) NSString *idVideo;
@property (nonatomic, strong) UIView *controlBar;
@property (strong, nonatomic) UIView *playingView;
@property (nonatomic, strong) NSDictionary *playingItem;
@property (nonatomic, assign) BOOL didDismiss;
@property (nonatomic, assign) CGPoint startPan;
@property (nonatomic, assign) BOOL appearBottom;

@property (weak, nonatomic) IBOutlet UIButton *playingListBt;
@property (weak, nonatomic) IBOutlet UIButton *relatedBt;
@property (weak, nonatomic) IBOutlet UILabel *titleVideo;
@property (weak, nonatomic) IBOutlet UILabel *viewLb;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;
@property (weak, nonatomic) IBOutlet UIButton *moreBt;



+ (instancetype)shareInstance;
- (void) onNext;
- (void) playVideo;
- (void) onPause;
- (void) addGesturetoVideo;
- (void) changeOrientationtoPotrait;
- (void) endPan;
- (void) updateFromPan:(CGPoint)currentPan;


@end
