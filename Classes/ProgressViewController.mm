    //
//  ProgressViewController.mm
//  AlephOne
//
//  Created by Daniel Blezek on 10/12/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "ProgressViewController.h"
#include "AlephOneHelper.h"


@implementation ProgressViewController
@synthesize progressView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
  [self.progressView setTintColor:[UIColor greenColor]];
}

- (void)startProgress:(int)t {
  self.progressView.progress = 0;
  total = t;
  currentProgress = 0;
  // Make sure we have a heartbeat
  pumpEvents();
}

- (void)progressCallback:(int)d {
  currentProgress += d;
  self.progressView.progress = currentProgress / (float)total;
  // Make sure we have a heartbeat
  pumpEvents();
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
