//
//  IOSRequest.m
//  MusicPlayer
//
//  Created by bmxstudio04 on 9/22/16.
//  Copyright © 2016 bmxstudio04. All rights reserved.
//

#import "IOSRequest.h"

@implementation IOSRequest
+(void)requestPath:(NSString *)path onCompletion:(onCompletionHandle)complete{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    request.URL = [NSURL URLWithString:path];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData*data, NSURLResponse*respond, NSError*error){
        if (error){
            if (complete) complete(nil, error);
        }else {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (complete) complete(json,error);
        }
    }]resume];
}

+(void)requestPath2:(NSString *)path onCompletion:(onCompletion2)complete{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    request.URL = [NSURL URLWithString:path];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData*data, NSURLResponse*respond, NSError*error){
        if (error){
            if (complete) complete(nil, error);
        }else {
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (complete) complete(json,error);
        }
    }]resume];
}

@end
