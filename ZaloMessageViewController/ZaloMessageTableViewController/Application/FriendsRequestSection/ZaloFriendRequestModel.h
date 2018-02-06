//
//  ZaloFriendRequestModel.h
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 1/26/18.
//  Copyright © 2018 Mihozil. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZaloFriendRequestModel;

@protocol ZaloFriendRequestModelProtocol<NSObject>

@property (readonly, copy, nonatomic) NSString *title,*detail,*icon;

@end

@interface ZaloFriendRequestModel : NSObject

@property (copy, nonatomic) NSString *title, *detail, *icon;

@end
