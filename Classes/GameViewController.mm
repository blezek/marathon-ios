    //
//  GameViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
#import "NewGameViewController.h"
#import "AlephOneShell.h"
#import "AlephOneAppDelegate.h"
#import "GameViewController.h"
#import <QuartzCore/QuartzCore.h>


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
#import "game_wad.h"
#include "overhead_map.h"

@implementation GameViewController
@synthesize view, pause, viewGL, hud, menuView, lookView, moveView, moveGesture, newGameView;
@synthesize rightWeaponSwipe, leftWeaponSwipe, panGesture, menuTapGesture;
@synthesize rightFireView, leftFireView, mapView, actionView;
@synthesize nextWeaponView, previousWeaponView, inventoryToggleView;
@synthesize loadGameView, haveNewGamePreferencesBeenSet;
@synthesize saveGameViewController, currentSavedGame;
@synthesize savedGameMessage;

#pragma mark -
#pragma mark class instance methods


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
      NSLog ( @"inside initWithNib" );
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  self.saveGameViewController = [[SaveGameViewController alloc] initWithNibName:@"SaveGameViewController" bundle:nil];
  self.saveGameViewController.view;
  MLog ( @"Save Game View: %@", self.saveGameViewController.view );
  // Since the SaveGameViewController was initialized from a nib, add it's view to the proper place
  [self.loadGameView addSubview:self.saveGameViewController.uiView];
  
  // Kill a warning
  (void)all_key_definitions;
  mode = MenuMode;
  haveNewGamePreferencesBeenSet = NO;
  startingNewGameSoSave = NO;
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
  [viewList addObject:self.loadGameView];
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
  self.savedGameMessage.hidden = YES;
  isPaused = NO;
  [super viewDidLoad];
}

- (IBAction)newGame {
  // Set the preferences, and kick off a new game if needed
  // Bring up the preferences
  // TODO -- nice animation!
  self.newGameView.hidden = NO;
}

- (IBAction)beginGame {
  haveNewGamePreferencesBeenSet = YES;
  [self cancelNewGame];
  CGPoint location = lastMenuTap;
  SDL_SendMouseMotion(0, location.x, location.y);
  SDL_SendMouseButton(SDL_PRESSED, SDL_BUTTON_LEFT);
  SDL_SendMouseButton(SDL_RELEASED, SDL_BUTTON_LEFT);
  SDL_GetRelativeMouseState(NULL, NULL);
  startingNewGameSoSave = YES;
}

- (IBAction)cancelNewGame {
  // TODO -- nice animation
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
  
  // Should we save a new game in place?
  if ( startingNewGameSoSave ) {
    startingNewGameSoSave = NO;
    self.currentSavedGame = [self.saveGameViewController createNewGameFile];
    [self saveGame];
  }
  
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
#pragma mark Choose saved game methods

extern void force_system_colors(void);
extern bool choose_saved_game_to_load(FileSpecifier& File);
extern bool load_and_start_game(FileSpecifier& File);

- (IBAction)chooseSaveGame {
  self.loadGameView.hidden = NO;
}
  
- (IBAction) gameChosen:(SavedGame*)game {
  self.currentSavedGame = game;
  self.loadGameView.hidden = YES;
  MLog (@"Loading game: %@", game.filename );
  FileSpecifier FileToLoad ( (char*)[game.filename UTF8String] );
  load_and_start_game(FileToLoad);
  MLog ( @"Restored game in position %d, %d", local_player->location.x, local_player->location.y );
}

- (IBAction) chooseSaveGameCanceled {
  self.loadGameView.hidden = YES;
}

extern SDL_Surface *draw_surface;

- (IBAction)saveGame {
  // See if we can generate an overhead view
  struct overhead_map_data overhead_data;
  int MapSize = 196;
  // Create a buffer to render into
  SDL_Surface *s = SDL_CreateRGBSurface(SDL_SWSURFACE, MapSize, MapSize, 8, 0xff, 0xff, 0xff, 0xff);
  SDL_Surface *map = SDL_DisplayFormat(s);
  SDL_FreeSurface(s);
  
  SDL_Surface *old = draw_surface;
  draw_surface = map;
  
  MLog ( @"Saving game in position %d, %d", local_player->location.x, local_player->location.y );
  
  overhead_data.scale= OVERHEAD_MAP_MINIMUM_SCALE; // This is 1, let's go a little larger
  overhead_data.scale= 3;
  overhead_data.origin.x= local_player->location.x;
  overhead_data.origin.y= local_player->location.y;
  overhead_data.half_width= 196/2;
  overhead_data.half_height= 196/2;
  overhead_data.width= 196;
  overhead_data.height= 196;
  overhead_data.mode= _rendering_saved_game_preview;
  
  _render_overhead_map(&overhead_data);
  
  draw_surface = old;
  // See here: http://www.bit-101.com/blog/?p=1861
  SDL_SaveBMP ( map, (char*)[self.currentSavedGame.mapFilename UTF8String] );
  SDL_FreeSurface ( map );
  
  MLog ( @"Saving game to %@", self.currentSavedGame.filename); 
  FileSpecifier file ( (char*)[self.currentSavedGame.filename UTF8String] );
  save_game_file(file);
  
  // Animate the saved game message
  self.savedGameMessage.hidden = YES;
  self.savedGameMessage.alpha = 0.5;
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:1.0];
  self.savedGameMessage.alpha = 0.0;
  [UIView commitAnimations];

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
  
#if TARGET_IPHONE_SIMULATOR
  // If we are in the simulator, save the game
  save_game();
#endif
  
  // Normally would just darken the screen, here we may want to popup a list of things to do.
  if ( isPaused ) {
    resume_game();
  } else {
    pause_game();
  }
  isPaused = !isPaused;
}

- (void)startAnimation {
  // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
  // class is used as fallback when it isn't available.
  NSString *reqSysVer = @"3.1";
  NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
  if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
    displayLinkSupported = TRUE;
  }
  
  NSInteger animationFrameInterval = 2;  
  if (displayLinkSupported) {
    // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
    // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
    // not be called in system versions earlier than 3.1.
    displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(runMainLoopOnce:)];
    [displayLink setFrameInterval:animationFrameInterval];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  } else {
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(runMainLoopOnce:) userInfo:nil repeats:TRUE];
  }
}

- (void)runMainLoopOnce:(id)sender {
  AlephOneMainLoop();
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

+(GameViewController*)createNewSharedInstance {
  return [AlephOneAppDelegate sharedAppDelegate].game;
}

+(GameViewController*)sharedInstance
{
  return [AlephOneAppDelegate sharedAppDelegate].game;
}

- (void)release {
  //do nothing
}

@end
