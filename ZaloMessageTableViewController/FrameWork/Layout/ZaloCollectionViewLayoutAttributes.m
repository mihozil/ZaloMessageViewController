//
//  ZaloCollectionViewLayoutAttributes.m
//  ZaloMessageTableViewController
//
//  Created by Mihozil on 12/31/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "ZaloCollectionViewLayoutAttributes.h"

@implementation ZaloCollectionViewLayoutAttributes

- (BOOL)isEqual:(id)object {
    // this will be updated later
    return  NO;
}

- (id)copyWithZone:(NSZone *)zone {
    ZaloCollectionViewLayoutAttributes *copy = [super copyWithZone:zone];
    copy.editing = self.editing;
    return copy;
}

@end
