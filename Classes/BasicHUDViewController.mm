//
//  BasicHUDViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 7/19/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "BasicHUDViewController.h"

#include "cseries.h"
#include "map.h"
#include "screen.h"
#include "interface.h"
#include "shell.h"
#include "preferences.h"
#include "mouse.h"
#include "items.h"
#include "player.h"
#include "platforms.h"

// From devices.cpp
enum // control panel sounds
{
  _activating_sound,
  _deactivating_sound,
  _unusuable_sound,
  
  NUMBER_OF_CONTROL_PANEL_SOUNDS
};
struct control_panel_definition
{
  int16 _class;
  uint16 flags;
  
  int16 collection;
  int16 active_shape, inactive_shape;
  
  int16 sounds[NUMBER_OF_CONTROL_PANEL_SOUNDS];
  _fixed sound_frequency;
  
  int16 item;
};


extern control_panel_definition *get_control_panel_definition(
                                                              const short control_panel_type);
@implementation BasicHUDViewController
@synthesize lookView, movePadView, actionKeyImageView, actionBox;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      // Custom initialization
      lookingAtRefuel=NO;
    }
    return self;
}

- (void)dimActionKey {
  self.actionKeyImageView.alpha = 0.0;
  self.actionKeyImageView.hidden = YES;
  self.actionBox.hidden = YES;
  lookingAtRefuel=NO;
}
- (void)lightActionKeyWithTarget:(short)target_type objectIndex:(short)object_index {
  // From player.h
//  _target_is_platform,
//  _target_is_control_panel,
//  _target_is_unrecognized
    UIImage *image = nil;
    lookingAtRefuel=NO;
    if(object_index != NONE) {
    switch(target_type)
    {
      case _target_is_platform: {
        // Doors
        // Look in platforms.cpp
        // player_touch_platform_state(player_index, object_index);
        image = [UIImage imageNamed:@"OpenDoor"];
        break;
      }
      case _target_is_control_panel: {
        short panel_side_index = object_index;
        // See code in devices.cpp
        // change_panel_state(player_index, object_index);
        struct side_data *side= get_side_data(panel_side_index);
        struct control_panel_definition *cpdefinition= get_control_panel_definition(side->control_panel_type);
        switch (cpdefinition->_class)
        {
          case _panel_is_oxygen_refuel:
          case _panel_is_shield_refuel:
          case _panel_is_double_shield_refuel:
          case _panel_is_triple_shield_refuel:
            lookingAtRefuel=YES;
          case _panel_is_computer_terminal: 
            image = [UIImage imageNamed:@"UseComputer"];
            break;
          case _panel_is_tag_switch:
          case _panel_is_light_switch:
          case _panel_is_platform_switch:  // Switch
            image = [UIImage imageNamed:@"ThrowSwitch"];
            break;
          case _panel_is_pattern_buffer:  // Save
            image = [UIImage imageNamed:@"SaveGame"];
            break;
        }
        break;
      }
    }
  }
  [self.actionKeyImageView setImage:image forState:UIControlStateNormal];
  [self.actionKeyImageView setImage:image forState:UIControlStateHighlighted];
  [self.actionKeyImageView setImage:image forState:UIControlStateSelected];
  self.actionKeyImageView.hidden = NO;
  self.actionKeyImageView.alpha = 1.0;
  self.actionBox.hidden = NO;
  self.actionBox.alpha = .7;
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
  [self.movePadView setup];
	[self.lookPadView setup]; //DCW
  self.lookView.primaryFire = primaryFireKey;
  self.lookView.secondaryFire = secondaryFireKey;
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.lookView = nil;
  self.movePadView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
	return YES;
}

@end
