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
#import "UAInventory.h"
#import "UAStoreFrontViewController.h"
#import "UAProductDetailViewController.h"
#import "UAStoreFrontCell.h"
#import "UAStoreKitObserver.h"

// Weak link to this notification since it doesn't exist in iOS 3.x
UIKIT_EXTERN NSString* const UIApplicationDidEnterBackgroundNotification __attribute__((weak_import));
UIKIT_EXTERN NSString* const UIApplicationDidBecomeActiveNotification __attribute__((weak_import));

NSString *const UAContentsDisplayOrderTitle = @"title";
NSString *const UAContentsDisplayOrderID = @"productIdentifier";
NSString *const UAContentsDisplayOrderPrice = @"priceNumber";

@implementation UAStoreFrontViewController

@synthesize productTable;
@synthesize filterSegmentedControl;
@synthesize activityView;
@synthesize statusLabel;
@synthesize detailViewController;
@synthesize loadingView;
@synthesize toolBar;
@dynamic products;

#pragma mark -
#pragma mark UIViewController

- (void)dealloc {
    [inventory unregisterObserver:self];
    inventory = nil;
    
    RELEASE_SAFELY(productTable);
    RELEASE_SAFELY(filterSegmentedControl);
    RELEASE_SAFELY(activityView);
    RELEASE_SAFELY(statusLabel);
    RELEASE_SAFELY(filteredProducts);
    RELEASE_SAFELY(productDetailViewNibName);
    RELEASE_SAFELY(productDetailViewClassName);

    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initNibNames];
    }
    return self;
}

- (void)initNibNames {
    productDetailViewNibName = [@"UAProductDetail" retain];
    productDetailViewClassName = [@"UAProductDetailViewController" retain];
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    wasBackgrounded = NO;
    
    if (&UIApplicationDidEnterBackgroundNotification != NULL) {
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(enterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
	}
    
    if (&UIApplicationDidBecomeActiveNotification != NULL) {
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(enterForeground)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
	}
    
    self.title = UA_SF_TR(@"UA_Content");   

    [filterSegmentedControl setTitle:UA_SF_TR(@"UA_filter_all") forSegmentAtIndex:ProductTypeAll];
    [filterSegmentedControl setTitle:UA_SF_TR(@"UA_filter_installed") forSegmentAtIndex:ProductTypeInstalled];
    [filterSegmentedControl setTitle:UA_SF_TR(@"UA_filter_updates") forSegmentAtIndex:ProductTypeUpdated];
    [filterSegmentedControl setEnabled:NO forSegmentAtIndex:ProductTypeInstalled];
    [filterSegmentedControl setEnabled:NO forSegmentAtIndex:ProductTypeUpdated];
    [filterSegmentedControl setSelectedSegmentIndex:ProductTypeAll];

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(done:)] autorelease];
    
    statusLabel.text = NSLocalizedStringWithDefaultValue(@"UA_Loading", nil, [StoreFront shared].localizationBundle, @"Loading...", @"");
    statusLabel.hidden = NO;
    [activityView startAnimating];

    filteredProducts = [[NSMutableArray alloc] init];
    
    [self customTableViewContentOffset];
    
    inventory = [StoreFront shared].inventory;
    [inventory registerObserver:self];
    [inventory loadInventory];
}

// App is backgrounding, so unregister observers in prep for data reload later
- (void)enterBackground {
    
    [activityView stopAnimating];
    
    wasBackgrounded = YES;
    [inventory unregisterObserver:self];
    inventory = nil;
}

