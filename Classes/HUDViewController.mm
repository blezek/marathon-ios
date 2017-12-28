//
//  HUDViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 7/19/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "HUDViewController.h"

#import "AlephOneAppDelegate.h"

extern "C" { 
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

#include "AlephOneHelper.h"

@implementation HUDViewController
@synthesize primaryFireKey, secondaryFireKey, lookingAtRefuel, lookPadView, netStats;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      key_definition *key = standard_key_definitions;
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
        } else if ( key->action_flag == _key_activate_console ) {
          consoleKey = key->offset;
        }
      }
    }
    return self;
}

// Noops
- (void)dimActionKey {}
- (void)lightActionKeyWithTarget:(short)target_type objectIndex:(short)object_index {}


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
  setKey(primaryFireKey, 1);
}
- (IBAction)primaryFireUp:(id)sender {
  setKey(primaryFireKey, 0);

}
- (IBAction)secondaryFireDown:(id)sender {
  setKey(secondaryFireKey, 1);
}
- (IBAction)secondaryFireUp:(id)sender {
  setKey(secondaryFireKey, 0);
}
- (IBAction)nextWeaponDown:(id)sender {
  setKey(nextWeaponKey, 1);
}
- (IBAction)nextWeaponUp:(id)sender {
  setKey(nextWeaponKey, 0);
}
- (IBAction)doNextWeapon:(id)sender{
  [self nextWeaponDown:self];
  [self performSelector:@selector(nextWeaponUp:) withObject:self afterDelay:0.10];
}
- (IBAction)previousWeaponDown:(id)sender {
  setKey(previousWeaponKey, 1);
}
- (IBAction)previousWeaponUp:(id)sender {
  setKey(previousWeaponKey, 0);
}
- (IBAction)doPreviousWeapon:(id)sender{
  [self previousWeaponDown:self];
  [self performSelector:@selector(previousWeaponUp:) withObject:self afterDelay:0.10];
}
- (IBAction)inventoryDown:(id)sender {
  setKey(inventoryKey, 1);
}
- (IBAction)inventoryUp:(id)sender {
  setKey(inventoryKey, 0);
}
- (IBAction)actionDown:(id)sender {
  setKey(actionKey, 1);
}
- (IBAction)actionUp:(id)sender {
  setKey(actionKey, 0);
}
- (IBAction)forwardDown:(id)sender {
  setKey(forwardKey, 1);
}
- (IBAction)forwardUp:(id)sender {
  setKey(forwardKey, 0);
}
- (IBAction)backwardDown:(id)sender {
  setKey(backwardKey, 1);
}
- (IBAction)backwardUp:(id)sender {
  setKey(backwardKey, 0);
}
- (IBAction)leftDown:(id)sender {
  setKey(leftKey, 1);
}
- (IBAction)leftUp:(id)sender {
  setKey(leftKey, 0);
}
- (IBAction)rightDown:(id)sender {
  setKey(rightKey, 1);
}
- (IBAction)rightUp:(id)sender {
  setKey(rightKey, 0);
}
- (IBAction)runDown:(id)sender {
  setKey(runKey, 1);
}
- (IBAction)runUp:(id)sender {
  setKey(runKey, 0);
}
- (IBAction)mapDown:(id)sender {
  setKey(mapKey, 1);
}
- (IBAction)mapUp:(id)sender {
  setKey(mapKey, 0);
}

- (IBAction)doMap:(id)sender{
  [self mapDown:self];
  [self performSelector:@selector(mapUp:) withObject:self afterDelay:0.10];
}

- (IBAction)consoleDown:(id)sender {
  //setKey(consoleKey, 1);
}
- (IBAction)consoleUp:(id)sender{
  //setKey(consoleKey, 0);
  
  SDL_Event enter, unenter;
  enter.type = SDL_KEYDOWN;
  SDL_utf8strlcpy(enter.text.text, "\\", SDL_arraysize(enter.text.text));
  enter.key.keysym.sym=SDLK_BACKSLASH;
  SDL_PushEvent(&enter);
  unenter.type = SDL_KEYUP;
  SDL_utf8strlcpy(unenter.text.text, "\\", SDL_arraysize(unenter.text.text));
  unenter.key.keysym.sym=SDLK_BACKSLASH;
  SDL_PushEvent(&unenter);

}

- (IBAction)netStatsDown:(id)sender {
  SDL_Event stats, unstats;
  stats.type = SDL_KEYDOWN;
  SDL_utf8strlcpy(stats.text.text, "1", SDL_arraysize(stats.text.text));
  stats.key.keysym.sym=SDLK_1;
  SDL_PushEvent(&stats);
}
- (IBAction)netStatsUp:(id)sender{
  SDL_Event stats, unstats;
  unstats.type = SDL_KEYUP;
  SDL_utf8strlcpy(unstats.text.text, "1", SDL_arraysize(unstats.text.text));
  unstats.key.keysym.sym=SDLK_1;
  SDL_PushEvent(&unstats);
}

- (IBAction)doConsole:(id)sender{
  [self consoleDown:self];
  [self performSelector:@selector(consoleUp:) withObject:self afterDelay:0.10];
}

- (IBAction)doNetStats:(id)sender{
  [self netStatsDown:self];
  [self performSelector:@selector(netStatsUp:) withObject:self afterDelay:0.10];
}

// Looking
- (IBAction)lookUpDown:(id)sender {
  setKey(lookUpKey, 1);
}
- (IBAction)lookUpUp:(id)sender {
  setKey(lookUpKey, 0);
}
- (IBAction)lookDownDown:(id)sender {
  setKey(lookDownKey, 1);
}
- (IBAction)lookDownUp:(id)sender {
  setKey(lookDownKey, 0);
}
- (IBAction)lookLeftDown:(id)sender {
  setKey(lookLeftKey, 1);
}
- (IBAction)lookLeftUp:(id)sender {
  setKey(lookLeftKey, 0);
}
- (IBAction)lookRightDown:(id)sender {
  setKey(lookRightKey, 1);
}
- (IBAction)lookRightUp:(id)sender {
  setKey(lookRightKey, 0);
}

- (void)dimActionKey:(short)actionType {}
- (void)lightActionKey:(short)actionType {}


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
    [netStats setHidden: ![[AlephOneAppDelegate sharedAppDelegate] gameIsNetworked]];

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
