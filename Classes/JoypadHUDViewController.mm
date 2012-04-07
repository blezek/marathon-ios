//
//  JoypadHUDViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 7/21/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "JoypadHUDViewController.h"
#import "JoypadSDK.h"
#import "JoypadXIBConfigure.h"
#import "GameViewController.h"
#import "AlertPrompt.h"
#import "UIAlertView+MKBlockAdditions.h"

extern "C" {
  extern  int
  SDL_SendMouseMotion(int relative, int x, int y);
}


static int counter = 0;

@implementation JoypadHUDViewController
@synthesize alert;
-(void)connectToDevice {
  // Start finding devices running Joypad.
  [joypadManager startFindingDevices];
  // Already paused [[GameViewController sharedInstance] pause:self];
  
  // What to do if the user asks for a manual
  // Button 0 is cancel
  void (^completion) ( int button ) = ^(int button) {
    if ( button == 0 ) {
      AlertPrompt* p = [[AlertPrompt alloc] initWithTitle:@"Device address"
                                        cancelButtonTitle:@"Cancel"
                                            okButtonTitle:@"OK"
                                               completion:^(NSString* s) {
                                                 
                                                 [self connectByIP:s];
                                               }];
      [p show];
    } else {
      // Ignore...
    }
  };
  
  
  alert = [UIAlertView alertViewWithTitle:@"Searching for Joypad"
                                  message:@"Searching for Joypad device"
                        cancelButtonTitle:@"Cancel"
                        // otherButtonTitles:[NSArray arrayWithObject:@"Manual"]
                        otherButtonTitles:nil
                                onDismiss:completion                   
                                 onCancel:^{
                                   [[GameViewController sharedInstance] configureHUD:nil];
                                 }];
  [alert show];
}

- (void)connectByIP:(NSString*)ip {
  [joypadManager connectToDeviceAtAddress:ip asPlayer:0];
  [self connectToDevice];
}

#pragma mark - Joypad integration
-(void)joypadManager:(JoypadManager *)manager didFindDevice:(JoypadDevice *)device previouslyConnected:(BOOL)prev
{
  [manager stopFindingDevices];
  [manager connectToDevice:device asPlayer:1];
}

-(void)joypadManager:(JoypadManager *)manager didLoseDevice:(JoypadDevice *)device
{
  if ( [manager.connectedDevices containsObject:device] ) {
    [self joypadManager:manager deviceDidDisconnect:device player:0];
  }
}

-(void)joypadManager:(JoypadManager *)manager deviceDidConnect:(JoypadDevice *)device player:(unsigned int)player
{
  NSLog(@"Device connected as player: %i!", player);
  NSLog(@"Found a device running Joypad!  Stopping the search and connecting to it.");
  [alert dismissWithClickedButtonIndex:5 animated:NO];
  [device setDelegate:self];
  [[GameViewController sharedInstance] resume:self];
}

-(void)joypadManager:(JoypadManager *)manager deviceDidDisconnect:(JoypadDevice *)device player:(unsigned int)player
{
  NSLog(@"Lost a device");
  [[GameViewController sharedInstance] pause:self];
  [[[UIAlertView alloc] initWithTitle:@"Lost Joypad connection" 
                              message:[NSString stringWithFormat:@"Lost connection to device %@", [device name]]
                             delegate:nil
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil] show];
  [[GameViewController sharedInstance] configureHUD:nil];
}

-(void)joypadDevice:(JoypadDevice *)device buttonDown:(JoyInputIdentifier)button
{
  NSLog(@"Button %@ is down", [buttonMap objectAtIndex:button]);
  // Primary fire "A"
  if ( button == kJoyInputAButton ) {
    [self primaryFireDown:nil];
  }
  // Secondary fire "B"
  if ( button == kJoyInputBButton ) {
    [self secondaryFireDown:nil];
  }
  // Map "Y"
  if ( button == kJoyInputYButton ) {
    [self mapDown:nil];
  }
  // Action "C"
  if ( button == kJoyInputCButton ) {
    [self actionDown:nil];
  }
  // Previous Weapon "L"
  if ( button == kJoyInputLButton ) {
    [self previousWeaponDown:nil];
  }
  // Next Weapon "R"
  if ( button == kJoyInputRButton ) {
    [self nextWeaponDown:nil];
  }
  
}

-(void)joypadDevice:(JoypadDevice *)device buttonUp:(JoyInputIdentifier)button
{
  NSLog(@"Button %@ is up", [buttonMap objectAtIndex:button]);
  // Primary fire "A"
  if ( button == kJoyInputAButton ) {
    [self primaryFireUp:nil];
  }
  // Secondary fire "B"
  if ( button == kJoyInputBButton ) {
    [self secondaryFireUp:nil];
  }
  // Map "Y"
  if ( button == kJoyInputYButton ) {
    [self mapUp:nil];
  }
  // Action "C"
  if ( button == kJoyInputCButton ) {
    [self actionUp:nil];
  }
  // Previous Weapon "L"
  if ( button == kJoyInputLButton ) {
    [self previousWeaponUp:nil];
  }
  // Next Weapon "R"
  if ( button == kJoyInputRButton ) {
    [self nextWeaponUp:nil];
  }
  // Pause "Start"
  if ( button == kJoyInputStartButton ) {
    [[GameViewController sharedInstance] pause:self];
  }
}

