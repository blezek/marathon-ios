    //
//  GameViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
extern "C" {
extern  int
  SDL_SendMouseMotion(int relative, int x, int y);

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



@implementation GameViewController
@synthesize view, pause, viewGL, hud, lookView, moveView, moveGesture;
@synthesize weaponView, rightWeaponSwipe, leftWeaponSwipe, panGesture, menuTapGesture;
@synthesize rightFireView, leftFireView;
@synthesize rightShootPanGesture;
@synthesize leftShootPanGesture;

#pragma mark -
#pragma mark class instance methods

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
      NSLog ( @"inside initWithNib
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  mode = MenuMode;
  CGAffineTransform transform = self.hud.transform;
  
  // Use the status bar frame to determine the center point of the window's content area.
  CGRect bounds = CGRectMake(0, 0, 1024, 768);
  CGPoint center = CGPointMake(bounds.size.height / 2.0, bounds.size.width / 2.0);
  // Set the center point of the view to the center point of the window's content area.
  self.hud.center = center;
  // Rotate the view 90 degrees around its new center point.
  transform = CGAffineTransformRotate(transform, (M_PI / 2.0));
  self.hud.transform = transform;
  self.hud.bounds = CGRectMake(0, 0, 1024, 768);
/*  
  
  
  CGAffineTransform transform;
  
  // Use the status bar frame to determine the center point of the window's content area.
  CGRect bounds = CGRectMake(0, 0, 1024, 768);
  CGPoint center = CGPointMake(1024 / 2.0, 768 / 2.0);
  
  for ( UIView *subview in self.view.subviews ) {

    // Set the center point of the view to the center point of the window's content area.
    subview.center = center;
  
    // Rotate the view 90 degrees around its new center point.
    transform = CGAffineTransformRotate(transform, (M_PI / 2.0));
    subview.transform = transform;
  }
  // self.view.bounds = CGRectMake(0, 0, 1024, 768);
 */
  
  
  key_definition *key = current_key_definitions;
  for (unsigned i=0; i<NUMBER_OF_STANDARD_KEY_DEFINITIONS; i++, key++) {
    if ( key->action_flag == _left_trigger_state ){
      leftFireKey = key->offset;
    }
    if ( key->action_flag == _right_trigger_state ){
      rightFireKey = key->offset;
    }
    if ( key->action_flag == _moving_forward ) {
      forwardKey = key->offset;
    }
    if ( key->action_flag == _moving_backward ) {
      backwardKey = key->offset;
    }
    if ( key->action_flag == _sidestepping_left ){
      leftKey = key->offset;
    }
    if ( key->action_flag == _sidestepping_right ) {
      rightKey = key->offset;
    }
  }
  NSLog ( @"Found left fire key: %d right fire key %d", leftFireKey, rightFireKey );
  self.rightWeaponSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
  self.rightWeaponSwipe.direction = UISwipeGestureRecognizerDirectionRight;
  [self.weaponView addGestureRecognizer:self.rightWeaponSwipe];

  self.leftWeaponSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
  self.leftWeaponSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
  [self.weaponView addGestureRecognizer:self.leftWeaponSwipe];

  self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLookGesture:)];
  [self.lookView addGestureRecognizer:self.panGesture];
  
  self.leftShootPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLookGesture:)];
  [self.leftFireView addGestureRecognizer:self.leftShootPanGesture];

  self.rightShootPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLookGesture:)];
  [self.rightFireView addGestureRecognizer:self.rightShootPanGesture];
  
  self.moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoveGesture:)];
  [self.moveView addGestureRecognizer:self.moveGesture];
  moveCenterPoint = CGPointMake(self.moveView.bounds.size.width / 2.0, self.moveView.bounds.size.height / 2.0 );
  moveRadius = ( moveCenterPoint.x + moveCenterPoint.y ) / 2.0;
  deadSpaceRadius = moveRadius / 5.0;
  
  self.menuTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
  [self.hud addGestureRecognizer:self.menuTapGesture];
  // Hide initially
  self.hud.hidden = NO;
  self.hud.userInteractionEnabled = YES;
  [super viewDidLoad];
}

- (void)startGame {
  mode = GameMode;
  self.hud.alpha = 0.0;
  self.hud.hidden = NO;
  // Animate the HUD coming into view
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:2.0];
  self.hud.alpha = 1.0;
  [UIView commitAnimations];
  extern bool displaying_fps;
  displaying_fps = true;
}

- (void)setOpenGLView:(SDL_uikitopenglview*)oglView {
  self.viewGL = oglView;
  self.viewGL.userInteractionEnabled = YES;
  // [self.viewGL addGestureRecognizer:self.menuTapGesture];
  [self.view insertSubview:self.viewGL belowSubview:self.hud];
}

#pragma mark -
#pragma mark Gestures
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
  if ( recognizer == self.rightWeaponSwipe ) {
    NSLog ( @"Right weapon swipe" );
  }
  if ( recognizer == self.leftWeaponSwipe ) {
    NSLog ( @"left weapon swipe" );
  }
}

- (void)handleLookGesture:(UIPanGestureRecognizer *)recognizer {
  Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  
  if ( recognizer.state == UIGestureRecognizerStateBegan ) {
    lastPanPoint = [recognizer translationInView:self.hud];
    // Start shooting if needed
    if ( recognizer == self.leftShootPanGesture ) {
      key_map[leftFireKey] = 1;
    }
    if ( recognizer == self.rightShootPanGesture ) {
      key_map[rightFireKey] = 1;
    }
    NSLog ( @"Starting pan: %@", NSStringFromCGPoint(lastPanPoint) );
  } else if ( recognizer.state == UIGestureRecognizerStateChanged ) {
    CGPoint currentPoint = [recognizer translationInView:self.hud];
    int dx, dy;
    dx = currentPoint.x - lastPanPoint.x;
    dy = currentPoint.y - lastPanPoint.y;
    SDL_SendMouseMotion ( true, dx, dy );
    lastPanPoint = currentPoint;
    // NSLog ( @"Moving pan: %@", NSStringFromCGPoint(lastPanPoint) );
    
  } else if ( recognizer.state == UIGestureRecognizerStateEnded ) {
    NSLog ( @"Pan ended" );
    if ( recognizer == self.leftShootPanGesture ) {
      key_map[leftFireKey] = 0;
    }
    if ( recognizer == self.rightShootPanGesture ) {
      key_map[rightFireKey] = 0;
    }
  }
}

