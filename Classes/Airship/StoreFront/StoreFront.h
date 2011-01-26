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
#import "Airship.h"
#import "StoreFrontDelegate.h"

#define STOREFRONT_VERSION @"2.1.6"
#define UA_SF_TR(key) [[StoreFront shared].localizationBundle localizedStringForKey:key value:@"" table:nil]

UIKIT_EXTERN NSString *const UAContentsDisplayOrderTitle;
UIKIT_EXTERN NSString *const UAContentsDisplayOrderID;
UIKIT_EXTERN NSString *const UAContentsDisplayOrderPrice;


@class UAInventory;
@class UAStoreKitObserver;
@class UAStoreFrontViewController;

@interface StoreFront : NSObject {
    // Essential StoreFront component
    UIViewController *rootViewController;
    UAStoreFrontViewController *productListViewController;
    UAStoreKitObserver* sfObserver;
    UAInventory* inventory;

    NSObject<StoreFrontDelegate> *delegate;
    NSMutableDictionary* purchaseReceipts;

    BOOL isVisible;
    BOOL animated;
    NSArray *originalSubviews;
    UIWindow *originalWindow;
    UIInterfaceOrientation userOrientation;
    UIInterfaceOrientation storeOrientation;
    UIWindow *uaWindow;

    NSBundle *localizationBundle;
    BOOL isiPad;
    BOOL downloadsPreventStoreFrontExit;
}

@property (nonatomic, retain, readonly) UIViewController *rootViewController;
@property (nonatomic, retain, readonly) UAStoreFrontViewController *productListViewController;
@property (nonatomic, retain, readonly) UAStoreKitObserver* sfObserver;
@property (nonatomic, assign) NSObject<StoreFrontDelegate> *delegate;
@property (nonatomic, retain) UAInventory* inventory;

@property (nonatomic, retain) NSMutableDictionary* purchaseReceipts;

@property (nonatomic, assign, readonly) BOOL isVisible;
@property (nonatomic, retain) NSArray *originalSubviews;
@property (nonatomic, retain) UIWindow *originalWindow;
@property (nonatomic, retain) UIWindow *uaWindow;

@property (nonatomic, retain) NSBundle *localizationBundle;
@property (nonatomic, assign, readonly) BOOL isiPad;
@property (nonatomic, assign) BOOL downloadsPreventStoreFrontExit;

SINGLETON_INTERFACE(StoreFront)

+ (void)setRuniPhoneTargetOniPad:(BOOL)value;

+ (void)quitStoreFront;
/*
 Present the store front as modalViewController over viewController
 */
+ (void)displayStoreFront:(UIViewController *)viewController animated:(BOOL)animated;
/*
 Display StoreFront in the current key window

 Deprecated.
 Does not fully support rotation
 Use displayStoreFront:animated:
 */
+ (void)displayStoreFront __UA_DEPRECATED;

/*
 Return StoreFront's view

 Deprecated
 Does not support rotation
 Has to resize the view to the right frame before adding to self.view,
 if adding to a navigation controller or tab bar controller's view
 Use displayStoreFront:animated:
 */
+ (UIView*)makeStoreFrontView __UA_DEPRECATED;

/*
 Set the displaying order of the product items in content tab
 Default is order by product ID, descending
 */
+ (void)setOrderBy:(NSString *)key;
+ (void)setOrderBy:(NSString *)key ascending:(BOOL)ascending;

/*
 Directly purchase a specific product
 */
+ (void)purchase:(NSString *)productIdentifier;

+ (void)land;

- (void)addReceipt:(UAProduct *)product;
- (BOOL)hasReceipt:(UAProduct *)product;
- (BOOL)directoryExistsAtPath:(NSString *)path orOldPath:(NSString *)oldPath;
- (BOOL)setDownloadDirectory:(NSString *)path;

@end