// App is returning to foreground, so reregister observers and reload data
- (void)enterForeground {
    
    [activityView startAnimating];
    
    // Things other than a backgrounding can trigger this message, only recover
    // if it is truly from being backgrounded
    if (wasBackgrounded) {
        wasBackgrounded = NO;
        
        // Need to remove all references to old objects
        [filteredProducts removeAllObjects];
        
        inventory = [StoreFront shared].inventory;
        [inventory registerObserver:self];
        [inventory resetReloadCount];
        [inventory loadInventory];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    inventory = [StoreFront shared].inventory;
    if (inventory.status == UAInventoryStatusFailed) {
        // if inventory status is failed, then this block only gets invoked when
        // SF displayed again
        [inventory resetReloadCount];
        [inventory reloadInventory];
    }
    if(![StoreFront shared].isiPad) {
        [self.productTable deselectRowAtIndexPath:[self.productTable indexPathForSelectedRow] animated:YES];
    }
}

- (void)viewDidUnload {
    self.productTable = nil;
    self.filterSegmentedControl = nil;
    self.activityView = nil;
    self.statusLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.searchDisplayController.searchBar setNeedsLayout];
    [self.searchDisplayController.searchResultsTableView reloadData];
    [self.productTable reloadData];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (detailViewController == nil) {
        detailViewController = [[NSClassFromString(productDetailViewClassName) alloc]
                                initWithNibName:productDetailViewNibName
                                bundle:nil];
    }
    
    NSArray *dataSource = [self productsForTableView:tableView];
    detailViewController.product = [dataSource objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ((UAStoreFrontCell *)cell).isOdd = indexPath.row%2;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UAStoreFrontCell *cell = (UAStoreFrontCell *)[tableView dequeueReusableCellWithIdentifier:@"store-front-cell"];
    if (cell == nil) {
        cell = [[[UAStoreFrontCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"store-front-cell"] autorelease];
        [UAViewUtils roundView:cell.iconContainer borderRadius:10 borderWidth:1 color:[UIColor darkGrayColor]];
    }
        
    UAProduct *product = [[self productsForTableView:tableView] objectAtIndex:indexPath.row];
    cell.product = product;
    [self customizeAccessoryViewForCell:cell];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *dataSource = [self productsForTableView:tableView];
    return [dataSource count];
}

#pragma mark -

- (void)customizeAccessoryViewForCell:(UITableViewCell *)cell {
    cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory.png"]] autorelease];
}

- (void)customTableViewContentOffset {
    self.productTable.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.bounds.size.height);
}

// Products list for current UI
- (NSArray *)productsForTableView:(UITableView *)tableView {
    if (self.searchDisplayController.searchResultsTableView == tableView) {
        return filteredProducts;
    } else {
        return self.products;
    }
}

// Products list according to segmented controll selection
- (NSArray *)products {
    return [inventory productsForType:filterSegmentedControl.selectedSegmentIndex];
}

#pragma mark -
#pragma mark KVO UAInventory status observer

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        [self inventoryStatusChanged:inventory];
    }
}

