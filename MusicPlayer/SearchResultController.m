//
//  SearchResultController.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 10/4/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "SearchResultController.h"
#import "CustomSearchCell.h"

@interface SearchResultController ()

@end

@implementation SearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_tableView registerNib:[UINib nibWithNibName:@"CustomSearchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CustomSearchCell"];
    _tableView.separatorColor= [UIColor colorWithRed:(7/255.0) green:(7/255.0) blue:(204/255.0) alpha:1];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _searchResultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"CustomSearchCell";
    CustomSearchCell *cell = (CustomSearchCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomSearchCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.resultTextLabel.text = _searchResultArray[indexPath.row];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *searchWord = _searchResultArray[indexPath.row];
    [self.delegate didChoseText:searchWord];
    
}
@end
