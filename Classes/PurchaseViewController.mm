    //
//  PurchaseViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 3/1/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "PurchaseViewController.h"
#import "GameViewController.h"
#import "Secrets.h"
#import "Effects.h"
#import "Tracking.h"

@implementation PurchaseViewController
@synthesize activity;
@synthesize vmmTitle;
@synthesize vmmPrice;
@synthesize vmmDescription;
@synthesize hdmTitle;
@synthesize hdmPrice;
@synthesize hdmDescription;
@synthesize vmmPurchase, hdmPurchase;
@synthesize loadingView;
@synthesize rmDescription,rmPrice,rmTitle,rmPurchase;

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
  self.loadingView.hidden = NO;
  SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObjects:VidmasterModeProductID, HDModeProductID, ReticulesProductID, nil]];
  request.delegate = self;
  [request start];
  [self updateView];
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
  self.loadingView.hidden = YES;
  if ( response == nil ) {
    // Pop up a dialog
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No response for the App Store"
                                          message:@"Could not connect to the app store, please try again later."
                                         delegate:self
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil];
    [av show];
    [av release];
    return;
  }
   
  MLog ( @"Found %d invalid Product IDS", response.invalidProductIdentifiers.count );
  for ( id invalidID in response.invalidProductIdentifiers ) {
    MLog ( @"ID %@ was invalid", invalidID );
  }
  
  if ( response.products.count == 0 && response.invalidProductIdentifiers.count > 0 ) {
    // Show an error
    // Pop up a dialog
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No response for the App Store"
                                                 message:@"Could not connect to the app store, (invalid response), please try again later."
                                                delegate:self
                                       cancelButtonTitle:@"Ok"
                                       otherButtonTitles:nil];
    [av show];
    [av release];
    return;
  }
  
  // populate UI
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
  MLog ( @"Got %d products back", [response.products count] );
  for ( SKProduct* p in response.products ) {
    [dict setObject:p forKey:p.productIdentifier];
  }
  SKProduct *product;
  product = [dict objectForKey:VidmasterModeProductID];
  if ( product != nil ) {
    self.vmmTitle.text = product.localizedTitle;
    self.vmmDescription.text = product.localizedDescription;
    self.vmmPrice.text = [self formatCurrency:product];
  }
  
  product = [dict objectForKey:HDModeProductID];
  if ( product != nil ) {
    self.hdmTitle.text = product.localizedTitle;
    self.hdmDescription.text = product.localizedDescription;
    self.hdmPrice.text = [self formatCurrency:product];
  }
  
  product = [dict objectForKey:ReticulesProductID];
  if ( product != nil ) {
    self.rmTitle.text = product.localizedTitle;
    self.rmDescription.text = product.localizedDescription;
    self.rmPrice.text = [self formatCurrency:product];
  }
  
  
  [self updateView];
  [request autorelease];
}


- (BOOL)canPurchase {
  if ([SKPaymentQueue canMakePayments]) {
    return YES;
  } else {
    // Pop up a dialog
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Purchases disabled"
                                               message:@"Purchases are disabled on this device, please enable and try again."
                                                delegate:self
                                       cancelButtonTitle:@"Ok"
                                       otherButtonTitles:nil];
    [av show];
    [av release];
    return NO;
  }
  return NO;
}  

- (IBAction)restore:(id)sender {
  [Tracking trackEvent:@"store" action:@"restore" label:@"" value:[self canPurchase]];
  if ( [self canPurchase] ) {
    MLog (@"Starting restore" );
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
  }
}

- (IBAction)buyHDMode:(id)sender {
  [Tracking trackEvent:@"store" action:@"hd" label:@"" value:[self canPurchase]];
  if ( [self canPurchase] ) {
    SKPayment* tPayment = [SKPayment paymentWithProductIdentifier:HDModeProductID];
    [[SKPaymentQueue defaultQueue] addPayment:tPayment];
  }
}
      
- (IBAction)buyVidmasterMode:(id)sender {
  [Tracking trackEvent:@"store" action:@"mc" label:@"" value:[self canPurchase]];
  if ( [self canPurchase] ) {
    SKPayment* tPayment = [SKPayment paymentWithProductIdentifier:VidmasterModeProductID];
    [[SKPaymentQueue defaultQueue] addPayment:tPayment];
  }
}

- (IBAction)buyReticuleMode:(id)sender {
  [Tracking trackEvent:@"store" action:@"rm" label:@"" value:[self canPurchase]];
  if ( [self canPurchase] ) {
    SKPayment* tPayment = [SKPayment paymentWithProductIdentifier:ReticulesProductID];
    [[SKPaymentQueue defaultQueue] addPayment:tPayment];
  }
}



- (IBAction)updateView {
  // see if we need to remove the "purchased" buttons
  if ( [[NSUserDefaults standardUserDefaults] boolForKey:kHaveTTEP] ) {
    self.hdmPurchase.hidden = YES;
    self.hdmPrice.text = @"Installed";
  } else {
    self.hdmPurchase.hidden = NO;
  }
  if ( [[NSUserDefaults standardUserDefaults] boolForKey:kHaveVidmasterMode] ) {
    self.vmmPurchase.hidden = YES;
    self.vmmPrice.text = @"Installed";
  } else {
    self.vmmPurchase.hidden = NO;
  }
}  


- (void)appear {
  CAAnimation *group = [Effects appearAnimation];
  for ( UIView *v in self.view.subviews ) {
    [v.layer removeAllAnimations];
    [v.layer addAnimation:group forKey:nil];
  }
}

- (void)disappear {
  CAAnimation *group = [Effects disappearAnimation];
  for ( UIView *v in self.view.subviews ) {
    [v.layer removeAllAnimations];
    [v.layer addAnimation:group forKey:nil];
  }
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
