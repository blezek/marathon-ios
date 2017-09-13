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
#import "GameViewController.h"

#include "interface.h" //DCW


@implementation PauseViewController
@synthesize statusLabel;

- (IBAction) setup {
  // Hide cheats
  bool cheatsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kHaveVidmasterMode]
                    && [[NSUserDefaults standardUserDefaults] boolForKey:kUseVidmasterMode];
  for ( UIView *view in self.view.subviews ) {
    if ( view.tag == 1  ) {
      view.hidden = [[AlephOneAppDelegate sharedAppDelegate] gameIsNetworked] ? 1 : !cheatsEnabled;
    }
  }
  statusLabel.text = [NSString stringWithFormat:@"Living monsters: %d     Living BoBs: %d", 
                      [[AlephOneAppDelegate sharedAppDelegate].game livingEnemies],
                      [[AlephOneAppDelegate sharedAppDelegate].game livingBobs]];
}

- (IBAction) resume:(id)sender {
  [[AlephOneAppDelegate sharedAppDelegate].game resume:sender];
}

- (IBAction) gotoMenu:(id)sender {
  
    //DCW If we are in a multiplayer game, exit immediately. Otherwise, the postgame report takes over and hoses the UIActionSheet.
#if !defined(DISABLE_NETWORKING)
  short state =get_game_state();
  if ( state == _displaying_network_game_dialogs || get_game_controller() == _network_player )
  {
    [[AlephOneAppDelegate sharedAppDelegate].game gotoMenu:self];
    return;
  }
#endif
    
  UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Return to menu"
                                                  delegate:self 
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:@"Yes"
                                         otherButtonTitles:@"No", nil];
  [as showInView:self.view];
  [as autorelease]; //DCW changed to autorelease
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if ( [actionSheet destructiveButtonIndex] == buttonIndex ) {
    [[AlephOneAppDelegate sharedAppDelegate].game gotoMenu:self];
  }
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
- (IBAction)connectToJoypad:(id)sender {
  [[GameViewController sharedInstance] initiateJoypad:sender];
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
