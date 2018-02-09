//
//  ZaloMessageViewController.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/30/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloMessageViewController.h"
#import "ZaloCollectionViewCell.h"
#import "ZaloMessageDataSource.h"
#import "ZaloCollectionViewLayout.h"
#import "ZaloPagedViewController.h"
#import "ZaloCollectionViewLayout.h"
#import "ZaloFriendRequestsDataSource.h"
#import "ZaloComposedDataSource.h"

@interface ZaloMessageViewController ()

@property (strong, nonatomic) ZaloMessageDataSource *messageDataSource;
@property (strong, nonatomic) ZaloFriendRequestsDataSource *friendRequestDataSource;
@property (strong, nonatomic) ZaloComposedDataSource *messageComposedDataSource;

@end

@implementation ZaloMessageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.collectionView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    
    self.messageComposedDataSource = [[ZaloComposedDataSource alloc]init];
    self.collectionView.dataSource = self.messageComposedDataSource;
    
    self.messageDataSource = [self newMessageDataSource];
    self.friendRequestDataSource = [self newFriendRequestDataSource];
    
    [_messageComposedDataSource addDataSource:_messageDataSource];
    [_messageComposedDataSource addDataSource:_friendRequestDataSource];
    self.messageComposedDataSource.delegate = self; // this put here, because the first time addDataSource, will not call to delegate didInsertSection
}

- (ZaloFriendRequestsDataSource*)newFriendRequestDataSource {
    ZaloFriendRequestsDataSource* friendRequestDataSource = [[ZaloFriendRequestsDataSource alloc]init];
    friendRequestDataSource.title = @"Add more friends to have more fun";
    friendRequestDataSource.loadErrorPlaceholder = [ZaloDataSourcePlaceholder placeholderWithTitle:@"Error" message:@"Please try again later" image:nil];
    friendRequestDataSource.noContentPlaceholder = [ZaloDataSourcePlaceholder placeholderWithTitle:@"No Content" message:@"Please try again later" image:nil];
    return friendRequestDataSource;
}

- (ZaloMessageDataSource*)newMessageDataSource {
    ZaloMessageDataSource* messageDataSource = [[ZaloMessageDataSource alloc]init];
    messageDataSource.collectionSuggetionIndex = 5;
    messageDataSource.noContentPlaceholder = [ZaloDataSourcePlaceholder placeholderWithTitle:@"No Content" message:@"There are no content loaded" image:nil];
    messageDataSource.loadErrorPlaceholder = [ZaloDataSourcePlaceholder placeholderWithTitle:@"Error" message:@"There seems to be an error loading content. Please try again." image:nil];
    return messageDataSource;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ZaloCollectionViewLayout *collectionViewLayout = [[ZaloCollectionViewLayout alloc]init];
        ZaloPagedViewController *pageViewController = [[ZaloPagedViewController alloc]initWithCollectionViewLayout:collectionViewLayout];
        [self.navigationController pushViewController:pageViewController animated:true];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark subClass


//- (void)dataSource:(ZaloDataSource *)dataSource perFormBatchUpdate:(dispatch_block_t)update {
//    
//    [super dataSource:dataSource perFormBatchUpdate:update];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//#pragma mark <UICollectionViewDelegate>


/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
