//
//  ZaloSuggestionCollectionViewModel.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/18/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ZaloSuggestionCollectionViewModel;

@protocol ZaloSuggestionCollectionViewModelProtocol<NSObject>

@property (copy, readonly, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *icon;

@end

@interface ZaloSuggestionCollectionViewModel : NSObject

@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *icon;

@end
