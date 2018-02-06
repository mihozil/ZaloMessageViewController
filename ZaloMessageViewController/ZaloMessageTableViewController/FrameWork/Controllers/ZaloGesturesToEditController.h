//
//  ZaloGesturesToEditController.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/27/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ZaloGesturesToEditController;

@protocol ZaloGesturesToEditControllerDelegate <NSObject>

- (void)longGestureDidBeginZaloGesturesController:(ZaloGesturesToEditController*)gesturesController;

@end

@interface ZaloGesturesToEditController : NSObject

@property (assign, nonatomic)BOOL editing;
@property (strong, nonatomic) NSString *currentState;
@property (weak, nonatomic) id<ZaloGesturesToEditControllerDelegate>delegate;
- (instancetype)initWithCollectionView:(UICollectionView*)collectionView;
- (void)resetState;
- (void)shutActionPaneForEditingCell;

@end
