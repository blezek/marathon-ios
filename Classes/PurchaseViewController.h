//
//  PurchaseViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 3/1/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "InventoryKit.h"

@interface PurchaseViewController : UIViewController<SKProductsRequestDelegate> {
  IBOutlet UIActivityIndicatorView *activity;
  IBOutlet UILabel *vmmTitle;
  IBOutlet UILabel *vmmPrice;
  IBOutlet UILabel *vmmDescription;
  IBOutlet UILabel *hdmTitle;
  IBOutlet UILabel *hdmPrice;
  IBOutlet UILabel *hdmDescription;
  
  IBOutlet UIButton *hdmPurchase;
  IBOutlet UIButton *vmmPurchase;
  
}

@property(nonatomic,retain) UIActivityIndicatorView *activity;
@property(nonatomic,retain) UILabel *vmmTitle;
@property(nonatomic,retain) UILabel *vmmPrice;
@property(nonatomic,retain) UILabel *vmmDescription;
@property(nonatomic,retain) UILabel *hdmTitle;
@property(nonatomic,retain) UILabel *hdmPrice;
@property(nonatomic,retain) UILabel *hdmDescription;
@property(nonatomic,retain) UIButton *hdmPurchase;
@property(nonatomic,retain) UIButton *vmmPurchase;

- (IBAction)openDoors;
- (IBAction)buyHDMode:(id)sender;
- (IBAction)buyVidmasterMode:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)restore:(id)sender;
- (BOOL)canPurchase;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (IBAction)updateView;

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
- (NSString*)formatCurrency:(SKProduct*)product;


@end
