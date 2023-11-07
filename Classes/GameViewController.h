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
#import "ManagedObjects.h"
#import "ProgressViewController.h"
#import "PreferencesViewController.h"
#import "PauseViewController.h"
#import "PurchaseViewController.h"
#import "HelpViewController.h"
#import "NewGameViewController.h"
#import "FilmViewController.h"

#import "Statistics.h"

#import "HUDViewController.h"
#import "BasicHUDViewController.h"
#import "AOMGameController.h"

//#import "JoypadHUDViewController.h"

typedef enum {
  MenuMode,
  GameMode,
  CutSceneMode,
  AutoMapMode,
  DeadMode,
  SDLMenuMode
} HUDMode;

@interface GameViewController : UIViewController /*<GKLeaderboardViewControllerDelegate,GKAchievementViewControllerDelegate>*/ {
  IBOutlet SDL_uikitopenglview *viewGL;
  IBOutlet UIView *hud;
  IBOutlet UIView *menuView;
  IBOutlet UIView *newGameView;
  IBOutlet UIView *purchaseView;
  IBOutlet UIView *loadGameView;
  IBOutlet UIView *progressView;
  IBOutlet UIView *preferencesView;
  IBOutlet UIView *pauseView;
  IBOutlet UIView *helpView;
  IBOutlet UIView *replacementMenuView;
  IBOutlet UIView *controlsOverviewView;
  IBOutlet ButtonView *restartView;
  IBOutlet UIImageView *splashView;
  IBOutlet UIView *filmView;

  IBOutlet UIView *aboutView;
  
  IBOutlet UIButton *pause;
  IBOutlet UIButton *zoomOutButton;
  IBOutlet UIButton *zoomInButton;
  IBOutlet UIButton *loadFilmButton;
  IBOutlet UIButton *saveFilmButton;
  IBOutlet UIButton *joinNetworkGameButton;
  IBOutlet UIButton *gatherNetworkGameButton;
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
  IBOutlet UIView *logoView;
  IBOutlet UIImageView *reticule;
  IBOutlet UIImageView *bungieAerospaceImageView;
  IBOutlet UIImageView *episodeImageView;
  IBOutlet UIImageView *episodeLoadingImageView;
  IBOutlet UIImageView *waitingImageView;
  
  IBOutlet UIView *mainMenuBackground;
  IBOutlet UIView *mainMenuLogo;
  IBOutlet UIView *mainMenuSubLogo;
  IBOutlet UIView *mainMenuButtons;

  NSMutableArray *reticuleImageNames;
  
  HUDMode mode;
  int currentReticleImage;
	
  bool haveNewGamePreferencesBeenSet;
  bool showingHelpBeforeFirstGame;
  bool showControlsOverview;
  bool haveChoosenSaveGame;
  BOOL isPaused;
  SavedGame *currentSavedGame;
  Statistics *statistics;
  
  UIAlertView *saveFilmCheatWarning;
  UIAlertView *rateGame;
  
  CGPoint lastMenuTap;
  
  GLfloat pauseAlpha;
  
  SDL_Keycode leftFireKey;
  SDL_Keycode rightFireKey;
  
  IBOutlet SaveGameViewController *saveGameViewController;
  IBOutlet ProgressViewController *progressViewController;
  IBOutlet PreferencesViewController *preferencesViewController;
  IBOutlet PauseViewController *pauseViewController;
  IBOutlet HelpViewController *helpViewController;
  IBOutlet NewGameViewController *newGameViewController;
  IBOutlet PurchaseViewController *purchaseViewController;
  IBOutlet FilmViewController* filmViewController;

  HUDViewController *HUDViewController;
  IBOutlet UILabel* A1Version;
  IBOutlet UITextView* aboutText;
  
  UITapGestureRecognizer *menuTapGesture;
  UITapGestureRecognizer *controlsOverviewGesture;
  
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
  
  AOMGameController *gameController;
  
  // Ticks for calculating how long the player has been playing
  int ticks;
}