- (void)inventoryStatusChanged:(UAInventory *)inv {
    NSString *statusString = nil;
    ProductType st = inv.status;
    
    if (st == UAInventoryStatusDownloading) {
        [self showLoading];
        statusString = UA_SF_TR(@"UA_Status_Downloading");
        
    } else if(st == UAInventoryStatusApple) {
        [self showLoading];
        statusString = UA_SF_TR(@"UA_Status_Apple");
        
    } else if(st == UAInventoryStatusFailed) {
        [self showLoading];
        statusString = UA_SF_TR(@"UA_Status_Failed");
        
    } else if(st == UAInventoryStatusPurchaseDisabled) {
        [self showLoading];
        statusString = UA_SF_TR(@"UA_Status_Disabled");
        
    } else if(st == UAInventoryStatusLoaded) {
        if ([inv countForType:ProductTypeAll] == 0) {
            statusString = UA_SF_TR(@"UA_No_Content");
            [self showLoading];
        } else {
            [self hideLoading];

            if(self.searchDisplayController.active) {
                [self filterContentForSearchText:self.searchDisplayController.searchBar.text];
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
            
            [self.productTable reloadData];

        }
        
    } else if (st == UAInventoryStatusUpdated) {
        if ([inv countForType:ProductTypeAll] == 0) {
            statusString = UA_SF_TR(@"UA_No_Content");
            [self showLoading];
        } else {
            [self hideLoading];

            if(self.searchDisplayController.active) {
                [self filterContentForSearchText:self.searchDisplayController.searchBar.text];
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
            
            [self.productTable reloadData];
        
            [self refreshUI];
        }
    }
    
    statusLabel.text = statusString;
}


- (void)showLoading {
    loadingView.hidden = NO;
    activityView.hidden = NO;

    productTable.hidden = YES;
    
    if(self.searchDisplayController.active) {
        self.searchDisplayController.searchResultsTableView.hidden = YES;
        toolBar.hidden = YES;
    }
}


- (void)hideLoading {
    loadingView.hidden = YES;
    activityView.hidden = YES;

    productTable.hidden = NO;
    
    if(self.searchDisplayController.active) {
        self.searchDisplayController.searchResultsTableView.hidden = NO;
        toolBar.hidden = NO;
    }
}

#pragma mark -
#pragma mark Search Methods

- (void)filterContentForSearchText:(NSString*)searchText {
    
    NSArray *productsArray = self.products;
    [filteredProducts removeAllObjects];
    int count = [productsArray count];
    for (int i = 0; i < count; i++) {
        UAProduct *product = [productsArray objectAtIndex:i];
        NSRange range = [product.title rangeOfString:searchText
                                             options:(NSCaseInsensitiveSearch
                                                      |NSDiacriticInsensitiveSearch
                                                      |NSWidthInsensitiveSearch)];
        if (range.location != NSNotFound) {
            [filteredProducts addObject:product];
        }
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    tableView.rowHeight = 80;
}

#pragma mark -

- (void)refreshUI {
    
    // update segmented control
    NSUInteger updateCount = [inventory countForType:ProductTypeUpdated];
    NSUInteger installCount = [inventory countForType:ProductTypeInstalled];
    
    NSString *updatesString = UA_SF_TR(@"UA_filter_updates");
    if (updateCount > 0) {
        updatesString = [updatesString stringByAppendingFormat:@"(%d)", updateCount];
    }

    [filterSegmentedControl setTitle:updatesString 
                   forSegmentAtIndex:ProductTypeUpdated];
    [filterSegmentedControl setEnabled:!!updateCount
                     forSegmentAtIndex:ProductTypeUpdated];
    [filterSegmentedControl setEnabled:!!installCount
                     forSegmentAtIndex:ProductTypeInstalled];

    // update 'update all' button
    const int UPDATE_ALL_LOWER_BOUND = 2;
    if (updateCount >= UPDATE_ALL_LOWER_BOUND) {
        NSString *buttonText = UA_SF_TR(@"UA_update_all");
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:buttonText
                                                                                   style:UIBarButtonItemStyleBordered
                                                                                  target:self
                                                                                  action:@selector(updateAll)]
                                                  autorelease];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        
        NSString* buyString = UA_SF_TR(@"UA_Restore");
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:buyString
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(restoreAll)] autorelease];
    }
    
    [self refreshExitButton];
    [self.productTable reloadData];
    [self.searchDisplayController.searchResultsTableView reloadData];

}

- (void)refreshExitButton {
    if ([StoreFront shared].downloadsPreventStoreFrontExit) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        for (UAProduct *product in [inventory productsForType:ProductTypeAll]) {
            if (product.status == UAProductStatusDownloading
                || product.status == UAProductStatusWaiting) {
                self.navigationItem.leftBarButtonItem.enabled = NO;
                break;
            }
        }
    }
}

- (void)disableRestoreButton {
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)enableRestoreButton {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark -
#pragma mark UI Action

- (IBAction)segmentAction:(id)sender {
    [self.productTable reloadData];
}

- (void)done:(id)sender {
    [StoreFront quitStoreFront];
}

- (void)updateAll {
    [[StoreFront shared].inventory updateAll];
}

- (void)restoreAll {
    [self disableRestoreButton];
    [[StoreFront shared].sfObserver restoreAll];
}

@end
