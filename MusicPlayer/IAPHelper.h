//
//  IAPHelper.h
//  iToolFiles
//
//  Created by BMXStudio on 5/17/14.
//  Copyright (c) 2014 BMXStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

#define kProductsLoadedNotification         @"ProductsLoaded"
#define kProductPurchasedNotification       @"ProductPurchased"
#define kProductRestoredNotification       @"ProductRestored"
#define kProductPurchaseFailedNotification  @"ProductPurchaseFailed"
#define kProductsLoadedFailNotification         @"ProductsLoadedFail"

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSSet * _productIdentifiers;    
    NSArray * _products;
    NSMutableSet * _purchasedProducts;
    SKProductsRequest * _request;
}

@property (retain) NSSet *productIdentifiers;
@property (retain) NSArray * products;
@property (retain) NSMutableSet *purchasedProducts;
@property (retain) SKProductsRequest *request;

+(IAPHelper *)sharedHelper;
-(void)requestProducts;
-(void)buyProductIdentifier:(SKProduct *)product;
-(void)restoreCompletedTransaction;

@end