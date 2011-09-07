//
//  HUDViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 7/19/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "HUDViewController.h"

extern "C" {
  extern  int
  SDL_SendMouseMotion(int relative, int x, int y);
  
#include "SDL_keyboard_c.h"
#include "SDL_keyboard.h"
#include "SDL_stdinc.h"
#include "SDL_mouse_c.h"
#include "SDL_mouse.h"
#include "SDL_events.h"
}

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

@implementation HUDViewController
@synthesize primaryFireKey, secondaryFireKey;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {      
      key_definition *key = current_key_definitions;
      for (unsigned i=0; i<NUMBER_OF_STANDARD_KEY_DEFINITIONS; i++, key++) {
        if ( key->action_flag == _left_trigger_state ){
          primaryFireKey = key->offset;
        } else if ( key->action_flag == _right_trigger_state ){
          secondaryFireKey = key->offset;
        } else if ( key->action_flag == _toggle_map ){
          mapKey = key->offset;
        } else if ( key->action_flag == _action_trigger_state ) {
          actionKey = key->offset;
        } else if ( key->action_flag == _cycle_weapons_forward ) {
          nextWeaponKey = key->offset;
        } else if ( key->action_flag == _cycle_weapons_backward ) {
          previousWeaponKey = key->offset;
        } else if ( key->action_flag == _moving_forward ) {
          forwardKey = key->offset;
        } else if ( key->action_flag == _moving_backward ) {
          backwardKey = key->offset;
        } else if ( key->action_flag == _sidestepping_left ){
          leftKey = key->offset;
        } else if ( key->action_flag == _sidestepping_right ) {
          rightKey = key->offset;
        } else if ( key->action_flag == _run_dont_walk ) {
          runKey = key->offset;
        } else if ( key->action_flag == _looking_up ) {
          lookUpKey = key->offset;
        } else if ( key->action_flag == _looking_down ) {
          lookDownKey = key->offset;
        } else if ( key->action_flag == _looking_left ) {
          lookLeftKey = key->offset;
        } else if ( key->action_flag == _looking_right ) {
          lookRightKey = key->offset;
        }
      }
    }
    return self;
}

- (void)mouseDeltaX:(int*)dx deltaY:(int*)dy {
  *dx = 0; *dy = 0;
}

- (IBAction)stopMoving:(id)sender {
  [self forwardUp:nil];
  [self backwardUp:nil];
  [self leftUp:nil];
  [self rightUp:nil];
}
- (IBAction)stopLooking:(id)sender {
  [self lookUpUp:nil];
  [self lookDownUp:nil];
  [self lookLeftUp:nil];
  [self lookRightUp:nil];
}
- (IBAction)primaryFireDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[primaryFireKey] = 1;
}
- (IBAction)primaryFireUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[primaryFireKey] = 0;
}
- (IBAction)secondaryFireDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[secondaryFireKey] = 1;
}
- (IBAction)secondaryFireUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[secondaryFireKey] = 0;
}
- (IBAction)nextWeaponDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[nextWeaponKey] = 1;
}
- (IBAction)nextWeaponUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[nextWeaponKey] = 0;
}
- (IBAction)previousWeaponDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[previousWeaponKey] = 1;
}
- (IBAction)previousWeaponUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[previousWeaponKey] = 0;
}
- (IBAction)inventoryDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[inventoryKey] = 1;
}
- (IBAction)inventoryUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[inventoryKey] = 0;
}
- (IBAction)actionDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[actionKey] = 1;
}
- (IBAction)actionUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[actionKey] = 0;
}
- (IBAction)forwardDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[forwardKey] = 1;
}
- (IBAction)forwardUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[forwardKey] = 0;
}
- (IBAction)backwardDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[backwardKey] = 1;
}
- (IBAction)backwardUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[backwardKey] = 0;
}
- (IBAction)leftDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[leftKey] = 1;
}
- (IBAction)leftUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[leftKey] = 0;
}
- (IBAction)rightDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[rightKey] = 1;
}
- (IBAction)rightUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[rightKey] = 0;
}
- (IBAction)runDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[runKey] = 1;
}
- (IBAction)runUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[runKey] = 0;
}
- (IBAction)mapDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[mapKey] = 1;
}
- (IBAction)mapUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[mapKey] = 0;
}

// Looking
- (IBAction)lookUpDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[lookUpKey] = 1;
}
- (IBAction)lookUpUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[lookUpKey] = 0;
}
- (IBAction)lookDownDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[lookDownKey] = 1;
}
- (IBAction)lookDownUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[lookDownKey] = 0;
}
- (IBAction)lookLeftDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[lookLeftKey] = 1;
}
- (IBAction)lookLeftUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[lookLeftKey] = 0;
}
- (IBAction)lookRightDown:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[lookRightKey] = 1;
}
- (IBAction)lookRightUp:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState(NULL);
  key_map[lookRightKey] = 0;
}


- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
