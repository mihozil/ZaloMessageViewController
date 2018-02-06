//
//  ZaloPagedViewController.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/24/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import "ZaloPagedViewController.h"
#import "ZaloPagedDataSource.h"

@interface ZaloPagedViewController ()

@property (strong, nonatomic) ZaloPagedDataSource *pagedDataSource;

@end

@implementation ZaloPagedViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    self.collectionView.dataSource = self.pagedDataSource;
    self.pagedDataSource.delegate = self;
}


- (ZaloPagedDataSource *)pagedDataSource {
    if (_pagedDataSource)
        return _pagedDataSource;
    
    ZaloPagedDataSource *newPagedDataSource = [[ZaloPagedDataSource alloc]init];
    newPagedDataSource.noContentPlaceholder = [ZaloDataSourcePlaceholder placeholderWithTitle:@"There is no content in this Section" message:@"Please try again later" image:nil];
    newPagedDataSource.loadErrorPlaceholder = [ZaloDataSourcePlaceholder placeholderWithTitle:@"Loading Error" message:@"Please try again" image:nil];
    _pagedDataSource = newPagedDataSource;
    
    return newPagedDataSource;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
