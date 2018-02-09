//
//  ZaloCollectionViewController.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/25/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloCollectionViewController.h"
#import "ZaloGesturesToEditController.h"
#import "ZaloCollectionViewLayout.h"

@interface ZaloCollectionViewController ()  <ZaloGesturesToEditControllerDelegate>

@property (strong, nonatomic)ZaloGesturesToEditController *gesturesController;
@property (assign, nonatomic)BOOL performingUpdates;
@property (strong, nonatomic)NSMutableIndexSet *reloadedSections, *insertedSections, *deletededSections;

@end

@implementation ZaloCollectionViewController {
    UIBarButtonItem *_leftBarButton,*_rightBarButton;
    NSMutableArray *_toDeleteIndexPaths;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 10.0, *)) {
        self.collectionView.prefetchingEnabled = false;
    } else {
        // Fallback on earlier versions
    }
    
    self.gesturesController = [[ZaloGesturesToEditController alloc]initWithCollectionView:self.collectionView];
    self.gesturesController.delegate = self;
    self.performingUpdates = false;
    
    _leftBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(didTapLeftBarButton)];
    _rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(didTapRightBarButton)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ZaloDataSource *dataSource = (ZaloDataSource*)self.collectionView.dataSource;
    if (dataSource) {
        [dataSource registerReusableViewsWithCollectionView:self.collectionView];
        
        [dataSource loadContent];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark gesture

- (void)setEditing:(BOOL)editing {
    
    // collectionViewLayout
    ZaloCollectionViewLayout *layout = (ZaloCollectionViewLayout*)self.collectionView.collectionViewLayout;
    layout.editing = editing;
    // even this put here, not inside gestureController because normally, the even activate setEditing is truely from viewController
    self.gesturesController.editing = editing;
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    // editingControl_navigationbar
    if (editing) {
        [self showEditingControl];
        _toDeleteIndexPaths = [NSMutableArray array];
    } else
        [self hideEditingControl];
}

- (void)longGestureDidBeginZaloGesturesController:(ZaloGesturesToEditController *)gesturesController {
    self.editing = true;
}

- (void)showEditingControl {
    self.navigationItem.leftBarButtonItem = _leftBarButton;
    self.navigationItem.rightBarButtonItem = _rightBarButton;
}

- (void)hideEditingControl {
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didTapLeftBarButton {
    self.editing = false;
    
}

// begin long gesture:

- (void)didTapRightBarButton {
    // delete
    ZaloDataSource *dataSource = (ZaloDataSource*)self.collectionView.dataSource;
    if (!dataSource) {
        return;
    }
    
    self.editing = false;
    
    [dataSource performUpdate:^{
        [dataSource removeItemsAtIndexPaths:_toDeleteIndexPaths];
    } completion:^{
        
    }];
}

#pragma mark cellAction
// note: these should be subclass
- (void)deleteActionFromCell:(ZaloCollectionViewCell*)cell {
    ZaloDataSource *dataSource = (ZaloDataSource*)self.collectionView.dataSource;
    if (!dataSource)
        return;
    // not enough, must have kind of reset state, otherwise, some other cell will have the same ...
    // shut panel ... <AAPL>
    
    [dataSource performUpdate:^{
        [dataSource removeItemAtIndexPath:[self.collectionView indexPathForCell:cell]];
        // include : 1. remove data 2. dataSource.delegate didRemoveItems
    } completion:^{
        
    }];
    
}

- (void)muteActionFromCell:(ZaloCollectionViewCell*)cell {
    NSLog(@"mute");
}

- (void)hideActionFromCell:(ZaloCollectionViewCell*)cell {
    NSLog(@"hide");
}

// subclass
- (void)didSelectRemoveButtonFromCell:(ZaloCollectionViewCell*)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (cell.toDeleteSelected == true) {
        cell.toDeleteSelected = false;
    
        // data : subClass and handle
        [_toDeleteIndexPaths removeObject:indexPath];
        
    } else {
        cell.toDeleteSelected = true;
        
        // data : subClass and handle
        [_toDeleteIndexPaths addObject:indexPath];
    }
    
}


// subClass

// when pressDelete:
//1. data: deleteData
//2. UI: delete selectedIndexPath

#pragma mark collectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![cell isKindOfClass:[ZaloCollectionViewCell class]])
        return;
    
    ZaloCollectionViewCell *zaloCell = (ZaloCollectionViewCell*)cell;
    if ([_toDeleteIndexPaths containsObject:indexPath]) {
        zaloCell.toDeleteSelected = true;
    } else
        zaloCell.toDeleteSelected = false;
}

#pragma mark ZaloDataSourceDeleagate
- (void)dataSource:(ZaloDataSource *)dataSource didShowActivityIndicatorAtSections:(NSIndexSet *)sections {
    [self.reloadedSections addIndexes:sections];
}

- (void)dataSource:(ZaloDataSource *)dataSource didRefreshSections:(NSIndexSet *)sections {
    if (self.performingUpdates) {
        [self.reloadedSections addIndexes:sections];
    } else
        [self.collectionView reloadSections:sections];
}


- (void)dataSource:(ZaloDataSource *)dataSource perFormBatchUpdate:(dispatch_block_t)update completion:(dispatch_block_t)completion{
    if (self.performingUpdates) {
        
        if (update)
            update();
        
        if (completion)
            completion();
        
        return;
    }
    
    self.reloadedSections = [NSMutableIndexSet indexSet];
    self.insertedSections = [NSMutableIndexSet indexSet];
    self.deletededSections = [NSMutableIndexSet indexSet];
    
    __weak ZaloCollectionViewController *weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        
        weakSelf.performingUpdates = true;
        if (update)
            update();
        else {
            
        }
        
        NSMutableIndexSet *reloadedSections = [weakSelf.reloadedSections mutableCopy];
        [reloadedSections removeIndexes:weakSelf.insertedSections]; // not to delete insert and delete Sections
        [reloadedSections removeIndexes:weakSelf.deletededSections];
        
        // for delete, no reloadedSections here
        [weakSelf.collectionView reloadSections:reloadedSections];
        
        weakSelf.reloadedSections = nil;
        weakSelf.insertedSections = nil;
        weakSelf.deletededSections = nil;
        weakSelf.performingUpdates = false;
        
    } completion:^(BOOL finished){
        // remember to check if it is true to put those things here
        if (completion)
            completion();
    }];
}

- (void)dataSource:(ZaloDataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths {
    if (![NSThread isMainThread]) {
        NSAssert(NO, @"This must be in mainQueue");
    }
    
    [self.gesturesController resetState]; // resetState, shutActionPane is not enough for every cases <begin EditingState>
    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
    
}

- (void)dataSource:(ZaloDataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {

    [self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)dataSource:(ZaloDataSource *)dataSource didInsertSections:(NSIndexSet *)sections {
    if (sections) {
        [self.collectionView insertSections:sections];
        [self.insertedSections addIndexes:sections]; // the insertedSections only for perfomrbatch update. if this is not inside batchupdate, supposed insertedSections is nil
    }
}


@end
