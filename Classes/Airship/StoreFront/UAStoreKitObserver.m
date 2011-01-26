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

#import "StoreFront.h"
#import "UAUtils.h"
#import "UAStoreKitObserver.h"
#import "UAStoreFrontViewController.h"
#import "UAInventory.h"
#import "SBJSON.h"
#import "ZipArchive.h"
#import "ASINetworkQueue.h"

#define kNotFirstTimeToPurchase @"NotFirstTimeToPurchase"

// Weak link to this notification since it doesn't exist in iOS 3.x
UIKIT_EXTERN NSString* const UIApplicationDidEnterBackgroundNotification __attribute__((weak_import));

@implementation UAStoreFrontRequest

@synthesize transaction;
@synthesize product;

- (void)dealloc {
    RELEASE_SAFELY(product);
    RELEASE_SAFELY(transaction);
    [super dealloc];
}

@end

@implementation UAStoreKitObserver
@synthesize firstTimeToPurchase;
@synthesize inRestoring;
@synthesize downloadDirectory;

- (id)init {
    if (!(self = [super init]))
        return nil;

    if (&UIApplicationDidEnterBackgroundNotification != NULL) {
        
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(enterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
	
    }
    
    
    firstTimeToPurchase = ![[NSUserDefaults standardUserDefaults]
                            boolForKey:kNotFirstTimeToPurchase];
    inRestoring = NO;

    networkQueue = [[ASINetworkQueue queue] retain];
    [networkQueue go];
    
    // For 2.1.5 we'll continue to default to the old download dir (Documents/) for backwards compatibility
    [self setDownloadDirectory:kUAOldDownloadDirectory];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:downloadDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    UALOG(@"Current downloadDirectory: %@", downloadDirectory);
    
    // For tracking group downloads
    downloadNetworkQueue = [[ASINetworkQueue queue] retain];
    downloadNetworkQueue.showAccurateProgress = YES;
    downloadNetworkQueue.downloadProgressDelegate = self;
    downloadNetworkQueue.delegate = self;
    downloadNetworkQueue.queueDidFinishSelector = @selector(downloadNetworkQueueFinished:);
    [downloadNetworkQueue go];
    
    [self loadPendingProducts];

    return self;
}

- (void)dealloc {
    RELEASE_SAFELY(downloadNetworkQueue);
    RELEASE_SAFELY(networkQueue);
    RELEASE_SAFELY(pendingProducts);
    RELEASE_SAFELY(firstPurchasedProduct);
    RELEASE_SAFELY(unRestoredTransactions);
    RELEASE_SAFELY(downloadDirectory);
    [super dealloc];
}

// App is backgrounding, so stop active networking
- (void)enterBackground {
    [networkQueue cancelAllOperations];
    [downloadNetworkQueue cancelAllOperations];
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    UALOG(@"paymentQueue:removedTransaction:%@", transactions);
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                [self startTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    inRestoring = NO;
    for (SKPaymentTransaction *transaction in unRestoredTransactions) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        UAProduct *product = [self productFromTransaction:transaction];
        [product resetStatus];
    }
    
    [[StoreFront shared].productListViewController refreshExitButton];
    [[StoreFront shared].productListViewController enableRestoreButton];
    
    RELEASE_SAFELY(unRestoredTransactions);
    UALOG(@"paymentQueue:%@ restoreCompletedTransactionsFailedWithError:%@", queue, error);
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    inRestoring = NO;
    firstTimeToPurchase = NO;
    [[NSUserDefaults standardUserDefaults] setBool:!firstTimeToPurchase forKey:kNotFirstTimeToPurchase];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[StoreFront shared].productListViewController enableRestoreButton];
    
    UALOG(@"paymentQueueRestoreCompletedTransactionsFinished:%@", queue);

    if (firstPurchasedProduct != nil) {
        RELEASE_SAFELY(firstPurchasedProduct);
    }

    if ([unRestoredTransactions count] == 0) {
        NSString* okStr = UA_SF_TR(@"UA_OK");
        NSString* restoreTitle = UA_SF_TR(@"UA_content_restore_title");
        NSString* restoreMsg = UA_SF_TR(@"UA_content_restore_none");
        
        UIAlertView *restoreAlert = [[UIAlertView alloc] initWithTitle:restoreTitle
                                                               message:restoreMsg
                                                              delegate:nil
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:okStr, nil];
        [restoreAlert show];
        [restoreAlert release];
        
        return;
    }
    
    NSString* okStr = UA_SF_TR(@"UA_OK");
    NSString* cancelStr = UA_SF_TR(@"UA_Cancel");

    NSString* restoreTitle = UA_SF_TR(@"UA_content_restore_title");
    
    NSString* restoreMsg = UA_SF_TR(@"UA_content_restore");

    int restoreCount = [unRestoredTransactions count];

    UIAlertView *restoreAlert = [[UIAlertView alloc] initWithTitle:restoreTitle
                                                           message:[NSString stringWithFormat:restoreMsg,
                                                                    restoreCount,
                                                                    [UAUtils pluralize: restoreCount singularForm: @"item" pluralForm: @"items"],
                                                                    [UAUtils pluralize: restoreCount singularForm: @"it" pluralForm: @"them"]]
                                                          delegate:self
                                                 cancelButtonTitle:cancelStr
                                                 otherButtonTitles:okStr, nil];
    [restoreAlert setTag:31];
    [restoreAlert show];
    [restoreAlert release];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 31) { // Restore Transactions found, download them?
        if (buttonIndex == 1) {
            for (SKPaymentTransaction *transaction in unRestoredTransactions) {
                [self verifyReceipt:transaction];
            }
        } else {
            for (SKPaymentTransaction *transaction in unRestoredTransactions) {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
            
        }
        RELEASE_SAFELY(unRestoredTransactions);
    }
    if (alertView.tag == 30) { // Begin Restore Transactions check?
        if (buttonIndex == 1) {
            // OK Clicked
            [self beginRestore];
        } else {
            // Cancel Clicked
            [[StoreFront shared].productListViewController enableRestoreButton];
        }
    }
}

