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
#import "PreferencesViewController.h"
#import "PauseViewController.h"
#import "HelpViewController.h"
#import "NewGameViewController.h"
#import "FilmViewController.h"

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
  IBOutlet UIView *preferencesView;
  IBOutlet UIView *pauseView;
  IBOutlet UIView *helpView;
  IBOutlet ButtonView *restartView;
  IBOutlet UIImageView *splashView;
  IBOutlet UIView *filmView;

  IBOutlet UIButton *pause;
  IBOutlet ButtonView *mapView;
  IBOutlet ButtonView *mapView2;
  IBOutlet ButtonView *actionView;
  IBOutlet LookView *lookView;
  IBOutlet MovePadView *moveView;
  IBOutlet ButtonView *leftFireView;
  IBOutlet ButtonView *rightFireView;
  IBOutlet ButtonView *previousWeaponView;
  IBOutlet ButtonView *nextWeaponView;
  IBOutlet ButtonView *inventoryToggleView;
  IBOutlet ButtonView *nextWeaponButton;
  IBOutlet ButtonView *previousWeaponButton;
  IBOutlet UIView *savedGameMessage;

  HUDMode mode;
  
  bool haveNewGamePreferencesBeenSet;
  bool showingHelpBeforeFirstGame;
  bool startingNewGameSoSave;
  bool haveChoosenSaveGame;
  BOOL isPaused;
  SavedGame *currentSavedGame;
  
  CGPoint lastMenuTap;
  
  SDLKey leftFireKey;
  SDLKey rightFireKey;
  
  IBOutlet SaveGameViewController *saveGameViewController;
  IBOutlet ProgressViewController *progressViewController;
  IBOutlet PreferencesViewController *preferencesViewController;
  IBOutlet PauseViewController *pauseViewController;
  IBOutlet HelpViewController *helpViewController;
  IBOutlet NewGameViewController *newGameViewController;
  IBOutlet FilmViewController* filmViewController;
  
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
  bool inMainLoop;
  NSTimer *animationTimer;  
  
  // Ticks for calculating how long the player has been playing
  int ticks;
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
- (void)playerKilled;
- (IBAction)quitPressed;

// Pause actions
- (IBAction) resume:(id)sender;
- (IBAction) gotoMenu:(id)sender;
- (IBAction) gotoPreferences:(id)sender;
- (IBAction) closePreferences:(id)sender;
- (IBAction) help:(id)sender;
- (IBAction) closeHelp:(id)sender;

// Cheats
- (IBAction)shieldCheat:(id)sender;
- (IBAction)invincibilityCheat:(id)sender;
- (IBAction)ammoCheat:(id)sender;
- (IBAction)saveCheat:(id)sender;
- (IBAction)weaponsCheat:(id)sender;

- (IBAction)chooseSaveGame;
- (IBAction)gameChosen:(SavedGame*)game;
- (IBAction)saveGame;
- (IBAction)chooseSaveGameCanceled;

// Films
- (IBAction)chooseFilm;
- (IBAction)filmChosen:(Film*)film;
- (IBAction)chooseFilmCanceled;
- (IBAction)saveFilm;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// Progress stuff
- (void) startProgress:(int)total;
- (void) progressCallback:(int)delta;
- (void) stopProgress;

- (void)bringUpHUD;
- (void)hideHUD;
- (void)teleportOut;
- (void)epilog;
- (void)endReplay;
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
@property (nonatomic, retain) UIView *hud;
@property (nonatomic, retain) UIView *savedGameMessage;
@property (nonatomic, retain) UIView *newGameView;
@property (nonatomic, retain) UIView *loadGameView;
@property (nonatomic, retain) UIView *progressView;
@property (nonatomic, retain) UIView *menuView;
@property (nonatomic, retain) UIView *pauseView;
@property (nonatomic, retain) UIView *helpView;
@property (nonatomic, retain) UIView *filmView;
@property (nonatomic, retain) UIView *preferencesView;
@property (nonatomic, retain) UIImageView *splashView;
@property (nonatomic, retain) ButtonView *restartView;

@property (nonatomic, retain) ButtonView *mapView;
@property (nonatomic, retain) ButtonView *mapView2;
@property (nonatomic, retain) ButtonView *actionView;
@property (nonatomic, retain) LookView *lookView;
@property (nonatomic, retain) MovePadView *moveView;
@property (nonatomic, retain) ButtonView *leftFireView;
@property (nonatomic, retain) ButtonView *rightFireView;
@property (nonatomic, retain) ButtonView *previousWeaponView;
@property (nonatomic, retain) ButtonView *nextWeaponView;
@property (nonatomic, retain) ButtonView *previousWeaponButton;
@property (nonatomic, retain) ButtonView *nextWeaponButton;
@property (nonatomic, retain) ButtonView *inventoryToggleView;
@property (nonatomic, retain) UIButton *pause;

@property (nonatomic, retain) SaveGameViewController *saveGameViewController;
@property (nonatomic, retain) ProgressViewController *progressViewController;
@property (nonatomic, retain) PreferencesViewController *preferencesViewController;
@property (nonatomic, retain) PauseViewController *pauseViewController;
@property (nonatomic, retain) HelpViewController *helpViewController;
@property (nonatomic, retain) FilmViewController *filmViewController;
@property (nonatomic, retain) NewGameViewController *newGameViewController;


@property (nonatomic, retain) UISwipeGestureRecognizer *leftWeaponSwipe;
@property (nonatomic, retain) UISwipeGestureRecognizer *rightWeaponSwipe;
@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;
@property (nonatomic, retain) UIPanGestureRecognizer *moveGesture;
@property (nonatomic, retain) UITapGestureRecognizer *menuTapGesture;
@property (nonatomic, assign) bool haveNewGamePreferencesBeenSet;
@property (nonatomic, retain) SavedGame *currentSavedGame;
@end
