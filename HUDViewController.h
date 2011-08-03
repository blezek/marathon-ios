//
//  HUDViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 7/19/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "SDL_keyboard.h"

@interface HUDViewController : UIViewController {
  SDLKey primaryFireKey;
  SDLKey secondaryFireKey;
  SDLKey nextWeaponKey;
  SDLKey previousWeaponKey;
  SDLKey inventoryKey;
  SDLKey actionKey;
  SDLKey forwardKey;
  SDLKey backwardKey;
  SDLKey leftKey;
  SDLKey rightKey;
  SDLKey runKey;
  SDLKey mapKey;
}

@property (nonatomic) SDLKey primaryFireKey;
@property (nonatomic) SDLKey secondaryFireKey;

- (IBAction)primaryFireDown:(id)sender;
- (IBAction)primaryFireUp:(id)sender;
- (IBAction)secondaryFireDown:(id)sender;
- (IBAction)secondaryFireUp:(id)sender;
- (IBAction)nextWeaponDown:(id)sender;
- (IBAction)nextWeaponUp:(id)sender;
- (IBAction)previousWeaponDown:(id)sender;
- (IBAction)previousWeaponUp:(id)sender;
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
- (IBAction)stopMoving:(id)sender;

@end
