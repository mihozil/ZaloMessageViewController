//
//  MySingleton.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/23/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "MySingleton.h"

@implementation MySingleton
@synthesize tableCellHeight;

+(instancetype)sharedInstance{
    static MySingleton *mySingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        mySingleton = [[MySingleton alloc]init];
    });
    return mySingleton;
}

- (id) init{
    if (self = [super init]){
        tableCellHeight = 90;
        _maxSongs = 20;
        _restrictRotation = YES;
        _playingViewCount=6;
        _isPurchased = NO;
        
        float width = MIN([[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
        float height =MAX([[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
        
        _blackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
        _blackView.backgroundColor = [UIColor blackColor];
        _pauseTouch = false;
        
    }
    return self;
}

@end
