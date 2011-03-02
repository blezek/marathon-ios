//
//  Purchases.h
//  AlephOne
//
//  Created by Daniel Blezek on 2/19/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAirship.h"
#import "UAStoreFrontDelegate.h"
@interface Purchases : NSObject <UAStoreFrontDelegate> {

}

-(NSString*)purchasesDirectory;
-(void)checkPurchases;
-(void)productPurchased:(UAProduct*) product;
-(void)storeFrontDidHide;
-(void)storeFrontWillHide;
-(void)productsDownloadProgress:(float)progress count:(int)count;
-(void)quickCheckPurchases;  

@end