#pragma mark -

- (void)startTransaction:(SKPaymentTransaction *)transaction {
    UALOG(@"Transaction started: %@, id: %@", transaction, transaction.payment.productIdentifier);
    UAProduct *product = [self productFromTransaction:transaction];
    product.status = UAProductStatusWaiting;
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    // Filter out unfinished transactions made by previous installation
    if (firstTimeToPurchase == YES) {
        
        if([transaction.payment.productIdentifier isEqual:firstPurchasedProduct.productIdentifier]) {
            // We're done with the first purchase
            firstTimeToPurchase = NO;
            [[NSUserDefaults standardUserDefaults] setBool:!firstTimeToPurchase forKey:kNotFirstTimeToPurchase];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UALOG(@"First purchase Successful, provide content.\n completeTransaction: %@ \t id: %@",
                  transaction, transaction.payment.productIdentifier);
            
            [self verifyReceipt:transaction];
            
            return;
        }
        
        UALOG(@"Remove unfinished orphan transaction: %@", transaction);
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        return;
    }

    UALOG(@"Purchase Successful, provide content.\n completeTransaction: %@ \t id: %@",
          transaction, transaction.payment.productIdentifier);
    [self verifyReceipt:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    UALOG(@"Restore Transaction: %@ id: %@", transaction, transaction.payment.productIdentifier);

    if (inRestoring) {
        UALOG(@"Original transaction: %@", transaction.originalTransaction);
        [self verifyReceipt:transaction];
    } else {
        // Discard duplicated restore transactions when not Restoring All
        if (![[StoreFront shared].purchaseReceipts objectForKey:transaction.payment.productIdentifier]) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } else {
            [self verifyReceipt:transaction];
        }
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSString* okStr = UA_SF_TR(@"UA_OK");
    NSString* purchaseErrorTitle = UA_SF_TR(@"UA_purchase_error_title");
    NSString* purchaseError = UA_SF_TR(@"UA_purchase_error");

    if ((int)transaction.error.code != SKErrorPaymentCancelled) {
        UALOG(@"Transaction Failed (%d), product: %@", (int)transaction.error.code, transaction.payment.productIdentifier);
        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:purchaseErrorTitle
                                                               message:purchaseError
                                                              delegate:nil
                                                     cancelButtonTitle:okStr
                                                     otherButtonTitles:nil];
        [failureAlert show];
        [failureAlert release];
    }

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    UAProduct *product = [self productFromTransaction:transaction];
    
    if ([[StoreFront shared].delegate respondsToSelector:@selector(productPurchaseFailed:)]) {
        [[StoreFront shared].delegate productPurchaseFailed:product];
    }
    
    // If canceled because of being a duplicate transaction
    BOOL needReset = YES;
    
    NSArray *tranArray = [SKPaymentQueue defaultQueue].transactions;
    for (SKPaymentTransaction *tran in tranArray) {
        if (transaction != tran && [transaction.payment.productIdentifier isEqualToString:tran.payment.productIdentifier]) {
            needReset = NO;
            break;
        }
    }
    
    if (needReset) {
        [product resetStatus];
        [[StoreFront shared].productListViewController refreshExitButton];
    }
}