// Helper for any sort of alternative mouse movement
- (void)mouseDeltaX:(int*)dx deltaY:(int*)dy {
  *dx = deltaX;
  *dy = deltaY;
}

-(void)joypadDevice:(JoypadDevice *)device analogStick:(JoyInputIdentifier)stick didMove:(JoypadStickPosition)newPosition
{
  float radius = 55.0;
  radius = 1.0;
  float runRadius = radius / 2.0;
  
  // This is the movement stick
  if ( stick == kJoyInputAnalogStick1 ) {
    if ( newPosition.distance > runRadius ) {
      [self runDown:self];
    } else {
      [self runUp:self];
    }
    
    // Which direction should we go?
    [self stopMoving:self];
    
    // Do we move?
    if ( newPosition.distance != 0.0 ) {
      if ( newPosition.angle >= ( M_PI / 4.0 ) && newPosition.angle < (M_PI * 3.0 / 4.0 ) ) {
        // Forward?
        [self forwardDown:nil];
      } else if ( newPosition.angle >= (M_PI * 5.0 / 4.0 ) && newPosition.angle < (M_PI * 7.0 / 4.0) ) {
        // Backward
        [self backwardDown:nil];
      } else if ( newPosition.angle >= ( 3.0 / 4.0 * M_PI) && newPosition.angle < ( 5.0 / 4.0 * M_PI) ) {
        // Left
        [self leftDown:nil];
      } else if ( newPosition.angle >= (7.0 / 4.0 * M_PI) || newPosition.angle < ( 1.0 / 4.0 *M_PI) ) {
        // Right
        [self rightDown:nil];
      }
    }
  }
  // Turn
  if ( stick == kJoyInputAnalogStick2 ) {
    deltaX = deltaY = 0;
    if ( newPosition.distance != 0.0 ) {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      float normalized = newPosition.distance / radius;
      float delta = 0.5 * 50.0 * ( 0.1 * normalized + pow(normalized, 2.2));
      
      int dx = delta * cos ( newPosition.angle ) * [defaults floatForKey:kHSensitivity];
      int dy = -delta * sin ( newPosition.angle ) * [defaults floatForKey:kVSensitivity];
      deltaX = dx;
      deltaY = dy;
    }
    
  }
  NSLog(@"Analog stick distance: %f, angle (rad): %f", newPosition.distance, newPosition.angle);
}


-(void)joypadDevice:(JoypadDevice *)device dPad:(JoyInputIdentifier)dpad buttonUp:(JoyDpadButton)dpadButton
{
  NSLog(@"Dpad %@ button %@ is up!", [buttonMap objectAtIndex:dpad], [buttonMap objectAtIndex:dpadButton] );
}

-(void)joypadDevice:(JoypadDevice *)device dPad:(JoyInputIdentifier)dpad buttonDown:(JoyDpadButton)dpadButton
{
  NSLog(@"Dpad %@ button %@ is down!", [buttonMap objectAtIndex:dpad], [buttonMap objectAtIndex:dpadButton] );
}

-(void)joypadDevice:(JoypadDevice *)device didAccelerate:(JoypadAcceleration)accel {
  if ( counter > 500 ) {
    NSLog(@"Accelerometer %f, %f, %f", accel.x, accel.y, accel.z );
    counter = 0;
  }
  counter++;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
  buttonMap = [[NSArray arrayWithObjects:@"kJoyInputDpad1",
                @"kJoyInputDpad2",
                @"kJoyInputAnalogStick1",
                @"kJoyInputAnalogStick2",
                @"kJoyInputAccelerometer",
                @"kJoyInputWheel",
                @"kJoyInputAButton",
                @"kJoyInputBButton",
                @"kJoyInputCButton",
                @"kJoyInputXButton",
                @"kJoyInputYButton",
                @"kJoyInputZButton",
                @"kJoyInputSelectButton",
                @"kJoyInputStartButton",
                @"kJoyInputLButton",
                @"kJoyInputRButton",
                nil] retain];
  joypadManager = [[JoypadManager alloc] init];
  [joypadManager setDelegate:self];
  
  // Create custom layout.
  
  JoypadXIBConfigure* config = [[JoypadXIBConfigure alloc] init];
  
  NSString* name = @"Marathon";
#if SCENARIO==2
  name = @"Durandal";
#endif
  
  JoypadControllerLayout *customLayout = [config configureLayout:@"DualAnalogSticks" name:name];
  [joypadManager useCustomLayout:customLayout];
  [customLayout release];
  [config release];
  
  [super viewDidLoad];

}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  [joypadManager release];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
