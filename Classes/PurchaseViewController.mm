    //
//  PurchaseViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 3/1/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "PurchaseViewController.h"
#import "InventoryKit.h"
#import "GameViewController.h"
#import "Secrets.h"

@implementation PurchaseViewController
@synthesize activity;
@synthesize vmmTitle;
@synthesize vmmPrice;
@synthesize vmmDescription;
@synthesize hdmTitle;
@synthesize hdmPrice;
@synthesize hdmDescription;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (IBAction)openDoors {
  // Request our list
  [self.activity startAnimating];
  SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObjects:VidmasterModeProductID, HDModeProductID, nil]];
  request.delegate = self;
  [request start];
}

- (NSString*)formatCurrency:(SKProduct*)product {
  NSDecimalNumber *price = product.price;
  NSLocale *priceLocale = product.priceLocale;

  NSNumberFormatter *currencyFormatter = [[[NSNumberFormatter alloc] init] autorelease];
  [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [currencyFormatter setLocale:priceLocale];
  
  // NSString *currencyString = [currencyFormatter internationalCurrencySymbol]; // EUR, GBP, USD...
  NSString *format = [currencyFormatter positiveFormat];
  // format = [format stringByReplacingOccurrencesOfString:@"¤" withString:currencyString];
  // ¤ is a placeholder for the currency symbol
  [currencyFormatter setPositiveFormat:format];

  return [currencyFormatter stringFromNumber:price];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
  [self.activity stopAnimating];
  if ( response == nil ) {
    // Pop up a dialog
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No response for the App Store"
                                          message:@"Could not connect to the app store, please try again later."
                                         delegate:self
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil];
    [av show];
    [av release];
  }
    
  // populate UI
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
  for ( SKProduct* p in response.products ) {
    [dict setObject:p forKey:p.productIdentifier];
  }
  SKProduct *product;
  product = [dict objectForKey:VidmasterModeProductID];
  self.vmmTitle.text = product.localizedTitle;
  self.vmmDescription.text = product.localizedDescription;
  self.vmmPrice.text = [self formatCurrency:product];
  
  product = [dict objectForKey:HDModeProductID];
  self.hdmTitle.text = product.localizedTitle;
  self.hdmDescription.text = product.localizedDescription;
  self.hdmPrice.text = [self formatCurrency:product];
  
  [request autorelease];
}


- (IBAction)buyHDMode:(id)sender {
  [InventoryKit purchaseProduct:HDModeProductID delegate:self];
}

-(void)productWithKey:(NSString*)productKey success:(bool)success {
  if ( success ) {
    [InventoryKit activateProduct:productKey];
  }
  MLog ( @"Bought %@", productKey );
}

- (IBAction)buyVidmasterMode:(id)sender {
  [InventoryKit purchaseProduct:VidmasterModeProductID delegate:self];
}

- (IBAction)done:(id)sender {
  [[GameViewController sharedInstance] cancelStore];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  // Nothing to do but go home
  [self done:self];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