#pragma mark -
#pragma mark Network Interactions

// send receipt of either SKPaymentTransaction or UAProduct to our server
- (void)verifyReceipt:(id)parameter {
   
    NSString* productIdentifier = nil;
    UAProduct *product = nil;
    SKPaymentTransaction *transaction = nil;
    NSString* receipt = nil;

    // Unify UAProduct and SKPaymentTransaction
    if ([parameter isKindOfClass:[UAProduct class]])  {
        product = (UAProduct *)parameter;
        productIdentifier = product.productIdentifier;
        if(product.isFree != YES) {
            receipt = product.receipt;
        }
        
        // Check if already downloading the product
        if (product.status == UAProductStatusDownloading ||
            product.status == UAProductStatusWaiting) {
            UALOG(@"The same item is being downloaded, ignore this request");
            return;
        }

    } else if([parameter isKindOfClass: [SKPaymentTransaction class]]) {
        transaction = (SKPaymentTransaction *)parameter;
        productIdentifier = [[transaction payment] productIdentifier];
        // If the product was purchased previously, but no longer exits on UA
        // We can not restore it.
        if ([[StoreFront shared].inventory hasProductWithIdentifier:productIdentifier] == NO) {
            UALOG(@"Product no longer exists in inventory: %@", productIdentifier);
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            return;
        }

        // First purchase - Restore all workflow
        if (inRestoring) {
            if ([productIdentifier isEqual:firstPurchasedProduct.productIdentifier]) {
                UALOG(@"Current product is what user purchased, product id: %@", productIdentifier);
                RELEASE_SAFELY(firstPurchasedProduct);
            } else {
                if (unRestoredTransactions == nil) {
                    unRestoredTransactions = [[NSMutableArray alloc] init];
                }
                
                // filter out previous duplicate restore transaction
                BOOL contains = NO;
                for (SKPaymentTransaction *tran in unRestoredTransactions) {
                    if ([tran.payment.productIdentifier isEqual:transaction.payment.productIdentifier]) {
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                        contains = YES;
                    }
                }
                if (!contains) {
                    UALOG(@"Add transaction into unRestoreTransactions array: %@", productIdentifier);
                    [unRestoredTransactions addObject:transaction];
                }
                return;
            }
        }
        
        product = [self productFromTransaction:transaction];
        receipt = product.receipt;

        // !!!: Workaround: StoreKit in iOS4 can not finish transactions taking more than approx. 20 seconds
        /*
         * In iOS4, if purchasing takes more than 17 seconds to finish, than all
         * the transactions at that time will be regenerated repeatedly by StoreKit
         * after completion. 
         * Therefore, we need to filter out those duplicate transactions for 
         * the same product, while let the auto restored transaction to continue
         * with unfinished purchasing.
         */

        if ([[StoreFront shared] hasReceipt:product]) {
            // if product has been purchased before

            NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
                                 [NSString stringWithFormat: @"%@tmp.zip", productIdentifier]];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
                // if no unfinished download file exists
                // then this is a duplicate transaction, discarded
                UALOG(@"Remove duplicated transaction: %@", transaction);
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                return;
            }
        }
		
    }

    UALOG(@"Verify receipt for product: %@", product.productIdentifier);

    // Refresh cell, waiting for download
    product.status = UAProductStatusWaiting;
	[self addPendingProduct:product];

    NSString* server = [[Airship shared] server];
    NSString *urlString = [NSString stringWithFormat: @"%@/api/app/content/%@/download", server, productIdentifier];
    NSURL* itemURL = [NSURL URLWithString: urlString];
    UAStoreFrontRequest *verifyRequest = [[UAStoreFrontRequest alloc] initWithURL:itemURL];
    verifyRequest.transaction = transaction;
    verifyRequest.product = product;
    [verifyRequest setRequestMethod: @"POST"];
    verifyRequest.password = [[Airship shared] appSecret];
    verifyRequest.username = [[Airship shared] appId];
    [verifyRequest setTimeOutSeconds: 60];
    [verifyRequest setUseSessionPersistence: NO]; // We don't want to UA auth to S3
    [verifyRequest setDelegate: self];
    [verifyRequest setDidFinishSelector: @selector(downloadStoreItem:)];
    [verifyRequest setShouldRedirect: NO];

    [verifyRequest addRequestHeader: @"Content-Type" value: @"application/json"];
    
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [UAUtils udidHash], @"udid",
                                 STOREFRONT_VERSION, @"version", nil];
    if(receipt != nil)
        [data setObject:receipt forKey:@"transaction_receipt"];

    SBJsonWriter *writer = [SBJsonWriter new];
    [verifyRequest appendPostData: [[writer stringWithObject: data] dataUsingEncoding: NSUTF8StringEncoding]];
    [writer release];

    [networkQueue addOperation:verifyRequest];
}

