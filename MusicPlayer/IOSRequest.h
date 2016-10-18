//
//  IOSRequest.h
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/22/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^onCompletionHandle) (NSDictionary*,NSError*);
typedef void (^onCompletion2) (NSArray*, NSError*);

@interface IOSRequest : NSObject

+(void) requestPath:(NSString*)path onCompletion:(onCompletionHandle) complete;
+(void) requestPath2:(NSString*)path onCompletion:(onCompletion2) complete;

@end
