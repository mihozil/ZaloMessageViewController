//
//  ZaloGesturesToEditController.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/27/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloGesturesToEditController.h"
#import "ZaloCollectionViewCell.h"
#import "ZaloGestureWrapper.h"
#import "ZaloStateMachine.h"
#import "ZaloCollectionViewLayout.h"
#import "ZaloCollectionViewLayoutAttributes.h"
#import "ZaloCollectionViewController.h"

NSString * const ZaloGesturesStateIdle = @"IdleState";
NSString * const ZaloGesturesStateEditing = @"EditingState";
NSString * const ZaloGesturesStateTracking = @"TrackingState";
NSString * const ZaloGesturesStateOpen = @"OpenState";
NSString * const ZaloGestureStateLongTouching = @"LongTouchingState";

@interface ZaloGesturesToEditController() <ZaloStateMachineDelegate>

@property (strong, nonatomic) ZaloGestureWrapper *panWrapper;
@property (strong, nonatomic) ZaloGestureWrapper *longGestureWrapper;
@property (strong, nonatomic) ZaloGestureWrapper *tapGestureWrapper;
@property (strong, nonatomic) ZaloStateMachine *stateMachine;
@property (strong,nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) ZaloCollectionViewCell *editingCell;

@end

@implementation ZaloGesturesToEditController {
    
}

#pragma mark initializaton
- (instancetype)initWithCollectionView:(UICollectionView*)collectionView {
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        _stateMachine = [[ZaloStateMachine alloc]init];
        _stateMachine.delegate = self;
        _stateMachine.tranmissions = @{
                                       ZaloGesturesStateIdle : @[ZaloGestureStateLongTouching,ZaloGesturesStateTracking],
                                       ZaloGesturesStateTracking : @[ZaloGesturesStateIdle,ZaloGesturesStateOpen],
                                       ZaloGestureStateLongTouching : @[ZaloGesturesStateEditing, ZaloGesturesStateIdle],
                                       ZaloGesturesStateEditing : ZaloGesturesStateIdle,
                                       ZaloGesturesStateOpen : @[ZaloGesturesStateTracking, ZaloGesturesStateIdle]
                                       };
        [self addGestures];
        self.currentState = ZaloGesturesStateIdle;
    }
    return self;
}

- (void)addGestures {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:nil action:nil];
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:nil action:nil];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:nil action:nil];
    
     _panWrapper = [[ZaloGestureWrapper alloc]initWithGesture:panGesture target:self];
    _longGestureWrapper = [[ZaloGestureWrapper alloc]initWithGesture:longGesture target:self];
    _tapGestureWrapper = [[ZaloGestureWrapper alloc]initWithGesture:tapGesture target:self];
    
    [_collectionView addGestureRecognizer:panGesture];
    [_collectionView addGestureRecognizer:longGesture];
    [_collectionView addGestureRecognizer:tapGesture];
    
}

#pragma mark gesturesActions

- (void)handlepanGesture:(UIPanGestureRecognizer*)gesture {
    
    CGPoint location = [gesture locationInView:self.collectionView];
    CGPoint velocity = [gesture velocityInView:self.collectionView];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [_editingCell panDidBegin:location];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [_editingCell panDidChange:location];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [_editingCell panDidEnd:location velocity:velocity];
        
        if (velocity.x>0) {
            self.currentState = ZaloGesturesStateIdle;
        } else {
            self.currentState = ZaloGesturesStateOpen;
        }
    }
}

