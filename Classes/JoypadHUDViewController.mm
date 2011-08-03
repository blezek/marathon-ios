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
  [[GameViewController sharedInstance] pause:self];
  
  // What to do if the user asks for a manual
  void (^completion) ( int button ) = ^(int button) {
    /*
    AlertPrompt* p = [[AlertPrompt alloc] initWithTitle:@"Device address"
                                     cancelButtonTitle:@"Cancel"
                                         okButtonTitle:@"OK"
                                            completion:^(NSString* s) {
     
                                              [self connectByIP:s];
                                            }];
    [p show];
     */
  };
  
  
  alert = [UIAlertView alertViewWithTitle:@"Searching for Joypad"
                                  message:@"Searching for Joypad device"
                        cancelButtonTitle:@"Cancel"
                            otherButtonTitles:[NSArray arrayWithObject:@"Manual"]
                                onDismiss:completion                   
                                 onCancel:^{ }];
  [alert show];
}

- (void)connectByIP:(NSString*)ip {
  NSError *error = NULL;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([^:]+):([0-9]+)"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:&error];
  NSArray *matches = [regex matchesInString:ip
                                    options:0
                                      range:NSMakeRange(0, [ip length])];
  for (NSTextCheckingResult *match in matches) {
    NSRange matchRange = [match range];
    NSRange firstHalfRange = [match rangeAtIndex:1];
    NSRange secondHalfRange = [match rangeAtIndex:2];
  }
}

#pragma mark - Joypad integration
-(void)joypadManager:(JoypadManager *)manager didFindDevice:(JoypadDevice *)device previouslyConnected:(BOOL)prev
{
  NSLog(@"Found a device running Joypad!  Stopping the search and connecting to it.");
  [alert dismissWithClickedButtonIndex:0 animated:NO];
  [manager stopFindingDevices];
  [manager connectToDevice:device asPlayer:1];
}

-(void)joypadManager:(JoypadManager *)manager didLoseDevice:(JoypadDevice *)device
{
  NSLog(@"Lost a device");
  [[GameViewController sharedInstance] pause:self];
  [[[UIAlertView alloc] initWithTitle:@"Lost Joypad connection" 
                             message:[NSString stringWithFormat:@"Lost connection to device %@", [device name]]
                            delegate:nil
                   cancelButtonTitle:@"OK"
                    otherButtonTitles:nil] show];
}

-(void)joypadManager:(JoypadManager *)manager deviceDidConnect:(JoypadDevice *)device player:(unsigned int)player
{
  NSLog(@"Device connected as player: %i!", player);
  [device setDelegate:self];
  [[GameViewController sharedInstance] resume:self];
}

-(void)joypadManager:(JoypadManager *)manager deviceDidDisconnect:(JoypadDevice *)device player:(unsigned int)player
{
  NSLog(@"Player %i disconnected.", player);
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
  // Map "R"
  if ( button == kJoyInputRButton ) {
    [self mapDown:nil];
  }
  // Action "X"
  if ( button == kJoyInputXButton ) {
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
  // Action "X"
  if ( button == kJoyInputXButton ) {
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

-(void)joypadDevice:(JoypadDevice *)device analogStick:(JoyInputIdentifier)stick didMove:(JoypadStickPosition)newPosition
{
  float radius = 55.0;
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
    int dx = 0.1 * newPosition.distance * cos ( newPosition.angle );
    int dy = -0.1 * newPosition.distance * sin ( newPosition.angle );
    SDL_SendMouseMotion ( true, dx, dy );
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
  
  JoypadControllerLayout *customLayout = [config configureLayout:@"DualAnalogSticks"];
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