//Pull an item from the store and decompress it into the ~/Documents directory
- (void)downloadStoreItem:(UAStoreFrontRequest*)request {
    // Handle server error
    if (request.responseStatusCode != 200) {
        NSString* okStr = UA_SF_TR(@"UA_OK");
        NSString* verificationErrorTitle = UA_SF_TR(@"UA_receipt_verification_failure_title");
        NSString* verificationError = UA_SF_TR(@"UA_receipt_verification_failure");

        UALOG(@"Failure verifying receipt");
        UALOG(@"Server Response: %d, %@, %@", request.responseStatusCode, request.responseHeaders, [request responseString]);

        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle: verificationErrorTitle
                                                               message: verificationError
                                                              delegate: nil
                                                     cancelButtonTitle: okStr
                                                     otherButtonTitles: nil];
        [failureAlert show];
        [failureAlert release];
        
        [self requestFailed:request];

        return;
    }

    BOOL clearBeforeDownload = NO;
    UAProduct* product = request.product;
    NSString* productIdentifier = product.productIdentifier;

    // Set download path
    NSString *tempDirectory = NSTemporaryDirectory();
    NSString *path = [tempDirectory stringByAppendingPathComponent:
                      [NSString stringWithFormat: @"%@.zip", productIdentifier]];
    NSString *tmpPath = [tempDirectory stringByAppendingPathComponent:
                         [NSString stringWithFormat: @"%@tmp.zip", productIdentifier]];
    
    UALOG(@"Download path: %@", path);
    UALOG(@"Temp download path: %@", tmpPath);
    
    // check if already downloading
    // SKPaymentQueue seems to handle transactions for same product at the same time for most cases
    // but still need to check explicitly here before downloading
    for (ASIHTTPRequest *req in [downloadNetworkQueue operations]) {
        if ([req.downloadDestinationPath isEqualToString:path]) {
            UALOG(@"A Transaction for same product is already being downloaded, Discarded");
            product.status = UAProductStatusDownloading;
            if (request.transaction)
                [[SKPaymentQueue defaultQueue] finishTransaction:request.transaction];
            return;
        }
    }

    // Check if product got updated before resume downloading
    if ([product hasUpdate] && [[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
        UALOG(@"Product has been updated since last interrupted download, delete previous temp file before resuming");
        clearBeforeDownload = YES;
    }
    
    // Save purchased receipt
    [[StoreFront shared] addReceipt:product];
    
    // Refresh inventory and UI just before downloading start
    product.status = UAProductStatusDownloading;
    [[StoreFront shared].inventory updateInventory];

    // Make download request
    [ASIHTTPRequest clearSession]; // Added to work around an old ASIHTTP session issue
    SBJsonParser *parser = [SBJsonParser new];
    NSDictionary* jsonResponse = [parser objectWithString:[request responseString]];
    [parser release];
    NSString* urlString = [jsonResponse objectForKey:@"content_url"];

    UAStoreFrontRequest *downloadRequest = [[UAStoreFrontRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    if (request.transaction)
        downloadRequest.transaction = request.transaction;
    downloadRequest.product = product;
    [downloadRequest setDownloadDestinationPath:path];
    [downloadRequest setTemporaryFileDownloadPath:tmpPath];
    if (clearBeforeDownload) {
        [downloadRequest removeTemporaryDownloadFile];
        [downloadRequest setTemporaryFileDownloadPath:tmpPath];
    }
    [downloadRequest setTimeOutSeconds: 60];
    [downloadRequest setDelegate: self];
    [downloadRequest setRequestMethod: @"GET"];
    [downloadRequest setAllowResumeForFileDownloads: YES];
    [downloadRequest setDownloadProgressDelegate:product];
    [downloadRequest setDidFinishSelector: @selector(downloadFinished:)];
    [downloadNetworkQueue addOperation: downloadRequest];

    [request release];
}

- (void)downloadFinished:(UAStoreFrontRequest *)request {
    UALOG(@"Server Response: %d, %@, %@", request.responseStatusCode, request.responseHeaders, [request responseString]);
    
    // Handle server error
    if (request.responseStatusCode != 200 && request.responseStatusCode != 206) {
        UALOG(@"Request Headers: %@", [request requestHeaders]);
        UALOG(@"Failure downloading content");
        UALOG(@"Server Response: %d, %@, %@", request.responseStatusCode, request.responseHeaders, [request responseString]);
        [self requestFailed:request];
        return;
    }

    request.product.status = UAProductStatusWaiting;
    NSString* ext = [[request downloadDestinationPath] pathExtension];
    if([ext caseInsensitiveCompare: @"zip"] == NSOrderedSame) {
        // request is retained by newly detached thread
        [NSThread detachNewThreadSelector:@selector(decompressContent:) toTarget:self withObject:request];
    } else {
        // TODO: do something sane with non .zip content
        UALOG(@"Content must end with .zip extention, ignoring");
    }

    [request release];
}

- (void)decompressContent:(UAStoreFrontRequest *)request {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString* path = [request downloadDestinationPath];
    ZipArchive* za = [[ZipArchive alloc] init];
    
    BOOL ret;
    
    if([za UnzipOpenFile:path]) {
        
        ret = [za UnzipFileTo: [NSString stringWithFormat: @"%@", downloadDirectory] overWrite:YES];
        
        if(!ret) {
            UALOG(@"Failed to decompress content %@", path);
            
            // Call our failure case here
            if ([[StoreFront shared].delegate respondsToSelector:@selector(productPurchaseFailed:)]) {
                [[StoreFront shared].delegate productPurchaseFailed:request.product];
            }
            
        } else {
            NSError *error = nil;
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL success = [fileManager removeItemAtPath:path error:&error];
            
            if (!success) {
                // Failed to remove the file from the temp directory - not fatal
                UALOG(@"Failed to remove downloaded item, %@", error);
            }
            
            // request is retained until after the selector is performed
            [self performSelectorOnMainThread:@selector(decompressFinished:) withObject:request waitUntilDone:[NSThread isMainThread]];
        }
        
        [za UnzipCloseFile];
    }
    
    [za release];
    [pool release];
}

- (void)decompressFinished:(UAStoreFrontRequest *)request {
    UALOG(@"Decompress Finished");
    [self removePendingProduct:request.product withTransaction:request.transaction];

    request.product.status = UAProductStatusInstalled;
    
    [[StoreFront shared].productListViewController refreshExitButton];
    [[StoreFront shared].delegate productPurchased:request.product];
}

- (void)requestFailed:(UAStoreFrontRequest *)request {
    
    NSError *error = [request error];
    
    UALOG(@"ERROR: NSError query result: %@", error);
    UALOG(@"Server Response: %d, %@ for product: %@", request.responseStatusCode, request.responseHeaders, request.product.productIdentifier);
    
    if (request.transaction) {
        [self failedTransaction:request.transaction];
    } else {
		// If the error not a cancel, need to call this:
		if([error code] != 4) {
            
            if ([[StoreFront shared].delegate respondsToSelector:@selector(productPurchaseFailed:)]) {
                [[StoreFront shared].delegate productPurchaseFailed:request.product];
            }
            
		}
	}
    
    [request.product resetStatus];
    [[StoreFront shared].productListViewController refreshExitButton];
    
    [request release];
}

#pragma mark -
#pragma mark Pending Transactions Management

- (void)loadPendingProducts {
    pendingProducts = [[NSMutableDictionary alloc] initWithContentsOfFile:kPendingProductsFile];
    if (pendingProducts == nil) {
        pendingProducts = [[NSMutableDictionary alloc] init];
    }
}

- (void)savePendingProducts {
    [pendingProducts writeToFile:kPendingProductsFile atomically:YES];
}

- (BOOL)hasPendingProduct:(UAProduct *)product {
    return [pendingProducts valueForKey:product.productIdentifier] != nil;
}

- (void)addPendingProduct:(UAProduct *)product {
    if (product.receipt == nil)
        product.receipt = @"";

    [pendingProducts setObject:product.receipt forKey:product.productIdentifier];
    [self savePendingProducts];
}

- (void)removePendingProduct:(UAProduct *)product withTransaction:(SKPaymentTransaction *)transaction {
    if (transaction)
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    [pendingProducts removeObjectForKey:product.productIdentifier];
    [self savePendingProducts];
}

- (UAProduct *)productFromTransaction:(SKPaymentTransaction *)transaction {
    NSString *identifier = transaction.payment.productIdentifier;
    UAProduct *product = [[StoreFront shared].inventory productWithIdentifier:identifier];
    if (transaction.transactionState == SKPaymentTransactionStatePurchased
        || transaction.transactionState == SKPaymentTransactionStateRestored)
        product.receipt = [[[NSString alloc] initWithData:transaction.transactionReceipt
                                                 encoding:NSUTF8StringEncoding] autorelease];
    return product;
}

- (void)resumePendingProducts {
    UALOG(@"Resume pending products in purchasing queue:");
	
    for (NSString *identifier in [pendingProducts allKeys]) {
		
		UALOG(@"Pending Product ID: %@", identifier);
		
        UAProduct *pendingProduct = [[StoreFront shared].inventory productWithIdentifier:identifier];
        pendingProduct.receipt = [pendingProducts objectForKey:identifier];
        [self verifyReceipt:pendingProduct];
    }
}

#pragma mark -

- (void)restoreAll {
    
    NSString* okStr = UA_SF_TR(@"UA_OK");
    NSString* cancelStr = UA_SF_TR(@"UA_Cancel");
    NSString* restoreTitle = UA_SF_TR(@"UA_content_restore_title");
    NSString* restoreMsg = UA_SF_TR(@"UA_content_restore_question");
    
    UIAlertView *restoreAlert = [[UIAlertView alloc] initWithTitle:restoreTitle
                                                           message:restoreMsg
                                                          delegate:self
                                                 cancelButtonTitle:cancelStr
                                                 otherButtonTitles:okStr, nil];
    [restoreAlert setTag:30];
    [restoreAlert show];
    [restoreAlert release];   
}

- (void)beginRestore {
    inRestoring = YES;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)firstTimeToPurchaseWithProduct:(UAProduct *)product {
    firstPurchasedProduct = [product retain];
    
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:firstPurchasedProduct.productIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark -
#pragma mark ASINetworkQueue Progress Delegate

- (void)setProgress:(float)progress {
    int downloadCount = downloadNetworkQueue.requestsCount;
    if ([[StoreFront shared].delegate respondsToSelector:@selector(productsDownloadProgress:count:)]) {
        [[StoreFront shared].delegate productsDownloadProgress:progress count:downloadCount];
    }
}

- (void)downloadNetworkQueueFinished:(ASINetworkQueue *)queue {
    // Prior to 2.1.6 we expliocitly set 100% but this can be invoked in other cancel scenarios
    //[self setProgress:1];
    
    // reset download queue progress
    [downloadNetworkQueue cancelAllOperations];
}

@end