- (void)handleLongGestureWhileInIdleState:(UIGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        [self.delegate longGestureDidBeginZaloGesturesController:self];
        
    } else if ( gesture.state == UIGestureRecognizerStateChanged) {
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (void)handleTapGestureWhileInOpenState:(UIGestureRecognizer*)gesture {
    [_editingCell panDidEnd:CGPointZero velocity:CGPointMake(1, 0)]; // notify cell to scroll back to normal position
    // just temporary. should not be a panDidEnd. does should have a specified function
    self.currentState = ZaloGesturesStateIdle;
}

- (void)handleTapGestureWhileInEditingState:(UIGestureRecognizer*)gesture {
    CGPoint point = [gesture locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    ZaloCollectionViewCell *cell = (ZaloCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell)
        [cell handleAction:@selector(didSelectRemoveButtonFromCell:)];
}

#pragma mark gestureState

// neccessary : beginAction for Tracking
- (BOOL)panGestureShouldBeginWhileInIdleState:(UIGestureRecognizer*)gesture {
    // do something
    // it seems this has nothing to do with dataSource
    CGPoint point = [gesture locationInView:self.collectionView];
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:point];
    
    ZaloDataSource *dataSource = [(ZaloDataSource*)self.collectionView.dataSource dataSourceForSectionAtIndex:indexPath.section];
    if (![dataSource canEditItemAtIndexPath:indexPath]) {
        return false;
    }
    
    _editingCell = (ZaloCollectionViewCell*)[_collectionView cellForItemAtIndexPath:indexPath];
    _editingCell.editingActions = [dataSource actionsForItemAtIndexPath:indexPath];
    
    // one main task here is active the tracking State <set Action for gesture>
    self.currentState = ZaloGesturesStateTracking;
    return true;
}

// neccessary: beginAction for Editing
- (BOOL)longGestureShouldBeginWhileInIdleState:(UIGestureRecognizer*)gesture {
    
    self.currentState = ZaloGestureStateLongTouching; // one more state:
    return true;
}

- (BOOL)panGestureShouldBeginWhileInOpenState:(UIGestureRecognizer*)gesture {
    // check if the true cell
    CGPoint point = [gesture locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    if ([[self.collectionView cellForItemAtIndexPath:indexPath] isEqual:_editingCell]) {
        // change state to tracking and return true
        self.currentState = ZaloGesturesStateTracking;
        return true;
    }
    
    return false;
}

// note: if editing and scroll Happen -> should quit editing!
// neccessary: tap
- (BOOL)tapGestureShouldBeginWhileInOpenState:(UIGestureRecognizer*)gesture {
    // only return true if tapp at the editing cell
//    CGPoint point = [gesture locationInView:self.collectionView];
//    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
//    NSIndexPath *editingIndexPath = [self.collectionView indexPathForCell:_editingCell];
//    if (indexPath.row == editingIndexPath.row) {
//        return true;
//    }
//    return false;
    return true;
}

- (BOOL)tapGestureShouldBeginWhileInEditingState:(UIGestureRecognizer*)gesture {
    return true;
}

// the didEnterState handle whatever needed when the application change from State ... to State <may call update UI be somewhere else>
- (void)didEnterIdleState {
    _panWrapper.beginSelector = @selector(panGestureShouldBeginWhileInIdleState:);
    _longGestureWrapper.beginSelector = @selector(longGestureShouldBeginWhileInIdleState:);
    _tapGestureWrapper.beginSelector = NULL;
    
    [_editingCell shutActionPane];
}

- (void)didEnterEditingState {
    _panWrapper.beginSelector = NULL;
    _longGestureWrapper.beginSelector = NULL;
    _tapGestureWrapper.beginSelector = @selector(tapGestureShouldBeginWhileInEditingState:);
    _tapGestureWrapper.actionSelector = @selector(handleTapGestureWhileInEditingState:);

}

- (void)didEnterTrackingState {
    _panWrapper.beginSelector = NULL;
    _panWrapper.actionSelector = @selector(handlepanGesture:);
    
    _longGestureWrapper.beginSelector = NULL;
    
    _tapGestureWrapper.beginSelector = NULL;
}

- (void)didEnterOpenState {
    _panWrapper.beginSelector = @selector(panGestureShouldBeginWhileInOpenState:);
    
    _longGestureWrapper.beginSelector = NULL;
    
    _tapGestureWrapper.beginSelector = @selector(tapGestureShouldBeginWhileInOpenState:);
    _tapGestureWrapper.actionSelector = @selector(handleTapGestureWhileInOpenState:);
}

- (void)didEnterLongTouchingState {
    _panWrapper.beginSelector = NULL;
    
    _longGestureWrapper.beginSelector = NULL;
    _longGestureWrapper.actionSelector = @selector(handleLongGestureWhileInIdleState:);
    
    _tapGestureWrapper.beginSelector = NULL;
}

// those exit may not be neccessary anymore
- (void)didExitIdleState {
    
}

- (void)didExitEditingState {
    
}

- (void)didExitTrackingState {
    
}

- (void)didExitOpenState {
    
}

#pragma mark public

- (void)setCurrentState:(NSString *)currentState {
    if (![_currentState isEqualToString:currentState]) {
        _currentState = currentState;
        _stateMachine.currentState = currentState;
    }
}

- (void)setEditing:(BOOL)editing {
    // take it later
    self.currentState = editing? ZaloGesturesStateEditing : ZaloGesturesStateIdle;
}

- (void)resetState {
    self.currentState = ZaloGesturesStateIdle;
}

- (void)shutActionPaneForEditingCell {
    if (self.currentState == ZaloGesturesStateOpen) {
        self.currentState = ZaloGesturesStateIdle;
    }
}

@end
