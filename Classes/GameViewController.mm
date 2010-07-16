    //
//  GameViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"

#include "cseries.h"
#include <string.h>
#include <stdlib.h>

#include "map.h"
#include "interface.h"
#include "shell.h"
#include "preferences.h"
#include "mouse.h"
#include "player.h"
#include "key_definitions.h"
#include "tags.h"
extern "C" {
#include "SDL_keyboard_c.h"
#include "SDL_keyboard.h"
}
GameViewController *globalGameView = nil;

@implementation GameViewController
@synthesize view, pause, viewGL, hud;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

  CGAffineTransform transform = self.hud.transform;
  
  // Use the status bar frame to determine the center point of the window's content area.
  CGRect bounds = CGRectMake(0, 0, 1024, 768);
  CGPoint center = CGPointMake(bounds.size.height / 2.0, bounds.size.width / 2.0);
  // Set the center point of the view to the center point of the window's content area.
  self.hud.center = center;
  // Rotate the view 90 degrees around its new center point.
  transform = CGAffineTransformRotate(transform, (M_PI / 2.0));
  self.hud.transform = transform;
  self.hud.bounds = CGRectMake(0, 0, 1024, 768);
/*  
  
  
  CGAffineTransform transform;
  
  // Use the status bar frame to determine the center point of the window's content area.
  CGRect bounds = CGRectMake(0, 0, 1024, 768);
  CGPoint center = CGPointMake(1024 / 2.0, 768 / 2.0);
  
  for ( UIView *subview in self.view.subviews ) {

    // Set the center point of the view to the center point of the window's content area.
    subview.center = center;
  
    // Rotate the view 90 degrees around its new center point.
    transform = CGAffineTransformRotate(transform, (M_PI / 2.0));
    subview.transform = transform;
  }
  // self.view.bounds = CGRectMake(0, 0, 1024, 768);
 */
  
  
  key_definition *key = current_key_definitions;
  for (unsigned i=0; i<NUMBER_OF_STANDARD_KEY_DEFINITIONS; i++, key++) {
    if ( key->action_flag == _left_trigger_state ){
      leftFireKey = key->offset;
    }
    if ( key->action_flag == _right_trigger_state ){
      rightFireKey = key->offset;
    }
  }
  NSLog ( @"Found left fire key: %d right fire key %d", leftFireKey, rightFireKey );
  
  [super viewDidLoad];
}

- (void)startGame {
  self.hud.alpha = 0.0;
  self.hud.hidden = NO;
  // Animate the HUD coming into view
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:2.0];
  self.hud.alpha = 1.0;
  [UIView commitAnimations];
}

- (IBAction) leftTrigger:(id)sender {
  NSLog(@"Key %s has been pressed", SDL_GetScancodeName( SDL_GetScancodeFromKey(leftFireKey ) ));
  // SDL_SendKeyboardKey ( SDL_PRESSED, SDL_GetScancodeFromKey ( leftFireKey ) );
  Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  key_map[leftFireKey] = !key_map[leftFireKey];
  
}
- (IBAction) rightTrigger:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  key_map[rightFireKey] = !key_map[rightFireKey];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return ( interfaceOrientation == UIInterfaceOrientationLandscapeRight );
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
