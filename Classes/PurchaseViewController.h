//
//  PurchaseViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 3/1/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "RoundedView.h"
@interface PurchaseViewController : UIViewController<SKProductsRequestDelegate, SKPaymentTransactionObserver> {
  IBOutlet UIActivityIndicatorView *activity;
  
  IBOutlet RoundedView *loadingView;
  
  IBOutlet UITextView *tipDescription;
  IBOutlet UIButton *restoreButton;
  IBOutlet UIButton *tipButton;
  IBOutlet UISegmentedControl *tipSelector;
  IBOutlet UIView *thankYou;
}

@property(nonatomic,retain) UIActivityIndicatorView *activity;

@property(nonatomic,retain) UITextView *tipDescription;
@property(nonatomic,retain) NSArray *allProductIDs;
@property(nonatomic,retain) NSMutableArray *validProductIDs;
@property(nonatomic,retain) NSMutableDictionary *allProductResponses;
@property(nonatomic,retain) NSMutableDictionary *allProductDescriptions;

@property(nonatomic,retain) UIButton *restoreButton;
@property(nonatomic,retain) UIButton *tipButton;
@property(nonatomic,retain) IBOutlet UISegmentedControl *tipSelector;
@property(nonatomic,retain) IBOutlet UIView *thankYou;

@property(nonatomic,retain) UIView *loadingView;

- (IBAction)openDoors;
- (IBAction)buyTip:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)restore:(id)sender;
- (BOOL)canPurchase;
- (IBAction)tipSelectorChanged:(id)sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (IBAction)updateView;
- (IBAction)appear;
- (IBAction)disappear;

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
- (NSString*)formatCurrency:(SKProduct*)product;


@end
