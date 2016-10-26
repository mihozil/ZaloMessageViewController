//
//  SearchResultController.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/4/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchResultDelegate;

@interface SearchResultController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *searchResultArray;

@property (nonatomic, weak) id<SearchResultDelegate> delegate;


@end

@protocol SearchResultDelegate <NSObject>

- (void) didChoseText:(NSString*)text;

@end