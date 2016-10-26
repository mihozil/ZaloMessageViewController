//
//  ListOfferViewController.h
//  CloudMusicWorld
//
//  Created by BMX-05 on 5/7/16.
//  Copyright © 2016 BMX-05. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ListOfferViewController : UIViewController<NSURLSessionDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lbNameApp;
@property (weak, nonatomic) IBOutlet UIImageView *imageApp;
@property (weak, nonatomic) IBOutlet UIView *viewInstallApp;
@property (weak, nonatomic) IBOutlet UIButton *btnInstall;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIWebView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *btnActive;

@end
