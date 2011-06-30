//
//  JoyPad.h
//  AlephOne
//
//  Created by Daniel Blezek on 6/28/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JoypadManager.h"
#import "JoypadDevice.h"
#include "SDL_keyboard.h"

@interface JoyPad : NSObject <JoypadManagerDelegate, JoypadDeviceDelegate> {
  JoypadManager *joypadManager;
  NSArray *buttonMap;

  BOOL findingDevice;
  BOOL connectedWithDevice;
  
  SDLKey forwardKey;
  SDLKey backwardKey;
  SDLKey leftKey;
  SDLKey rightKey;
  SDLKey runKey;
  SDLKey primaryFire;
  SDLKey secondaryFire;
  SDLKey mapKey;
  SDLKey actionKey;
  SDLKey nextWeapon;
  SDLKey previousWeapon;

}

@property (nonatomic) BOOL findingDevice;
@property (nonatomic) BOOL connectedWithDevice;

-(id)init;

-(void)startFindingDevices;
-(void)stopFindingDevices;

-(void)setButtonState:(JoyInputIdentifier)button toState:(int)state;
-(void)setButtonsToState:(int)state;


// JoypadManagerDelegate
-(void)joypadManager:(JoypadManager *)manager didFindDevice:(JoypadDevice *)device previouslyConnected:(BOOL)prev;
-(void)joypadManager:(JoypadManager *)manager didLoseDevice:(JoypadDevice *)device;
-(void)joypadManager:(JoypadManager *)manager deviceDidConnect:(JoypadDevice *)device player:(unsigned int)player;
-(void)joypadManager:(JoypadManager *)manager deviceDidDisconnect:(JoypadDevice *)device player:(unsigned int)player;


// JoypadDeviceDelegate
-(void)joypadDevice:(JoypadDevice *)device didAccelerate:(JoypadAcceleration)accel;
-(void)joypadDevice:(JoypadDevice *)device dPad:(JoyInputIdentifier)dpad buttonUp:(JoyDpadButton)dpadButton;
-(void)joypadDevice:(JoypadDevice *)device dPad:(JoyInputIdentifier)dpad buttonDown:(JoyDpadButton)dpadButton;
-(void)joypadDevice:(JoypadDevice *)device buttonUp:(JoyInputIdentifier)button;
-(void)joypadDevice:(JoypadDevice *)device buttonDown:(JoyInputIdentifier)button;
-(void)joypadDevice:(JoypadDevice *)device analogStick:(JoyInputIdentifier)stick didMove:(JoypadStickPosition)newPosition;

@end
