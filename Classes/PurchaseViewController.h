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

@interface PurchaseViewController : UIViewController<IKPurchaseDelegate, SKProductsRequestDelegate> {
  IBOutlet UIActivityIndicatorView *activity;
  IBOutlet UILabel *vmmTitle;
  IBOutlet UILabel *vmmPrice;
  IBOutlet UILabel *vmmDescription;
  IBOutlet UILabel *hdmTitle;
  IBOutlet UILabel *hdmPrice;
  IBOutlet UILabel *hdmDescription;
  
}

@property(nonatomic,retain) UIActivityIndicatorView *activity;
@property(nonatomic,retain) UILabel *vmmTitle;
@property(nonatomic,retain) UILabel *vmmPrice;
@property(nonatomic,retain) UILabel *vmmDescription;
@property(nonatomic,retain) UILabel *hdmTitle;
@property(nonatomic,retain) UILabel *hdmPrice;
@property(nonatomic,retain) UILabel *hdmDescription;

- (IBAction)openDoors;
- (void)productWithKey:(NSString*)productKey success:(bool)success;
- (IBAction)buyHDMode:(id)sender;
- (IBAction)buyVidmasterMode:(id)sender;
- (IBAction)done:(id)sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
- (NSString*)formatCurrency:(SKProduct*)product;

@end