+(GameViewController*)sharedInstance;
+(GameViewController*)createNewSharedInstance;

- (HUDMode)mode;
- (void)startAnimation;
- (void)stopAnimation;
- (void)runMainLoopOnce:(id)sender;
- (void)setDialogOk;

- (IBAction)pause:(id)from;
- (IBAction)pauseForBackground:(id)from;
- (IBAction)togglePause:(id)from;
- (IBAction)newGame;
- (IBAction)joinNetworkGame;
- (IBAction)joinNetworkGameCommand; //Needed to test delayed menu selection
- (IBAction)displayNetGameStatsCommand;
- (IBAction)gatherNetworkGame;
- (IBAction)gatherNetworkGameCommand;
- (IBAction)switchBackToGameView;
- (IBAction)switchToSDLMenu;
- (IBAction)beginGame;
- (IBAction)beginGameCommand;
- (IBAction)cancelNewGame;
- (void)playerKilled;
- (IBAction)quitPressed;
- (IBAction)networkPressed;
- (IBAction)tipTheDeveloper;

// Replacement menus
- (IBAction)menuShowReplacementMenu;
- (IBAction)menuHideReplacementMenu;
- (IBAction)menuNewGame;
- (IBAction)menuLoadGame;
- (IBAction)menuJoinNetworkGame;
- (IBAction)menuGatherNetworkGame;
- (IBAction)menuPreferences;
- (IBAction)menuStore;
- (IBAction)cancelStore;
- (IBAction)menuAbout;
- (IBAction)cancelAbout;
- (IBAction)finishIntro:(id)sender;
- (IBAction)menuTip;


// Pause actions
- (IBAction) resume:(id)sender;
- (IBAction) startRearranging:(id)sender;
- (IBAction) stopRearranging:(id)sender;
- (IBAction) gotoMenu:(id)sender;
- (IBAction) gotoPreferences:(id)sender;
- (IBAction) closePreferences:(id)sender;
- (IBAction) help:(id)sender;
- (IBAction) closeHelp:(id)sender;
- (GLfloat) getPauseAlpha;

// Joypad
////- (IBAction) cancelJoypad:(id)sender;
////- (IBAction) initiateJoypad:(id)sender;
////- (void)configureHUD:(NSString*)HUDType;

// Reticules
- (void)updateReticule:(int)index;

// Cheats
- (IBAction)shieldCheat:(id)sender;
- (IBAction)invincibilityCheat:(id)sender;
- (IBAction)ammoCheat:(id)sender;
- (IBAction)saveCheat:(id)sender;
- (IBAction)weaponsCheat:(id)sender;

- (IBAction)chooseSaveGame;
- (IBAction)gameChosen:(SavedGame*)game;
- (IBAction)gameChosenCommand:(SavedGame*)game;
- (IBAction)saveGame;
- (IBAction)chooseSaveGameCanceled;

// Films
- (IBAction)chooseFilm;
- (IBAction)filmChosen:(Film*)film;
- (IBAction)chooseFilmCanceled;
- (IBAction)saveFilm;
- (void)saveFilmForReal;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// Progress stuff
- (void) startProgress:(int)total;
- (void) progressCallback:(int)delta;
- (void) stopProgress;

- (void)bringUpControlsOverview;
- (void)bringUpHUD;
- (void)hideHUD;
- (void)teleportOut;
- (void)teleportInLevel;
- (void)epilog;
- (void)endReplay;
- (void)setOpenGLView:(SDL_uikitopenglview*)oglView;
- (void)closeEvent;
- (void)setDisplaylinkPaused:(bool)paused;

// Some actions inventory and map
- (IBAction)changeInventory;
- (IBAction)zoomMapIn;
- (IBAction)zoomMapOut;
- (IBAction)startPrimaryFire;
- (IBAction)stopPrimaryFire;
- (IBAction)startSecondaryFire;
- (IBAction)stopSecondaryFire;


- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer;
- (void)controlsOverviewTap:(UITapGestureRecognizer *)recognizer;

