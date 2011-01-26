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

#import <UIKit/UIKit.h>
#import "UAProductDetailViewController.h"


@class UAInventory;
@interface UAStoreFrontViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate> {
    IBOutlet UITableView *productTable;
    IBOutlet UISegmentedControl *filterSegmentedControl;
    IBOutlet UIActivityIndicatorView *activityView;
    IBOutlet UILabel *statusLabel;
    IBOutlet UIView *loadingView;
    IBOutlet UIToolbar *toolBar;
    UIBarButtonItem *restoreButton;

    BOOL wasBackgrounded;
    
    // modal
    UAInventory *inventory;    // weak reference, not retained
    NSMutableArray *filteredProducts;

    UAProductDetailViewController *detailViewController;    // weak reference, not retained

    NSString *productDetailViewNibName;
    NSString *productDetailViewClassName;
}

@property (nonatomic, retain) UITableView *productTable;
@property (nonatomic, retain) UISegmentedControl *filterSegmentedControl;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UIToolbar *toolBar;

@property (nonatomic, assign) UAProductDetailViewController *detailViewController;
@property (nonatomic, readonly) NSArray *products;

- (IBAction)segmentAction:(id)sender;

//private
- (void)initNibNames;
- (NSArray *)products;
- (NSArray *)productsForTableView:(UITableView *)tableView;
- (void)done:(id)sender;
- (void)updateAll;
- (void)customizeAccessoryViewForCell:(UITableViewCell *)cell;
- (void)customTableViewContentOffset;
- (void)inventoryStatusChanged:(UAInventory *)inv;
- (void)refreshExitButton;
- (void)refreshUI;
- (void)filterContentForSearchText:(NSString*)searchText;
- (void)showLoading;
- (void)hideLoading;
- (void)enableRestoreButton;
- (void)disableRestoreButton;

@end
