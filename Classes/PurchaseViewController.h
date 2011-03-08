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
@interface PurchaseViewController : UIViewController<SKProductsRequestDelegate> {
  IBOutlet UIActivityIndicatorView *activity;
  IBOutlet UILabel *vmmTitle;
  IBOutlet UILabel *vmmPrice;
  IBOutlet UITextView *vmmDescription;
  IBOutlet UILabel *hdmTitle;
  IBOutlet UILabel *hdmPrice;
  IBOutlet UITextView *hdmDescription;
  
  IBOutlet RoundedView *loadingView;
  IBOutlet UIButton *hdmPurchase;
  IBOutlet UIButton *vmmPurchase;
  
}

@property(nonatomic,retain) UIActivityIndicatorView *activity;
@property(nonatomic,retain) UILabel *vmmTitle;
@property(nonatomic,retain) UILabel *vmmPrice;
@property(nonatomic,retain) UITextView *vmmDescription;
@property(nonatomic,retain) UILabel *hdmTitle;
@property(nonatomic,retain) UILabel *hdmPrice;
@property(nonatomic,retain) UITextView *hdmDescription;
@property(nonatomic,retain) UIButton *hdmPurchase;
@property(nonatomic,retain) UIButton *vmmPurchase;
@property(nonatomic,retain) UIView *loadingView;

- (IBAction)openDoors;
- (IBAction)buyHDMode:(id)sender;
- (IBAction)buyVidmasterMode:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)restore:(id)sender;
- (BOOL)canPurchase;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (IBAction)updateView;
- (IBAction)appear;
- (IBAction)disappear;

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
- (NSString*)formatCurrency:(SKProduct*)product;


@end
