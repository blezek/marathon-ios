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
#import "UAStoreKitObserver.h"
#import "UAInventory.h"
#import "UAStoreFrontSplitViewController.h"
#import "UAStoreFrontViewController.h"
#import "ASIDownloadCache.h"


@implementation StoreFront

@synthesize rootViewController;
@synthesize productListViewController;
@synthesize sfObserver;
@synthesize inventory;
@synthesize delegate;

@synthesize purchaseReceipts;
@synthesize originalSubviews;
@synthesize localizationBundle;
@synthesize originalWindow;
@synthesize isiPad;
@synthesize downloadsPreventStoreFrontExit;
@synthesize uaWindow;
@synthesize isVisible;

SINGLETON_IMPLEMENTATION(StoreFront)

static BOOL runiPhoneTargetOniPad = NO;
+ (void)setRuniPhoneTargetOniPad:(BOOL)value {
    runiPhoneTargetOniPad = value;
}

-(void)dealloc {
    RELEASE_SAFELY(rootViewController);
    RELEASE_SAFELY(productListViewController);
    RELEASE_SAFELY(sfObserver);
    RELEASE_SAFELY(inventory);
    self.delegate = nil;
    
    RELEASE_SAFELY(originalWindow);
    RELEASE_SAFELY(originalSubviews);

    RELEASE_SAFELY(purchaseReceipts);
    RELEASE_SAFELY(localizationBundle);
    RELEASE_SAFELY(uaWindow);
    
    [super dealloc];
}

+ (void)land {
    // If the app is landing, cancel all networking explicitly
    [[StoreFront shared].sfObserver enterBackground];
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver: [StoreFront shared].sfObserver];
}

- (void)loadReceipts {
    self.purchaseReceipts = [NSMutableDictionary dictionaryWithContentsOfFile: kReceiptHistoryFile];
    if(purchaseReceipts == nil) {
        self.purchaseReceipts = [NSMutableDictionary dictionary];
    }
}

- (void)saveReceipts {
    // Don't want to potentially stomp on the file by saving a blank dictionary
    // when the receipts haven't finished loading
    if([purchaseReceipts count] > 0) {
        UALOG(@"Saving %d receipts", [purchaseReceipts count]);
        BOOL saved = [purchaseReceipts writeToFile:kReceiptHistoryFile atomically:YES];
        if(!saved) {
            UALOG(@"Unable to save receipt data to file");
        }
    }
}

- (void)addReceipt:(UAProduct *)product {
    UALOG(@"Add receipt for product %@", product.productIdentifier);
    NSNumber* rev = [NSNumber numberWithInt:product.revision];
    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:
                          rev, @"revision",
                          product.receipt, @"receipt",
                          nil];

    [purchaseReceipts setObject:data forKey:product.productIdentifier];
    [self saveReceipts];
}

- (BOOL)hasReceipt:(UAProduct *)product {
    return [[purchaseReceipts allKeys] containsObject:product.productIdentifier];
}

// This will migrate files from the oldPath to the new path
- (BOOL)directoryExistsAtPath:(NSString *)path orOldPath:(NSString *)oldPath {
    
    // Check for the new path - this will be false on the first run with 2.1.5, or ever
    BOOL uaExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if (!uaExists) {
        uaExists = [[NSFileManager defaultManager] fileExistsAtPath:oldPath];
        
        // If the oldPath exists, then we need to move everything from that to the new path
        if(uaExists) {
            [[NSFileManager defaultManager] moveItemAtPath:oldPath
                                                    toPath:path
                                                     error:nil];
            UALOG(@"Files migrated to NSLibraryDirectory: %@", 
                  [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil]);
        }
    }
    
    return uaExists;
}

- (BOOL)setDownloadDirectory:(NSString *)path {
    BOOL success = YES;
    
    // It'll be used default dir when path is nil.
    if (path == nil) {
        // The default is created in sfObserver's init
        UALOG(@"Using Default Download Directory: %@", self.sfObserver.downloadDirectory);
        return success;
    }
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        success = [[NSFileManager defaultManager] createDirectoryAtPath:path 
                                              withIntermediateDirectories:YES 
                                                               attributes:nil 
                                                                    error:nil];
    }
    
    if(success) {
        [self.sfObserver setDownloadDirectory:path];
        UALOG(@"New Download Directory: %@", self.sfObserver.downloadDirectory);
    }
    
    return success;
}

