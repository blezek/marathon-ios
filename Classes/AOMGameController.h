//
//  AOMGameController.h
//  AlephOne
//
//  Created by Dustin Wenz on 4/16/19.
//  Copyright © 2019 SDG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameController/GCController.h>

#include "SDL_keyboard.h"

@interface AOMGameController : NSObject {
  SDL_Keycode nextWeapon;
  SDL_Keycode previousWeapon;
  SDL_Keycode runKey;
  SDL_Keycode actionKey;
  SDL_Keycode primaryFire;
  SDL_Keycode secondaryFire;
  SDL_Keycode moveForward;
  SDL_Keycode moveBack;
  SDL_Keycode moveLeft;
  SDL_Keycode moveRight;
  SDL_Keycode mapKey;
  
  float rightXAxis;
  float rightYAxis;
  float leftXAxis;
  float lefttYAxis;
}

@property (nonatomic, retain) GCController *mainController;
@property (nonatomic) SDL_Keycode nextWeapon;
@property (nonatomic) SDL_Keycode previousWeapon;
@property (nonatomic) SDL_Keycode mapKey;
@property (nonatomic) SDL_Keycode runKey;
@property (nonatomic) SDL_Keycode actionKey;
@property (nonatomic) SDL_Keycode primaryFire;
@property (nonatomic) SDL_Keycode secondaryFire;
@property (nonatomic) SDL_Keycode moveForward;
@property (nonatomic) SDL_Keycode moveBack;
@property (nonatomic) SDL_Keycode moveLeft;
@property (nonatomic) SDL_Keycode moveRight;

@property (nonatomic) float rightXAxis;
@property (nonatomic) float rightYAxis;
@property (nonatomic) float leftXAxis;
@property (nonatomic) float lefttYAxis;

- (void)controllerConnected:(NSNotification *)notification;
- (void)controllerDisconnected:(NSNotification *)notification;
- (void)handleControllerState;
- (void)handleControllerInput;

@end

