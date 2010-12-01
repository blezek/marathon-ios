    //
//  PauseViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 10/13/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "PauseViewController.h"
#import "AlephOneAppDelegate.h"
#import "Prefs.h"
@implementation PauseViewController

- (IBAction) setup {
  // Hide cheats
  bool cheatsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kCheatsEnabled];
  for ( UIView *view in self.view.subviews ) {
    if ( view.tag == 1  ) {
      view.hidden = !cheatsEnabled;
    }
  }
}

- (IBAction) resume:(id)sender {
  [[AlephOneAppDelegate sharedAppDelegate].game resume:sender];
}
- (IBAction) gotoMenu:(id)sender {
  [[AlephOneAppDelegate sharedAppDelegate].game gotoMenu:sender];
}
- (IBAction) gotoPreferences:(id)sender {
  [[AlephOneAppDelegate sharedAppDelegate].game gotoPreferences:sender];
}

- (IBAction)help:(id)sender {
  [[AlephOneAppDelegate sharedAppDelegate].game help:sender];
}
- (IBAction)shieldCheat:(id)sender {
  [[AlephOneAppDelegate sharedAppDelegate].game shieldCheat:sender];
}
- (IBAction)invincibilityCheat:(id)sender {
  [[AlephOneAppDelegate sharedAppDelegate].game invincibilityCheat:sender];
}
- (IBAction)ammoCheat:(id)sender {
  [[AlephOneAppDelegate sharedAppDelegate].game ammoCheat:sender];
}
- (IBAction)saveCheat:(id)sender {
  [[AlephOneAppDelegate sharedAppDelegate].game saveCheat:sender];
}
- (IBAction)weaponsCheat:(id)sender {
  [[AlephOneAppDelegate sharedAppDelegate].game weaponsCheat:sender];
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
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
