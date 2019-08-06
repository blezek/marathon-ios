//
//  AOMGameController.m
//  AlephOne
//
//  Created by Dustin Wenz on 4/16/19.
//  Copyright © 2019 SDG Productions. All rights reserved.
//

#import "AOMGameController.h"

@implementation AOMGameController

-(id)init {
  self = [super init];
  
  [[UIApplication sharedApplication]setIdleTimerDisabled:YES];
  
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controllerConnected:) name:GCControllerDidConnectNotification object:nil];
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controllerDisconnected:) name:GCControllerDidDisconnectNotification object:nil];

  return self;
}
- (void)controllerConnected:(NSNotification *)notification {
  

  GCController *controller = (GCController *)notification.object;
  
  NSString *status = [NSString stringWithFormat:@"Controller connected\nName: %@\n", controller.vendorName];
  
  self.statusLabel.text = status;
  
  
  self.mainController = controller;
  
  [self handleControllerInput];
}


- (void)controllerDisconnected:(NSNotification *)notification {
  
  
  // a controller was disconnected
  
  GCController *controller = (GCController *)notification.object;
  
  NSString *status = [NSString stringWithFormat:@"Controller disconnected:\n%@", controller.vendorName];
  
  self.statusLabel.text = status;
  
  self.mainController = nil;
}

- (void)handleControllerInput {
  
  // register block for input change detection
  
  GCExtendedGamepad *profile = self.mainController.extendedGamepad;
  
  profile.valueChangedHandler = ^(GCExtendedGamepad *gamepad, GCControllerElement *element)
  
  {
    
    NSString *message = @"";
    
    // left trigger
    
    if (gamepad.leftTrigger == element && gamepad.leftTrigger.isPressed) {
      
      message = @"Left Trigger";
      
    }
    
    // right shoulder button
    
    if (gamepad.rightShoulder == element && gamepad.rightShoulder.isPressed) {
      
      message = @"Right Shoulder Button";
      
    }
    
    // X button
    
    if (gamepad.buttonX == element && gamepad.buttonX.isPressed) {
      
      message = @"X Button";
      
    }
    
    // d-pad
    
    if (gamepad.dpad == element) {
      
      if (gamepad.dpad.up.isPressed) {
        
        message = @"D-Pad Up";
        
      }
      
      if (gamepad.dpad.down.isPressed) {
        
        message = @"D-Pad Down";
        
      }
      
    }
    
    // left stick
    
    if (gamepad.leftThumbstick == element) {
      
      if (gamepad.leftThumbstick.up.isPressed) {
        
        message = [NSString stringWithFormat:@"Left Stick %f", gamepad.leftThumbstick.yAxis.value];
        
      }
      
      if (gamepad.leftThumbstick.down.isPressed) {
        
        message = [NSString stringWithFormat:@"Left Stick %f", gamepad.leftThumbstick.yAxis.value];
        
      }
      
      if (gamepad.leftThumbstick.left.isPressed) {
        
        message = [NSString stringWithFormat:@"Left Stick %f", gamepad.leftThumbstick.xAxis.value];
        
      }
      
      if (gamepad.leftThumbstick.right.isPressed) {
        
        message = [NSString stringWithFormat:@"Left Stick %f", gamepad.leftThumbstick.xAxis.value];
        
      }
      
      [self displayMessage:message];
      
    };
    
  }
@end
