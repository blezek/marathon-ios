/*
Copyright 2009-2010 Urban Airship Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binaryform must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided withthe distribution.

THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <StoreKit/StoreKit.h>
#import "ASIHTTPRequest.h"

@class UAProduct;
@interface UAStoreFrontRequest : ASIHTTPRequest {
    UAProduct *product;
    SKPaymentTransaction *transaction;
}
@property (nonatomic, retain) SKPaymentTransaction *transaction;
@property (nonatomic, retain) UAProduct *product;
@end


@class ASINetworkQueue;
@interface UAStoreKitObserver : NSObject <SKPaymentTransactionObserver, UIAlertViewDelegate> {
    ASINetworkQueue *networkQueue;
    ASINetworkQueue *downloadNetworkQueue;
    NSMutableDictionary *pendingProducts;
    
    //the first time a user purchases something (if there are no previous receipts)
    //we want to trigger a restore all event instead along with the purchase.
    BOOL firstTimeToPurchase;
    BOOL inRestoring;
    UAProduct *firstPurchasedProduct;
    NSMutableArray *unRestoredTransactions;
    NSString *downloadDirectory;
}
@property (nonatomic, assign, readonly) BOOL firstTimeToPurchase;
@property (nonatomic, assign, readonly) BOOL inRestoring;
@property (nonatomic, retain) NSString *downloadDirectory;

- (void)restoreAll;
- (void)beginRestore;
- (void)verifyReceipt:(id)product;
- (void)downloadStoreItem:(UAStoreFrontRequest *)request;
- (void)downloadFinished:(UAStoreFrontRequest *)request;
- (void)requestFailed:(UAStoreFrontRequest *)request;
- (void)decompressContent:(UAStoreFrontRequest *)request;
- (void)decompressFinished:(UAStoreFrontRequest *)request;

- (void)startTransaction:(SKPaymentTransaction *)transaction;
- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;

- (void)loadPendingProducts;
- (void)savePendingProducts;
- (UAProduct *)productFromTransaction:(SKPaymentTransaction *)transaction;
- (void)addPendingProduct:(UAProduct *)product;
- (BOOL)hasPendingProduct:(UAProduct *)product;
- (void)removePendingProduct:(UAProduct *)product
             withTransaction:(SKPaymentTransaction *)transaction;
- (void)resumePendingProducts;
- (void)firstTimeToPurchaseWithProduct:(UAProduct *)product;
- (void)enterBackground;
@end
