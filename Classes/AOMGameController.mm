//
//  AOMGameController.mm
//  AlephOne
//
//  Created by Dustin Wenz on 4/16/19.
//  Copyright © 2019 SDG Productions. All rights reserved.
//

#import "AOMGameController.h"
#import "GameViewController.h"
#import "GameController/GCExtendedGamepad.h"
#import "GameController/GCControllerButtonInput.h"
#import "GameController/GCControllerDirectionPad.h"
#import "GameController/GCControllerAxisInput.h"

extern "C" {
#include "SDL_keyboard_c.h"
#include "SDL_keyboard.h"
#include "SDL_stdinc.h"
#include "SDL_mouse_c.h"
#include "SDL_mouse.h"
#include "SDL_events.h"
}

#include "player.h"
#include "key_definitions.h"
#include "preferences.h"

#include "AlephOneHelper.h"

@implementation AOMGameController

@synthesize mainController;
@synthesize nextWeapon;
@synthesize previousWeapon;
@synthesize mapKey;
@synthesize runKey;
@synthesize actionKey;
@synthesize primaryFire;
@synthesize secondaryFire;
@synthesize moveForward;
@synthesize moveBack;
@synthesize moveLeft;
@synthesize moveRight;

@synthesize rightXAxis;
@synthesize rightYAxis;
@synthesize leftXAxis;
@synthesize lefttYAxis;

-(id)init {
  self = [super init];
  
  key_definition *key = standard_key_definitions;
  for (unsigned i=0; i<NUMBER_OF_STANDARD_KEY_DEFINITIONS; i++, key++) {
    if ( key->action_flag == _moving_forward ) {
      moveForward = key->offset;
    }
    if ( key->action_flag == _moving_backward ) {
      moveBack = key->offset;
    }
    if ( key->action_flag == _sidestepping_left ){
      moveLeft = key->offset;
    }
    if ( key->action_flag == _sidestepping_right ) {
      moveRight = key->offset;
    }
    if ( key->action_flag == _run_dont_walk ) {
      runKey = key->offset;
    }
    if ( key->action_flag == _left_trigger_state ){
      primaryFire = key->offset;
    }
    if ( key->action_flag == _right_trigger_state ){
      secondaryFire = key->offset;
    }
    if ( key->action_flag == _action_trigger_state ){
      actionKey = key->offset;
    }
    if ( key->action_flag == _toggle_map ){
      mapKey = key->offset;
    }
    if ( key->action_flag == _cycle_weapons_forward ) {
      nextWeapon = key->offset;
    }
    if ( key->action_flag == _cycle_weapons_backward ) {
      previousWeapon = key->offset;
    }
    
  }
  
  [[UIApplication sharedApplication]setIdleTimerDisabled:YES];
  
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controllerConnected:) name:GCControllerDidConnectNotification object:nil];
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controllerDisconnected:) name:GCControllerDidDisconnectNotification object:nil];
  
  return self;
}
- (void)controllerConnected:(NSNotification *)notification {

  GCController *newController = (GCController *)notification.object;
  
  NSLog(@"Controller Connected: %@", newController.vendorName);
  
  [self setMainController: newController];

  
  [self.mainController setControllerPausedHandler: ^(GCController *controller) {
    //Note: don't let the AO SDL joystick event handler initialize, otherwise it will override this callback.
    
    if( !getLocalPlayer() ){
      return;
    }
        
    [[GameViewController sharedInstance] togglePause:self];
  } ];
  
  [self handleControllerInput];
}


- (void)controllerDisconnected:(NSNotification *)notification {
  GCController *controller = (GCController *)notification.object;
  
  NSLog(@"Controller Disconnected: %@", controller.vendorName);

  self.mainController = nil;
}
- (void)handleControllerState {
  if (self.mainController == nil) {
    return;
  }
}

- (void)handleControllerInput {
    
  // register block for input change detection
  
  GCExtendedGamepad *profile = self.mainController.extendedGamepad;
	
  profile.valueChangedHandler = ^(GCExtendedGamepad *gamepad, GCControllerElement *element)
  
  {
    
    NSString *message = @"";
    
    GCControllerDirectionPad *lookThumbstick = gamepad.rightThumbstick;
    GCControllerDirectionPad *moveThumbstick = gamepad.leftThumbstick;

    if( shouldswapJoysticks() ){
      lookThumbstick = gamepad.leftThumbstick;
      moveThumbstick = gamepad.rightThumbstick;
    }
    		
    //Triggers. Only activate if this is a current element, so we don't interfere with smart trigger.
    if ( gamepad.rightTrigger == element ) {
      setKey(primaryFire, gamepad.rightTrigger.isPressed);
    }
    if (gamepad.leftTrigger == element) {
      setKey(secondaryFire, gamepad.leftTrigger.isPressed);
    }
    
    if (gamepad.rightShoulder == element) {
      setSmartFirePrimary(gamepad.rightShoulder.isPressed);
    }
    
    // XYAB buttons
    setKey(actionKey, gamepad.buttonA.isPressed);
      //Pause gyro if in refuel.
    if (gamepad.buttonA.isPressed && [[GameViewController sharedInstance].HUDViewController lookingAtRefuel]){
      [[GameViewController sharedInstance].HUDViewController.lookPadView pauseGyro];
    }
    setKey(nextWeapon, gamepad.buttonB.isPressed);
    setKey(previousWeapon, gamepad.buttonY.isPressed);
    setKey(mapKey, gamepad.buttonX.isPressed);
    
    
      //Always run above media. Never check headBelowMedia or set preferences if no game is active, otherwise it will crash!
    setKey(runKey, 1);
    if ([[GameViewController sharedInstance] mode] == GameMode) {
      if(headBelowMedia()){
        SET_FLAG(input_preferences->modifiers,_inputmod_interchange_swim_sink, true);
      } else {
        SET_FLAG(input_preferences->modifiers,_inputmod_interchange_swim_sink, false);
      }
    }

		// d-pad
    float moveStickToDirectionThreshold=0.2;
    if (gamepad.dpad == element || moveThumbstick == element ) {
      setKey(moveLeft,    gamepad.dpad.left.isPressed  || moveThumbstick.xAxis.value < (0-moveStickToDirectionThreshold));
      setKey(moveRight,   gamepad.dpad.right.isPressed || moveThumbstick.xAxis.value > moveStickToDirectionThreshold );
      setKey(moveBack,    gamepad.dpad.down.isPressed  || moveThumbstick.yAxis.value < (0-moveStickToDirectionThreshold) );
      setKey(moveForward, gamepad.dpad.up.isPressed    || moveThumbstick.yAxis.value > moveStickToDirectionThreshold );
    
    }
    
    if ([[GameViewController sharedInstance] mode] == GameMode) {
      //
      if( playerInTerminal() || !getLocalPlayer() ) {
        setKey(SDL_SCANCODE_ESCAPE, gamepad.leftShoulder.isPressed);
      } else {
        setKey(SDL_SCANCODE_ESCAPE, 0); //We don't want to get stuck in escape!
        setKey(runKey, !(gamepad.leftShoulder.isPressed));
      }
    }
    
    
    //Look stick
    float rX = lookThumbstick.xAxis.value;
    float rY = lookThumbstick.yAxis.value;
    float arbitraryConstant=14; 

    rightXAxis = rX * arbitraryConstant;
    rightYAxis = 0.0 - rY * arbitraryConstant * 2.0;
    

    //NSLog(@"Controller thing: %@", message);

   // [[self mainController]  setControllerPausedHandler: ^(GCController *controller) {
   //   NSLog(@"Controller PAUSE!");
   // } ];
    
  };
    
}

@end
