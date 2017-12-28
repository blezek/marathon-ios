//
//  HUDViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 7/19/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "SDL_keyboard.h"
#import "LookPadView.h" //DCW


@interface HUDViewController : UIViewController {
  SDL_Keycode primaryFireKey;
  SDL_Keycode secondaryFireKey;
  SDL_Keycode nextWeaponKey;
  SDL_Keycode previousWeaponKey;
  SDL_Keycode inventoryKey;
  SDL_Keycode actionKey;
  SDL_Keycode forwardKey;
  SDL_Keycode backwardKey;
  SDL_Keycode leftKey;
  SDL_Keycode rightKey;
  SDL_Keycode runKey;
  SDL_Keycode mapKey;
  SDL_Keycode consoleKey;
  
  SDL_Keycode lookUpKey;
  SDL_Keycode lookDownKey;
  SDL_Keycode lookLeftKey;
  SDL_Keycode lookRightKey;
  
     //DCW
  LookPadView *lookPadView;
  bool lookingAtRefuel;
  UIButton *netStats;
}

@property (nonatomic) SDL_Keycode primaryFireKey;
@property (nonatomic) SDL_Keycode secondaryFireKey;

  //DCW
@property (nonatomic) bool lookingAtRefuel;
@property (nonatomic,retain) IBOutlet LookPadView* lookPadView;
@property (nonatomic,retain) IBOutlet UIButton *netStats;

// Helper for any sort of alternative mouse movement
- (void)mouseDeltaX:(int*)dx deltaY:(int*)dy;

- (IBAction)primaryFireDown:(id)sender;
- (IBAction)primaryFireUp:(id)sender;
- (IBAction)secondaryFireDown:(id)sender;
- (IBAction)secondaryFireUp:(id)sender;
- (IBAction)nextWeaponDown:(id)sender;
- (IBAction)nextWeaponUp:(id)sender;
- (IBAction)doNextWeapon:(id)sender;
- (IBAction)previousWeaponDown:(id)sender;
- (IBAction)previousWeaponUp:(id)sender;
- (IBAction)doPreviousWeapon:(id)sender;
- (IBAction)inventoryDown:(id)sender;
- (IBAction)inventoryUp:(id)sender;
- (IBAction)actionDown:(id)sender;
- (IBAction)actionUp:(id)sender;
- (IBAction)forwardDown:(id)sender;
- (IBAction)forwardUp:(id)sender;
- (IBAction)backwardDown:(id)sender;
- (IBAction)backwardUp:(id)sender;
- (IBAction)leftDown:(id)sender;
- (IBAction)leftUp:(id)sender;
- (IBAction)rightDown:(id)sender;
- (IBAction)rightUp:(id)sender;
- (IBAction)runDown:(id)sender;
- (IBAction)runUp:(id)sender;
- (IBAction)mapDown:(id)sender;
- (IBAction)mapUp:(id)sender;
- (IBAction)doMap:(id)sender;
- (IBAction)consoleDown:(id)sender;
- (IBAction)consoleUp:(id)sender;
- (IBAction)doConsole:(id)sender;
- (IBAction)doNetStats:(id)sender;
- (IBAction)stopMoving:(id)sender;

- (IBAction)lookUpDown:(id)sender;
- (IBAction)lookUpUp:(id)sender;
- (IBAction)lookDownDown:(id)sender;
- (IBAction)lookDownUp:(id)sender;
- (IBAction)lookLeftDown:(id)sender;
- (IBAction)lookLeftUp:(id)sender;
- (IBAction)lookRightDown:(id)sender;
- (IBAction)lookRightUp:(id)sender;

- (void)dimActionKey;
- (void)lightActionKeyWithTarget:(short)target_type objectIndex:(short)object_index;


@end
