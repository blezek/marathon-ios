    //
//  GameViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
#import "NewGameViewController.h"

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
#include "items.h"
#include "interface.h"


@implementation GameViewController
@synthesize view, pause, viewGL, hud, menuView, lookView, moveView, moveGesture, newGameView;
@synthesize rightWeaponSwipe, leftWeaponSwipe, panGesture, menuTapGesture;
@synthesize rightFireView, leftFireView, mapView, actionView;
@synthesize nextWeaponView, previousWeaponView, inventoryToggleView;
@synthesize saveGameView;

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
  haveNewGamePreferencesBeenSet = NO;
  CGAffineTransform transform = self.hud.transform;
  
  // Use the status bar frame to determine the center point of the window's content area.
  CGRect bounds = CGRectMake(0, 0, 1024, 768);
  CGPoint center = CGPointMake(bounds.size.height / 2.0, bounds.size.width / 2.0);
  // Set the center point of the view to the center point of the window's content area.
  // Rotate the view 90 degrees around its new center point.
  transform = CGAffineTransformRotate(transform, (M_PI / 2.0));

  // self.view.transform = transform;
  // self.view.bounds = CGRectMake(0, 0, 1024, 768);
  
  NSMutableSet *viewList = [[[NSMutableSet alloc] init] autorelease];
  [viewList addObject:self.hud];
  [viewList addObject:self.menuView];
  [viewList addObject:self.newGameView];
  [viewList addObject:self.saveGameView];
  for ( UIView *v in viewList ) {
    v.center = center;
    v.transform = transform;
    v.bounds = CGRectMake(0, 0, 1024, 768);
    v.hidden = YES;
  }
  
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
  self.menuTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
  [self.menuView addGestureRecognizer:self.menuTapGesture];
  // Hide initially
  self.menuView.hidden = NO;
  [super viewDidLoad];
}

- (IBAction)newGame {
  // Have we already set the preferences?  If so, then start the game, otw, bring up the preferences
  if ( haveNewGamePreferencesBeenSet ) {
    // Start the game!
    [self cancelNewGame]; // Withdraw the view
    begin_game(_single_player, false);  
    haveNewGamePreferencesBeenSet = NO;
  } else {
    // Bring up the preferences
    // TODO -- nice animation!
    self.newGameView.hidden = NO;
  }
}

- (IBAction)beginGame {
  haveNewGamePreferencesBeenSet = YES;
  [self cancelNewGame];
  CGPoint location = lastMenuTap;
  SDL_SendMouseMotion(0, location.x, location.y);
  SDL_SendMouseButton(SDL_PRESSED, SDL_BUTTON_LEFT);
  SDL_SendMouseButton(SDL_RELEASED, SDL_BUTTON_LEFT);
  SDL_GetRelativeMouseState(NULL, NULL);
}

- (IBAction)cancelNewGame {
  self.newGameView.hidden = YES;
}

- (void)bringUpHUD {
  mode = GameMode;
  
  // Setup other views
  [self.moveView setup];
  
  key_definition *key = current_key_definitions;
  for (unsigned i=0; i<NUMBER_OF_STANDARD_KEY_DEFINITIONS; i++, key++) {
    if ( key->action_flag == _left_trigger_state ){
      [self.leftFireView setup:key->offset];
    } else if ( key->action_flag == _right_trigger_state ){
      [self.rightFireView setup:key->offset];
    } else if ( key->action_flag == _toggle_map ){
      [self.mapView setup:key->offset];
    } else if ( key->action_flag == _action_trigger_state ) {
      [self.actionView setup:key->offset];
    } else if ( key->action_flag == _cycle_weapons_forward ) {
      [self.nextWeaponView setup:key->offset];
    } else if ( key->action_flag == _cycle_weapons_backward ) {
      [self.previousWeaponView setup:key->offset];
    }
    
  }
  
  
  self.hud.alpha = 0.0;
  self.hud.hidden = NO;
  // Animate the HUD coming into view
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:2.0];
  self.hud.alpha = 1.0;
  [UIView commitAnimations];
  [self.hud removeGestureRecognizer:self.menuTapGesture];
  // If we are in the simulator, make us invincible
#if TARGET_IPHONE_SIMULATOR
  process_player_powerup(local_player_index, _i_invincibility_powerup);
#endif
}

- (void)setOpenGLView:(SDL_uikitopenglview*)oglView {
  self.viewGL = oglView;
  self.viewGL.userInteractionEnabled = NO;
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
}

- (void)handleMoveGesture:(UIPanGestureRecognizer *)recognizer {
}


- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
  if ( mode == MenuMode ) {
    if ( recognizer == menuTapGesture ) {
      NSLog ( @"Handling menu tap" );
      CGPoint location = [self transformTouchLocation:[recognizer locationInView:self.menuView]];
      location = [recognizer locationInView:self.menuView];
      lastMenuTap = location;
      SDL_SendMouseMotion(0, location.x, location.y);
      SDL_SendMouseButton(SDL_PRESSED, SDL_BUTTON_LEFT);
      SDL_SendMouseButton(SDL_RELEASED, SDL_BUTTON_LEFT);
      SDL_GetRelativeMouseState(NULL, NULL);
    }
  }
}

- (CGPoint) transformTouchLocation:(CGPoint)location {
  CGPoint newLocation;
  newLocation.x = location.y;
  newLocation.y = self.hud.frame.size.width - location.x;
  return newLocation;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  /*
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
  */
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  NSLog(@"Touches ended");
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  NSLog(@"Touches moved" );
}

#pragma mark -
#pragma mark Game controls

- (IBAction)pause:(id)from {
  // Level name is
  // static_world->level_name
  save_game();
}


#pragma mark -
#pragma mark View Controller Methods

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