-(id)init {
    UALOG(@"Initialize StoreFront.");

    if (self = [super init]) {
        BOOL uaExists = [self directoryExistsAtPath:kUADirectory orOldPath:kUAOldDirectory];
        if(!uaExists) {
            [[NSFileManager defaultManager] createDirectoryAtPath:kUADirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // In StoreFront, we set the cache policy to use cache if possible.
        // And currently we only use this download cache in UAAsyncImageView.
        // Cache is storaged for session duration but not permanetly.
        [[ASIDownloadCache sharedCache] setDefaultCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];

        NSString* path = [[[NSBundle mainBundle] resourcePath]
                          stringByAppendingPathComponent:@"UAStoreFrontLocalization.bundle"];
        self.localizationBundle = [NSBundle bundleWithPath:path];

        [self loadReceipts];
        
        sfObserver = [[UAStoreKitObserver alloc] init];
        inventory = [[UAInventory alloc] init];

        // To partially support rotation when present by displayStoreFront
        userOrientation = UIInterfaceOrientationPortrait;
        storeOrientation = UIInterfaceOrientationPortrait;

        NSString *deviceType = [UIDevice currentDevice].model;
        if ([deviceType hasPrefix:@"iPad"] && !runiPhoneTargetOniPad) {
            isiPad = YES;
            UAStoreFrontSplitViewController *svc = [[UAStoreFrontSplitViewController alloc] init];
            productListViewController = [svc productListViewController];
            rootViewController = (UIViewController *)svc;
        } else {
            productListViewController = [[UAStoreFrontViewController alloc]
                                         initWithNibName:@"UAStoreFront" bundle:nil];
            rootViewController = [[UINavigationController alloc] initWithRootViewController:productListViewController];
        }

        isVisible = NO;
        downloadsPreventStoreFrontExit = NO;
    }
    return self;
}

+ (void)displayStoreFront:(UIViewController *)viewController animated:(BOOL)animated{
    StoreFront* sf = [StoreFront shared];
    sf->animated = animated;

    if (!sf.isiPad) {
        [viewController presentModalViewController:sf.rootViewController animated:animated];
    } else {
        if (sf.uaWindow == nil) {
            sf.uaWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [sf.uaWindow addSubview:sf.rootViewController.view];
        }
        [sf.rootViewController viewWillAppear:animated];
        [sf.uaWindow makeKeyAndVisible];
    }
    sf->isVisible = YES;
}

// DEPRECATED - Use displayStoreFront:animated:
+ (void)displayStoreFront {
    UIWindow* kwin =  [[UIApplication sharedApplication] keyWindow];
    StoreFront* sf = [StoreFront shared];
    sf->userOrientation = [UIApplication sharedApplication].statusBarOrientation;
    sf.originalSubviews = [kwin subviews];
    sf.originalWindow = kwin;
    for (UIView *view in sf.originalSubviews) {
        [view removeFromSuperview];
    }
    [UIApplication sharedApplication].statusBarOrientation = sf->storeOrientation;
    
    [kwin addSubview:sf.rootViewController.view];
    sf->isVisible = YES;
}

// DEPRECATED - Use displayStoreFront:animated:
// Thanks to jjthrash http://gist.github.com/228050
+ (UIView*)makeStoreFrontView {

    UIView* tbc = [StoreFront shared].rootViewController.view;

    CGFloat statusBarOffset = [UIApplication sharedApplication].statusBarHidden ? 0 : 20;
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft
        || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        tbc.frame = CGRectMake(tbc.frame.origin.x,
                               tbc.frame.origin.y,
                               480,
                               320 - statusBarOffset);
    } else {
        tbc.frame = CGRectMake(tbc.frame.origin.x,
                               tbc.frame.origin.y,
                               320,
                               480 - statusBarOffset);
    }

    return tbc;
}

+ (void)quitStoreFront {
    StoreFront* sf = [StoreFront shared];

    [sf saveReceipts];

    if([sf.delegate respondsToSelector:@selector(storeFrontWillHide)]) {
        [sf.delegate performSelectorOnMainThread:@selector(storeFrontWillHide) 
                                      withObject:nil waitUntilDone:YES];
    }
    
    if (sf.isiPad) {
        [sf.rootViewController viewWillDisappear:sf->animated];
    }
 
    if (sf.rootViewController.parentViewController != nil) {
        // for iPhone displayStoreFront:animated:
        [sf.rootViewController dismissModalViewControllerAnimated:sf->animated];
        
        // KEEP in case rotating/positioning bug happens again
        //UIViewController *con = sf.rootViewController.parentViewController;
        //[con dismissModalViewControllerAnimated:sf->animated];
        // Workaround. ModalViewController does not handle resizing correctly if
        // dismissed in landscape when status bar is visible
        //if ([UIApplication sharedApplication].statusBarHidden == NO) {
        //    con.view.frame = UAFrameForCurrentOrientation(con.view.frame);
        //}
    } else if (sf.rootViewController.view.superview == sf.uaWindow) {
        // for iPad displayStoreFront:animated:
        sf.uaWindow.hidden = YES;
    } else if (sf.rootViewController.view.superview == sf.originalWindow) {
        // For displayStoreFront
        sf->storeOrientation = [UIApplication sharedApplication].statusBarOrientation;
        [sf.rootViewController.view removeFromSuperview];
        [UIApplication sharedApplication].statusBarOrientation = sf->userOrientation;
        for (UIView *view in sf.originalSubviews) {
            [sf.originalWindow addSubview:view];
        }
    } else if (sf.rootViewController.view.superview != nil) {
        // For makeStoreFrontView
        [sf.rootViewController.view removeFromSuperview];
    } else {
        // For other circumstances. e.g custom showing rootViewController
        // or changed the showing code of StoreFront
        UALOG(@"StoreFront rootViewController did not add to the application in an official way. \
              You may want to put your own quiting code here.");
    }
    
    sf->isVisible = NO;

    if([sf.delegate respondsToSelector: @selector(storeFrontDidHide)]) {
        [sf.delegate performSelectorOnMainThread:@selector(storeFrontDidHide) 
                                      withObject:nil waitUntilDone:YES];
    }
}

+ (void)setOrderBy:(NSString *)key {
    [self setOrderBy:key ascending:NO];
}

+ (void)setOrderBy:(NSString *)key ascending:(BOOL)ascending {
    [[StoreFront shared].inventory setOrderBy:key ascending:ascending];
}

+ (void)purchase:(NSString *)productIdentifier {
    [[StoreFront shared].inventory purchase:productIdentifier];
}

@end