- (void)handleMoveGesture:(UIPanGestureRecognizer *)recognizer {
  Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  if ( recognizer.state == UIGestureRecognizerStateEnded ) {
    // lift up on all the keys
    key_map[leftKey] = 0;
    key_map[rightKey] = 0;
    key_map[forwardKey] = 0;
    key_map[backwardKey] = 0;
    // key_map[runKey] = 0;
    return;
  }
  
  // Doesn't matter where we are in this control, just find the position relative to the center
  CGPoint currentPoint = [recognizer locationInView:recognizer.view];
  // NSLog ( @"Starting move: %@", NSStringFromCGPoint(currentPoint) );
  
  float dx, dy;
  dx = currentPoint.x - moveCenterPoint.x;
  dy = currentPoint.y - moveCenterPoint.y;
  NSLog ( @"Move delta: %f, %f", dx, dy );
  // Do we move left or right?
  // Left
  if ( dx < -deadSpaceRadius ) {
    // Just move for now
    NSLog ( @"Move left" );
    key_map[leftKey] = 1;
  } else {
    key_map[leftKey] = 0;
  }
  // Right
  if ( dx > deadSpaceRadius ) {
    NSLog(@"Move right" );
    key_map[rightKey] = 1;
  } else {
    key_map[rightKey] = 0;
  }
  
  // Forward, remember that y is increasing up
  if ( dy < -deadSpaceRadius ) {
    NSLog(@"Move forward");
    key_map[forwardKey] = 1;
  } else {
    key_map[forwardKey] = 0;    
  }
  // Backward
  if ( dy > deadSpaceRadius ) {
    NSLog(@"Move backward");
    key_map[backwardKey] = 1;
  } else {
    key_map[backwardKey] = 0;    
  }
}


- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
  if ( mode == MenuMode ) {
    if ( recognizer == menuTapGesture ) {
      CGPoint location = [self transformTouchLocation:[recognizer locationInView:self.hud]];
      location = [recognizer locationInView:self.hud];
      SDL_SendMouseMotion(0, location.x, location.y);
      SDL_SendMouseButton(SDL_PRESSED, SDL_BUTTON_LEFT);
      SDL_SendMouseButton(SDL_RELEASED, SDL_BUTTON_LEFT);
      SDL_GetRelativeMouseState(NULL, NULL);
    }
  }
}

- (IBAction) leftTrigger:(id)sender {
  NSLog(@"Key %s has been pressed", SDL_GetScancodeName( SDL_GetScancodeFromKey(leftFireKey ) ));
  SDL_SendKeyboardKey ( SDL_PRESSED, SDL_GetScancodeFromKey ( leftFireKey ) );
  Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  key_map[leftFireKey] = !key_map[leftFireKey];
  
}
- (IBAction) rightTrigger:(id)sender {
  Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  key_map[rightFireKey] = !key_map[rightFireKey];
}


- (CGPoint) transformTouchLocation:(CGPoint)location {
  CGPoint newLocation;
  newLocation.x = location.y;
  newLocation.y = self.hud.frame.size.width - location.x;
  return newLocation;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  for ( UITouch *touch in touches ) {
    if ( touch.tapCount == 1 ) {
      // Simulate a mouse event
      CGPoint location = [self transformTouchLocation:[touch locationInView:self.hud]];
      NSLog(@"touchesBegan location: %@", NSStringFromCGPoint(location));
     //  SDL_SendMouseMotion(0, location.x, location.y);
      SDL_SendMouseButton(SDL_PRESSED, SDL_BUTTON_LEFT);
      SDL_GetRelativeMouseState(NULL, NULL);
    }
  }
  
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  NSLog(@"Touches ended");
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  NSLog(@"Touches moved" );
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return ( interfaceOrientation == UIInterfaceOrientationLandscapeRight );
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark Singleton methods
static GameViewController *sharedInstance = nil;

+(GameViewController*)createNewSharedInstance {
  @synchronized(self)
  {
    [sharedInstance release];
    sharedInstance = nil;
    sharedInstance = [[GameViewController alloc] init]; // WithNibName:nil bundle:[NSBundle mainBundle]];
    sharedInstance.view.hidden = NO;
    NSLog ( @"View is %@", sharedInstance.view );
    NSLog ( @"Loaded Hud is %@", sharedInstance.hud );
    [[NSBundle mainBundle] loadNibNamed:@"GameViewController" owner:sharedInstance options:nil];
    NSLog ( @"Loaded Hud is %@", sharedInstance.hud );
    [sharedInstance viewDidLoad];
  }
  return sharedInstance;
}

+(GameViewController*)sharedInstance
{
  @synchronized(self)
  {
    if ( sharedInstance == nil ) {
      [GameViewController createNewSharedInstance];
    }
  }
  return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (sharedInstance == nil) {
      sharedInstance = [super allocWithZone:zone];
      return sharedInstance;  // assignment and return on first allocation
    }
  }
  return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

- (id)retain {
  return self;
}

- (unsigned)retainCount {
  return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
  //do nothing
}

- (id)autorelease {
  return self;
}



@end
