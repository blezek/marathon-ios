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

#import "UAStoreFrontiPadViewController.h"
#import "ASIHTTPRequest.h"
#import "UAProductDetailiPadViewController.h"
#import "UAInventory.h"
#import "UAStoreFrontCell.h"

@implementation UAStoreFrontiPadViewController

- (void)initNibNames {
    productDetailViewNibName = [@"UAProductDetailiPad" retain];
    productDetailViewClassName = [@"UAProductDetailiPadViewController" retain];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tableView:productTable didSelectRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    UAProduct* product = [[self productsForTableView:tableView] objectAtIndex:indexPath.row];
    if (product == selectedProduct) {
        [tableView selectRowAtIndexPath:indexPath
                               animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
        ((UAStoreFrontCell*)cell).activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *dataSource = [self productsForTableView:tableView];
    selectedProduct = [dataSource objectAtIndex:indexPath.row];
    detailViewController.product = selectedProduct;
    
    // Sync selection between two table view
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [productTable reloadData];
    }
    UAStoreFrontCell *cell = (UAStoreFrontCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UAStoreFrontCell *cell = (UAStoreFrontCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
}


- (void)customizeAccessoryViewForCell:(UITableViewCell *)cell {
}

- (void)customTableViewContentOffset {
}

#pragma mark -

- (void)inventoryStatusChanged:(UAInventory *)inv {
    [super inventoryStatusChanged:inv];
    
    if (inv.status == UAInventoryStatusLoaded) {
        if ([inv countForType:ProductTypeAll] > 0 && selectedProduct == nil) {
            selectedProduct = [self.products objectAtIndex:0];
            detailViewController.product = selectedProduct;
        }
    }
}

@end