- (CGPoint) transformTouchLocation:(CGPoint)location;

// Achievements
- (void) projectileHit:(short)index withDamage:(int)damage;
- (void) projectileKill:(short)index;
- (int) livingEnemies;
- (int) livingBobs;
- (void) zeroStats;
- (void) gameFinished;
- (void)pickedUp:(short)itemType;

// Menu Sounds
- (void) PlayInterfaceButtonSound;
  
@property (nonatomic, retain) SDL_uikitopenglview *viewGL;
@property (nonatomic, retain) UIView *hud;
@property (nonatomic, retain) UIView *savedGameMessage;
@property (nonatomic, retain) UIView *newGameView;
@property (nonatomic, retain) UIView *purchaseView;
@property (nonatomic, retain) UIView *loadGameView;
@property (nonatomic, retain) UIView *progressView;
@property (nonatomic, retain) UIView *menuView;
@property (nonatomic, retain) UIView *pauseView;
@property (nonatomic, retain) UIView *helpView;
@property (nonatomic, retain) UIView *replacementMenuView;
@property (nonatomic, retain) UIView *controlsOverviewView;

@property (nonatomic, retain) UIView *aboutView;
@property (nonatomic, retain) UILabel* A1Version;
@property (nonatomic, retain) UITextView* aboutText;

@property (nonatomic, retain) UIView *filmView;
@property (nonatomic, retain) UIView *preferencesView;
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
@property (nonatomic, retain) UIButton *zoomInButton;
@property (nonatomic, retain) UIButton *zoomOutButton;
@property (nonatomic, retain) UIButton *saveFilmButton;
@property (nonatomic, retain) UIButton *joinNetworkGameButton;
@property (nonatomic, retain) UIButton *gatherNetworkGameButton;
@property (nonatomic, retain) UIButton *loadFilmButton;

@property (nonatomic, retain) SaveGameViewController *saveGameViewController;
@property (nonatomic, retain) ProgressViewController *progressViewController;
@property (nonatomic, retain) PreferencesViewController *preferencesViewController;
@property (nonatomic, retain) PauseViewController *pauseViewController;
@property (nonatomic, retain) HelpViewController *helpViewController;
@property (nonatomic, retain) FilmViewController *filmViewController;
@property (nonatomic, retain) NewGameViewController *newGameViewController;
@property (nonatomic, retain) PurchaseViewController *purchaseViewController;

@property (nonatomic, retain) HUDViewController *HUDViewController;
@property (nonatomic, retain) HUDViewController *HUDTouchViewController;
////@property (nonatomic, retain) HUDViewController *HUDJoypadViewController;
@property (nonatomic, retain) UIImageView *reticule;
@property (nonatomic, retain) UIImageView *bungieAerospaceImageView;
@property (nonatomic, retain) UIImageView *episodeImageView;
@property (nonatomic, retain) UIImageView *episodeLoadingImageView;
@property (nonatomic, retain) UIImageView *waitingImageView;
@property (nonatomic, retain) UIImageView *splashView;
@property (nonatomic, retain) UIView *logoView;
@property (nonatomic, retain) UIView *mainMenuBackground;
@property (nonatomic, retain) UIView *mainMenuLogo;
@property (nonatomic, retain) UIView *mainMenuSubLogo;
@property (nonatomic, retain) UIView *mainMenuButtons;


@property (nonatomic, retain) UISwipeGestureRecognizer *leftWeaponSwipe;
@property (nonatomic, retain) UISwipeGestureRecognizer *rightWeaponSwipe;
@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;
@property (nonatomic, retain) UIPanGestureRecognizer *moveGesture;
@property (nonatomic, retain) UITapGestureRecognizer *menuTapGesture;
@property (nonatomic, retain) UITapGestureRecognizer *controlsOverviewGesture;
@property (nonatomic, assign) bool haveNewGamePreferencesBeenSet;
@property (nonatomic, retain) SavedGame *currentSavedGame;
@end
