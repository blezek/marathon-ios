    //
//  ProgressViewController.mm
//  AlephOne
//
//  Created by Daniel Blezek on 10/12/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "ProgressViewController.h"
#include "AlephOneHelper.h"
#import "Prefs.h"
#include <stdlib.h>


@implementation ProgressViewController
@synthesize progressView, mainView;
@synthesize vmmAd, hdmAd;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
      MLog ( @"Mainview: %@", self.mainView );
      
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
  [self.progressView setTintColor:[UIColor greenColor]];
}

- (void)startProgress:(int)t {
  
  // This is the first progress event
  if ( t == -1 ) {
    self.vmmAd.hidden = YES;
    self.hdmAd.hidden = YES;
        
    // See if we need to show something
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
    NSMutableArray *views = [NSMutableArray arrayWithCapacity:2];
    if ( NO == [defaults boolForKey:kHaveTTEP] ) {
      [views addObject:self.hdmAd];
    }
    if ( NO == [defaults boolForKey:kHaveVidmasterMode] ) {
      [views addObject:self.vmmAd];
    }
    
    if ( views.count > 0 ) {
      // Figure out which one to add
      int index = arc4random() % views.count;
      UIView *v = [views objectAtIndex:index];
      v.hidden = NO;
    }
  }
  
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

- (void)progressFinished {
  self.vmmAd.hidden = YES;
  self.hdmAd.hidden = YES;
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
