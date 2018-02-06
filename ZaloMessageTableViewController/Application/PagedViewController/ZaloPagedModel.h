//
//  ZaloMessegeModel.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/13/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ZaloPagedModelProtocol <NSObject>

@property (readonly, copy, nonatomic) NSString *title,*detail,*lastUpdate;
@property (readonly, nonatomic) NSString *icon;

@end

@interface ZaloPagedModel : NSObject <ZaloPagedModelProtocol>

@property (copy, nonatomic) NSString *title,*detail,*lastUpdate;
@property (strong, nonatomic) NSString *icon;

@end
