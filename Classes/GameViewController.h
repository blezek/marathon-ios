//
//  GameViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaveGameViewController.h"
#import "SDL_uikitopenglview.h"
#include "SDL_keyboard.h"
#import "MovePadView.h"
#import "ButtonView.h"
#import "LookView.h"
#include "FileHandler.h"
#import "ManagedObjects.h"
#import "ProgressViewController.h"

// Useful functions
extern bool save_game(void);
extern "C" void setOpenGLView ( SDL_uikitopenglview* view );

// For cheats
#include "game_window.h"
extern void AddItemsToPlayer(short ItemType, short MaxNumber);
extern void AddOneItemToPlayer(short ItemType, short MaxNumber);



typedef enum {
  MenuMode,
  GameMode,
  AutoMapMode
} HUDMode;

@interface GameViewController : UIViewController {
  IBOutlet SDL_uikitopenglview *viewGL;
  IBOutlet UIView *hud;
  IBOutlet UIView *menuView;
  IBOutlet UIView *newGameView;
  IBOutlet UIView *loadGameView;
  IBOutlet UIView *progressView;
  IBOutlet UIButton *pause;
  IBOutlet ButtonView *mapView;
  IBOutlet ButtonView *actionView;
  IBOutlet LookView *lookView;
  IBOutlet MovePadView *moveView;
  IBOutlet ButtonView *leftFireView;
  IBOutlet ButtonView *rightFireView;
  IBOutlet ButtonView *previousWeaponView;
  IBOutlet ButtonView *nextWeaponView;
  IBOutlet ButtonView *inventoryToggleView;
  IBOutlet UIView *savedGameMessage;

  HUDMode mode;
  
  bool haveNewGamePreferencesBeenSet;
  bool startingNewGameSoSave;
  bool haveChoosenSaveGame;
  BOOL isPaused;
  SavedGame *currentSavedGame;
  
  CGPoint lastMenuTap;
  
  SDLKey leftFireKey;
  SDLKey rightFireKey;
  
  IBOutlet SaveGameViewController *saveGameViewController;
  IBOutlet ProgressViewController *progressViewController;
  
  UISwipeGestureRecognizer *leftWeaponSwipe;
  UISwipeGestureRecognizer *rightWeaponSwipe;
  UIPanGestureRecognizer *panGesture;
  
  UIPanGestureRecognizer *moveGesture;
  UITapGestureRecognizer *menuTapGesture;
  CGPoint lastPanPoint;
  
  // CADisplayLink setup
  BOOL displayLinkSupported;
  // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
  // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
  // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
  // isn't available.
  id displayLink;
  bool animating;
  NSTimer *animationTimer;  
}

+(GameViewController*)sharedInstance;
+(GameViewController*)createNewSharedInstance;

- (void)startAnimation;
- (void)stopAnimation;
- (void)runMainLoopOnce:(id)sender;

- (IBAction)pause:(id)from;
- (IBAction)newGame;
- (IBAction)beginGame;
- (IBAction)cancelNewGame;

- (IBAction)chooseSaveGame;
- (IBAction)gameChosen:(SavedGame*)game;
- (IBAction)saveGame;
- (IBAction)chooseSaveGameCanceled;

// Progress stuff
- (void) startProgress:(int)total;
- (void) progressCallback:(int)delta;
- (void) stopProgress;

- (void)bringUpHUD;
- (void)setOpenGLView:(SDL_uikitopenglview*)oglView;

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;
- (void)handleLookGesture:(UIPanGestureRecognizer *)recognizer;
- (void)handleMoveGesture:(UIPanGestureRecognizer *)recognizer;
- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer;

- (CGPoint) transformTouchLocation:(CGPoint)location;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
  
@property (nonatomic, retain) SDL_uikitopenglview *viewGL;
@property (nonatomic, retain) IBOutlet UIView *hud;
@property (nonatomic, retain) IBOutlet UIView *savedGameMessage;
@property (nonatomic, retain) IBOutlet UIView *newGameView;
@property (nonatomic, retain) IBOutlet UIView *loadGameView;
@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (nonatomic, retain) IBOutlet UIView *menuView;
@property (nonatomic, retain) IBOutlet ButtonView *mapView;
@property (nonatomic, retain) IBOutlet ButtonView *actionView;
@property (nonatomic, retain) IBOutlet LookView *lookView;
@property (nonatomic, retain) IBOutlet MovePadView *moveView;
@property (nonatomic, retain) IBOutlet ButtonView *leftFireView;
@property (nonatomic, retain) IBOutlet ButtonView *rightFireView;
@property (nonatomic, retain) IBOutlet ButtonView *previousWeaponView;
@property (nonatomic, retain) IBOutlet ButtonView *nextWeaponView;
@property (nonatomic, retain) IBOutlet ButtonView *inventoryToggleView;
@property (nonatomic, retain) IBOutlet UIButton *pause;
@property (nonatomic, retain) IBOutlet SaveGameViewController *saveGameViewController;
@property (nonatomic, retain) IBOutlet ProgressViewController *progressViewController;
@property (nonatomic, retain) UISwipeGestureRecognizer *leftWeaponSwipe;
@property (nonatomic, retain) UISwipeGestureRecognizer *rightWeaponSwipe;
@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;
@property (nonatomic, retain) UIPanGestureRecognizer *moveGesture;
@property (nonatomic, retain) UITapGestureRecognizer *menuTapGesture;
@property (nonatomic, assign) bool haveNewGamePreferencesBeenSet;
@property (nonatomic, retain) SavedGame *currentSavedGame;
@end
