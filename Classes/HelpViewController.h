//
//  HelpViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 11/19/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlephOneAppDelegate.h"

@interface HelpViewController : UIViewController {
  UIScrollView *scrollView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
- (IBAction) done;
@end
