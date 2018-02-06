//
//  ZaloMessageFoundations.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/30/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloMessageFoundations.h"

CGFloat Boundi(CGFloat value, CGFloat min, CGFloat max) {
    if (min>max) {
        max = min;
    }
    value = MAX(value, min);
    value = MIN(value, max);
    return value;
};

@implementation ZaloMessageFoundations

@end
