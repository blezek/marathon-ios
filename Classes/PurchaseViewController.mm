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
@synthesize tipDescription;
@synthesize loadingView;
@synthesize restoreButton, tipButton;
@synthesize allProductIDs, validProductIDs, allProductDescriptions, allProductResponses;
@synthesize tipSelector, thankYou;

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


- (void)viewDidLoad {
    [super viewDidLoad];
  thankYou.hidden=YES;
  allProductIDs = [[NSArray alloc] initWithObjects: Tip1, Tip2, Tip3, Tip4, Tip5, Tip6, Tip7, nil];
  validProductIDs = [[NSMutableArray alloc] init];
  allProductDescriptions = [[NSMutableDictionary alloc] init];
  allProductResponses = [[NSMutableDictionary alloc] init];
  [tipButton setHidden:YES];
  [tipSelector setHidden:YES];
  [tipSelector addTarget:self action:@selector(tipSelectorChanged:) forControlEvents:UIControlEventValueChanged];
  [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (IBAction)openDoors {
  
    //This is something we are really only interested on first access.
  if ( ![[NSUserDefaults standardUserDefaults] boolForKey:kHasAttemptedRestore] ) {
    [self restore:self]; //Comment this out if you want to test the restore button.
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasAttemptedRestore];
  }
  
  //If the user has already tipped, tell them how cool they are and don't show any more purchases.
  if ([[NSUserDefaults standardUserDefaults] boolForKey:kHasPurchasedTip]) {
    [self updateView];
    return;
  }
  
  // Request our list
  [self.activity startAnimating];
  self.loadingView.hidden = NO;
  SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithArray:allProductIDs]];
  request.delegate = self;
  [request start];
  
  [tipButton setEnabled:YES];
  [restoreButton setEnabled:YES];
  
  [tipSelector removeAllSegments];
  [tipSelector setHidden:NO];
  [tipDescription setText:@""];
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
  MLog ( @"Got %d products back", (int)[response.products count] );
  for ( SKProduct* p in response.products ) {
    [dict setObject:p forKey:p.productIdentifier];
  }
  
  int n = 0;
   for ( int i = 0; i < [allProductIDs count]; ++i ) {
      for ( SKProduct* p in response.products ) {
        if ( [[p productIdentifier] isEqualToString:[allProductIDs objectAtIndex:i]] ) {
          [validProductIDs addObject:[allProductIDs objectAtIndex:i]];
          [tipSelector insertSegmentWithTitle:[self formatCurrency:p] atIndex:n animated:YES];
          [allProductDescriptions setObject:p.localizedTitle forKey:[allProductIDs objectAtIndex:i]];
          [allProductResponses setObject:p forKey:[allProductIDs objectAtIndex:i]];
          n++;
        }
    }
  }
  
  [self updateView];
  [request autorelease];
}

- (IBAction)tipSelectorChanged:(id)sender {
  NSString *description = [allProductDescriptions objectForKey:[allProductIDs objectAtIndex:[tipSelector selectedSegmentIndex]]];
  if ( description != nil ) {
    [tipDescription setText:description];
    [tipButton setHidden:NO];
  }
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
  ////[Tracking trackEvent:@"store" action:@"restore" label:@"" value:[self canPurchase]];
  if ( [self canPurchase] ) {
    MLog (@"Starting restore" );
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
  }
}

- (IBAction)buyTip:(id)sender {
  int selectedTipIndex = [tipSelector selectedSegmentIndex];
  if ( [self canPurchase] && selectedTipIndex >= 0  ) {
    [tipButton setEnabled:NO];
    [restoreButton setEnabled:NO];
    SKPayment* tPayment = [SKPayment paymentWithProduct:[allProductResponses objectForKey:[validProductIDs objectAtIndex:selectedTipIndex]]];
    [[SKPaymentQueue defaultQueue] addPayment:tPayment];
  }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
  MLog(@"Transaction Updated!");
  for ( SKPaymentTransaction* transaction in transactions ) {
    switch (transaction.transactionState) {
      case(SKPaymentTransactionStatePurchasing) :
        MLog(@"SKPaymentTransactionStatePurchasing");
        break;
      case(SKPaymentTransactionStateRestored) :
        MLog(@"SKPaymentTransactionStateRestored");
        MLog(@"This player has restored...");
      case(SKPaymentTransactionStatePurchased) :
        MLog(@"This player has tipped! %@", transaction.payment.productIdentifier);
        //Set prefs here indicating that a tip was made
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasPurchasedTip];
        [self updateView];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        break;
      case(SKPaymentTransactionStateFailed) :
        MLog(@"SKPaymentTransactionStateFailed");
        [tipButton setEnabled:YES];
        [restoreButton setEnabled:YES];
        break;
      case(SKPaymentTransactionStateDeferred) :
        MLog(@"SKPaymentTransactionStateDeferred");
        break;
      default:
        MLog(@"Unknown Transaction State");
        [tipButton setEnabled:YES];
        [restoreButton setEnabled:YES];
        break;
    }
  }
}

- (IBAction)updateView {
  // see if we need to remove the "tip" buttons
  if ( [[NSUserDefaults standardUserDefaults] boolForKey:kHasPurchasedTip] ) {
        restoreButton.hidden=YES;
        tipButton.hidden=YES;
        tipSelector.hidden=YES;
        tipDescription.hidden=YES;
        thankYou.hidden=NO;
  } else {
        thankYou.hidden=YES;
  }
}  


- (void)appear {
  [Effects appearRevealingView:self.view];
}

- (void)disappear {
  [Effects disappearHidingView:self.view];

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
