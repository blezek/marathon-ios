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
#import "Effects.h"
#import "AlertPrompt.h"
#import "Appirater.h"
#include "FileHandler.h"
#import "Tracking.h"

//#import "FloatingTriggerHUDViewController.h"
#import "AlephOneHelper.h"
#import "alephversion.h"

#include "network.h"
#include "player.h"

#include "QuickSave.h" //DCW Used for metadata generation
#include <fstream>
#include <sstream>

extern float DifficultyMultiplier[];

// Useful functions
extern bool save_game(void);
extern "C" void setOpenGLView ( SDL_uikitopenglview* view );

// For cheats
#include "game_window.h"
extern void AddItemsToPlayer(short ItemType, short MaxNumber);
extern void AddOneItemToPlayer(short ItemType, short MaxNumber);


extern "C" {

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
#include "screen.h"
#include "interface.h"
#include "shell.h"
#include "preferences.h"
#include "mouse.h"
#include "items.h"
#include "platforms.h"
#include "monsters.h"
// Uggg... see monster_definitions.h for details
#define DONT_REPEAT_DEFINITIONS
#include "monster_definitions.h"
#include "player.h"
#include "key_definitions.h"
#include "tags.h"
#include "interface.h"
#import "game_wad.h"
#include "overhead_map.h"
#include "weapons.h"
#include "vbl.h"
#include "render.h"
#include "interface_menus.h"

static int livingBobs;
static int livingEnemies;

int DamageRecord[MAXIMUM_NUMBER_OF_WEAPONS];
int KillRecord[MAXIMUM_NUMBER_OF_WEAPONS];

extern void PlayInterfaceButtonSound(short SoundID);
extern struct view_data *world_view; /* should be static */
BOOL StatsDownloaded = NO;
extern  bool switch_can_be_toggled(short line_index, bool player_hit);
extern bool line_is_within_range(
                                 short monster_index,
                                 short line_index,
                                 world_distance range);

enum // control panel sounds
{
    _activating_sound,
    _deactivating_sound,
    _unusuable_sound,
    
    NUMBER_OF_CONTROL_PANEL_SOUNDS
};
struct control_panel_definition
{
    int16 _class;
    uint16 flags;
    
    int16 collection;
    int16 active_shape, inactive_shape;
    
    int16 sounds[NUMBER_OF_CONTROL_PANEL_SOUNDS];
    _fixed sound_frequency;
    
    int16 item;
};
#include "lightsource.h"
bool local_switch_can_be_toggled(
                           short side_index,
                           bool player_hit)
{
  
  // bool temp = switch_can_be_toggled(side_index, player_hit );
  
  
    bool valid_toggle= true;
    struct side_data *side= get_side_data(side_index);
    
    
    extern control_panel_definition *get_control_panel_definition(
                                                                  const short control_panel_type);
    struct control_panel_definition *definition= get_control_panel_definition(
                                                                              side->control_panel_type);
    // LP change: idiot-proofing
    if (!definition) {
        return false;
    }
    
    if (side->flags&_side_is_lighted_switch) {
        valid_toggle= get_light_intensity(side->primary_lightsource_index)>
        (3*FIXED_ONE/4) ? true : false;        
    }
    
    if ( ( definition->item!=NONE ) && !player_hit) {
        valid_toggle= false;
    }
    if (player_hit &&
        (side->flags&_side_switch_can_only_be_hit_by_projectiles)) {
        valid_toggle= false;
    }
    /*
    if (valid_toggle && (side->flags&_side_switch_can_be_destroyed)) {
        // destroy switch
        SET_SIDE_CONTROL_PANEL(side, false);
        if ( SideList[732].flags != 34 ) {
            printf ( "Suddenly switched in %s %s:%d\n", __FUNCTION__, __FILE__, __LINE__ );        
        }
        
    }
    
    if (!valid_toggle && player_hit) {
        play_control_panel_sound(side_index, _unusuable_sound);
    }
     */
    
    return valid_toggle;
}

extern short find_action_key_target(
                                    short player_index,
                                    world_distance range,
                                    short *target_type);
short localFindActionTarget(
                             short player_index,
                             world_distance range,
                             short *target_type)
{
  // short temp = find_action_key_target( player_index, range, target_type );
  
    //DCW
		if (!dynamic_world->player_count) {
      NSLog(@"Oh no! player_count is zero for some reason! I'm outta here.. Hopfully this doesn't break stuff.");
      return NONE;
    }
  
    struct player_data *player= get_player_data(player_index);
	
		//DCW
		if (!player) {
			NSLog(@"Oh no! player data is null for some reason! I'm outta here.. Hopfully this doesn't break stuff.");
			return NONE;
		}
  
  
    short current_polygon= player->camera_polygon_index;
    world_point2d destination;
    bool done= false;
    short itemhit, line_index;
    struct polygon_data *polygon;
    
    // In case we don't hit anything
    *target_type = _target_is_unrecognized;
    
    /* Should we use this one, the physics one, or the object one? */
    ray_to_line_segment((world_point2d *) &player->location, &destination,
                        player->facing,
                        range);
    
    //	dprintf("#%d(#%d,#%d) --> (#%d,#%d) (#%d along #%d)", current_polygon, player->location.x, player->location.y, destination.x, destination.y, range, player->facing);
    
    itemhit= NONE;
    while (!done)
    {
        line_index=
        find_line_crossed_leaving_polygon(current_polygon,
                                          (world_point2d *) &player->location,
                                          &destination);
        
        if (line_index==NONE) {
            done= true;
        }
        else
        {
            struct line_data *line;
            short original_polygon;
            
            line= get_line_data(line_index);
            
            original_polygon= current_polygon;
            current_polygon= find_adjacent_polygon(current_polygon, line_index);
            
            
            //			dprintf("leaving polygon #%d through line #%d to polygon #%d", original_polygon, line_index, current_polygon);
            
            if (current_polygon!=NONE) {
                polygon= get_polygon_data(current_polygon);
#define MAXIMUM_PLATFORM_ACTIVATION_RANGE (3*WORLD_ONE)

                /* We hit a platform */
                if (polygon->type==_polygon_is_platform &&
                    line_is_within_range(player->monster_index, line_index,
                                         MAXIMUM_PLATFORM_ACTIVATION_RANGE) &&
                    platform_is_legal_player_target(polygon->permutation)) {
                    
                    //					dprintf("found platform #%d in %p", polygon->permutation, polygon);
                    itemhit= polygon->permutation;
                    *target_type= _target_is_platform;
                    done= true;
                }
            }
            else
            {
                done= true;
            }
#define MAXIMUM_CONTROL_ACTIVATION_RANGE (WORLD_ONE+WORLD_ONE_HALF)
           
            /* Slammed a wall */
            if (line_is_within_range(player->monster_index, line_index,
                                     MAXIMUM_CONTROL_ACTIVATION_RANGE)) {
                
                if (line_side_has_control_panel(line_index, original_polygon,
                                                &itemhit)) {
                    
                    if (local_switch_can_be_toggled(itemhit, true)) {
                        
                        *target_type= _target_is_control_panel;
                        done= true;
                    }
                    else
                    {
                        itemhit= NONE;
                    }
                }
            }
        }
    }
    
    return itemhit;
}





#define kPauseAlphaDefault 0.5;

@implementation GameViewController
@synthesize pause, viewGL, hud, menuView, lookView, moveView, moveGesture, newGameView, preferencesView, pauseView;
@synthesize rightWeaponSwipe, leftWeaponSwipe, panGesture, menuTapGesture;
@synthesize rightFireView, leftFireView, mapView, mapView2, actionView;
@synthesize nextWeaponView, previousWeaponView, inventoryToggleView;
@synthesize loadGameView, haveNewGamePreferencesBeenSet;
@synthesize saveGameViewController, currentSavedGame;
@synthesize savedGameMessage, restartView;
@synthesize progressView, progressViewController, preferencesViewController, pauseViewController, splashView;
@synthesize helpViewController, helpView;
@synthesize newGameViewController;
@synthesize purchaseViewController;
@synthesize A1Version, aboutText;
@synthesize previousWeaponButton, nextWeaponButton;
@synthesize filmView, filmViewController;
@synthesize controlsOverviewView, controlsOverviewGesture;
@synthesize zoomInButton, zoomOutButton;
@synthesize replacementMenuView;
@synthesize saveFilmButton, loadFilmButton;
@synthesize joinNetworkGameButton, gatherNetworkGameButton;
@synthesize HUDViewController;
@synthesize reticule, bungieAerospaceImageView, episodeImageView, logoView, waitingImageView, episodeLoadingImageView;
@synthesize mainMenuBackground, mainMenuLogo, mainMenuSubLogo, mainMenuButtons;

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
  [super viewDidLoad];
  
  gameController = [[AOMGameController alloc] init];
  
  // Bogus reticule
  currentReticleImage = -1000;
  
  self.saveGameViewController = [[SaveGameViewController alloc] initWithNibName:@"SaveGameViewController" bundle:nil];
 // self.saveGameViewController.view;
  //[self.saveGameViewController.view setFrame:self.hud.bounds];//DCW: this subview needs to be the same size the hud view.
  //[self.saveGameViewController.uiView setFrame:self.hud.bounds];//DCW: this subview needs to be the same size the hud view.

  MLog ( @"Save Game View: %@", self.saveGameViewController.view );
  // Since the SaveGameViewController was initialized from a nib, add it's view to the proper place
  //[self.loadGameView setFrame:[UIScreen mainScreen].bounds];//DCW: this subview needs to be the same size as the screen.
  //[self.saveGameViewController.view setFrame:[UIScreen mainScreen].bounds];//DCW: this subview needs to be the same size as the screen.
  [self.saveGameViewController.uiView setFrame:self.loadGameView.frame];//DCW: this subview needs to be the same size as the superview.
  [self.loadGameView addSubview:self.saveGameViewController.uiView];
  MLog ( @"self.loadGameView = %@", self.loadGameView);
  MLog ( @"self.saveGameViewController.uiView = %@", self.saveGameViewController.uiView);

  [A1Version setText: [NSString stringWithFormat:@"Engine Version: %@", @A1_DISPLAY_VERSION]];
  
  self.progressViewController = [[ProgressViewController alloc] initWithNibName:@"ProgressViewController" bundle:[NSBundle mainBundle]];
  [self.progressViewController view];
  [self.progressViewController mainView];
  [self.progressViewController.mainView setFrame:[UIScreen mainScreen].bounds];//DCW: this subview needs to be the same size as the screen.
  [self.progressView addSubview:self.progressViewController.mainView];
  
  self.preferencesViewController = [[PreferencesViewController alloc] initWithNibName:@"PreferencesViewController" bundle:[NSBundle mainBundle]];
  [self.preferencesViewController view];
  [self.preferencesViewController.view setFrame:self.hud.bounds];//DCW: this subview needs to be the same size the hud view.
  //MLog ( @"self.preferencesViewController.view = %@", self.preferencesViewController.view);
  [self.preferencesView addSubview:self.preferencesViewController.view];
  
  self.helpViewController = [[HelpViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
  [self.helpViewController view];
  [self.helpViewController.view setFrame:self.hud.bounds];
  //[self.helpView setFrame:self.hud.bounds];
	[self.helpView addSubview:self.helpViewController.view];

  self.pauseViewController = [[PauseViewController alloc] initWithNibName:@"PauseViewController" bundle:[NSBundle mainBundle]];
  [self.pauseViewController view];
  [self.pauseViewController.view setFrame:self.hud.bounds];//DCW: this subview needs to be the same size the hud view.
  [self.pauseView addSubview:self.pauseViewController.view];
  
  self.newGameViewController = [[NewGameViewController alloc] initWithNibName:@"NewGameViewController" bundle:[NSBundle mainBundle]];
  [self.newGameViewController view];
  [self.newGameViewController.view setFrame:self.hud.bounds];//DCW: this subview needs to be the same size the hud view.
  [self.newGameView addSubview:self.newGameViewController.view];
  
  self.purchaseViewController = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:[NSBundle mainBundle]];
  [self.purchaseViewController view];
  [self.purchaseViewController.view setFrame:self.hud.bounds];//DCW: this subview needs to be the same size the hud view.
  [self.purchaseView addSubview:self.purchaseViewController.view];
  
  self.filmViewController = [[FilmViewController alloc] initWithNibName:@"FilmViewController" bundle:[NSBundle mainBundle]];
  [self.filmViewController view];
  [self.filmViewController enclosingView];
  [self.filmView addSubview:self.filmViewController.enclosingView];
  
  // Kill a warning
  (void)all_key_definitions;
  mode = MenuMode;
  haveNewGamePreferencesBeenSet = NO;
  showControlsOverview = NO;
  showingHelpBeforeFirstGame = NO;
  pauseAlpha = kPauseAlphaDefault;
    
  NSMutableSet *viewList = [[[NSMutableSet alloc] initWithObjects:
                             self.hud,
                             self.menuView,
                             self.newGameView,
                             self.loadGameView,
                             self.progressView,
                             self.pauseView,
                             self.helpView,
                             self.preferencesView,
                             splashView,
                             restartView,
                             self.filmView,
                             self.controlsOverviewView,
                             self.replacementMenuView,
                             self.aboutView,
                             self.purchaseView,
                             nil] autorelease];
  for ( UIView *v in viewList ) {
    v.hidden = YES;
  }
  
#if defined(A1DEBUG)
  //self.saveFilmButton.hidden = NO;
  //self.loadFilmButton.hidden = NO;
  
  // joyPad = [[JoyPad alloc] init];

#endif
  self.joinNetworkGameButton.hidden = NO;
  self.gatherNetworkGameButton.hidden = NO;
  
  self.splashView.hidden = NO;
  self.restartView.hidden = YES;
  
  self.menuTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
  [self.restartView addGestureRecognizer:self.menuTapGesture];

  self.controlsOverviewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controlsOverviewTap:)];
  [self.controlsOverviewView addGestureRecognizer:self.controlsOverviewGesture];

  // Hide initially
  self.menuView.hidden = NO;
  self.savedGameMessage.hidden = YES;
  isPaused = NO;
  animating = NO;
  [super viewDidLoad];
  statistics = [[Statistics alloc] init];
  [statistics retain];
  reticuleImageNames = [NSMutableArray arrayWithCapacity:MAXIMUM_NUMBER_OF_WEAPONS];
  [reticuleImageNames insertObject:@"" atIndex:_weapon_fist];
  [reticuleImageNames insertObject:@"ret_pistol" atIndex:_weapon_pistol];
  [reticuleImageNames insertObject:@"ret_plasma" atIndex:_weapon_plasma_pistol];
  [reticuleImageNames insertObject:@"ret_machinegun" atIndex:_weapon_assault_rifle];
  [reticuleImageNames insertObject:@"ret_rocket" atIndex:_weapon_missile_launcher];
  [reticuleImageNames insertObject:@"ret_flame" atIndex:_weapon_flamethrower];
  [reticuleImageNames insertObject:@"ret_alien" atIndex:_weapon_alien_shotgun];
  [reticuleImageNames insertObject:@"ret_shotgun" atIndex:_weapon_shotgun];
  [reticuleImageNames insertObject:@"ret_shotgun" atIndex:_weapon_ball];
  [reticuleImageNames insertObject:@"ret_machinegun" atIndex:_weapon_smg];
  [reticuleImageNames retain];
 
}

#pragma mark -
#pragma mark Game control


- (HUDMode)mode {
  return mode;
}

- (void)closeEvent {
  switch ( mode ) {
    case MenuMode:
      ////[Tracking trackPageview:@"/menu"];
      ////[Tracking tagEvent:@"menu"];
      break;
    case SDLMenuMode:
      ////[Tracking trackPageview:@"/menu"];
      ////[Tracking tagEvent:@"menu"];
      break;
    case CutSceneMode:
      ////[Tracking trackPageview:@"/cutscene"];
      ////[Tracking tagEvent:@"cutsecene"];
      break;
    case AutoMapMode:
      ////[Tracking trackPageview:@"/automap"];
      ////[Tracking tagEvent:@"automap"];
      break;
    case DeadMode:
      ////[Tracking trackPageview:@"/dead"];
      ////[Tracking tagEvent:@"dead"];
     break;
    case GameMode:
    default:
      ////[Tracking trackPageview:@"/game"];
      ////[Tracking tagEvent:@"game"];
      break;
  }
}

- (void)setDisplaylinkPaused:(bool)paused {
  
  if(displayLink) {
    ((CADisplayLink*)displayLink).paused = paused; //dcw shit test
  }
}

- (IBAction)quitPressed {
  rateGame = [[UIAlertView alloc] initWithTitle:@"Rate the app?"
                                               message:@"Quit? Like you have something better to do!  Why not rate the app instead?"
                                              delegate:self
                                     cancelButtonTitle:@"No, thanks"
                                     otherButtonTitles:@"Rate it!", nil];
  [rateGame show];
  [rateGame release];
}

- (IBAction)networkPressed {
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Networking not available"
                                               message:@"Network play is not available, but the button can not be removed due to license resctictions, sorry..."
                                              delegate:nil
                                     cancelButtonTitle:@"Bummer"
                                     otherButtonTitles:nil];
  [av show];
  [av release];
}

- (IBAction)newGame {
  // Set the preferences, and kick off a new game if needed
  // Bring up the preferences
  // TODO -- nice animation!
  ////[Tracking trackPageview:@"/new"];
  [self.newGameViewController appear];
	//self.newGameView.hidden = NO; //DCW: commenting out; appear function does this itself
	[Effects appearRevealingView:self.newGameView]; //DCW
  self.currentSavedGame = nil;
  [self zeroStats];
}

- (IBAction)tipTheDeveloper {
  [self.purchaseViewController openDoors];
  [self.purchaseViewController appear];
  [Effects appearRevealingView:self.purchaseView];
}

- (IBAction)joinNetworkGame {
  [self switchToSDLMenu];
  //[self performSelector:@selector(switchToSDLMenu) withObject:nil afterDelay:.1];
  //[self performSelector:@selector(joinNetworkGameCommand) withObject:nil afterDelay:0];
  [self performSelectorOnMainThread:@selector(joinNetworkGameCommand) withObject:nil waitUntilDone:NO];
  //do_menu_item_command(mInterface, iJoinGame, false);
}
- (IBAction)joinNetworkGameCommand {
  do_menu_item_command(mInterface, iJoinGame, false);
  [self setDisplaylinkPaused: NO]; //Unpause CADL ater joining finished.
}

- (IBAction)displayNetGameStatsCommand {
  display_net_game_stats();
  [self setDisplaylinkPaused: NO]; //Unpause CADL ater joining finished.
}

- (IBAction)gatherNetworkGame {
  if( mode!=SDLMenuMode ){
    [self switchToSDLMenu];
    [self performSelector:@selector(gatherNetworkGameCommand) withObject:nil afterDelay:0];
  }
}

- (IBAction)gatherNetworkGameCommand {
  do_menu_item_command(mInterface, iGatherGame, false);
  [self setDisplaylinkPaused: NO];
}

- (IBAction)switchBackToGameView {
    //Disable gamepad input while not in SDL menu mode
  SDL_GameControllerEventState(SDL_IGNORE);
  SDL_JoystickEventState(SDL_IGNORE);
  
  [self menuShowReplacementMenu];
  self.viewGL.userInteractionEnabled = YES;//DCW: why are we disabling this, again? //NO; //This must be disabled after the game starts or dialog is cancelled!
//DCW not sure if needed... it will crash the gamepad in this state if buttons are pressed before game starts  mode=GameMode;
  //[self startAnimation]; //Animation must also be restarted after the dialog is dismissed?
}


- (IBAction)switchToSDLMenu {

  [self setDisplaylinkPaused: YES];
  
  self.currentSavedGame = nil;
  [self zeroStats];
  haveNewGamePreferencesBeenSet = YES;
  self.hud.hidden = YES;
  [self menuHideReplacementMenu];
  showControlsOverview = NO;
  [self cancelNewGame];
  self.viewGL.userInteractionEnabled = YES; //This must be disabled after the game starts or dialog is cancelled!
  
  //dcw shit test
  /*[self.hud removeFromSuperview];
  [self.view setNeedsLayout];
  [self.view setNeedsDisplay];
  [self.view layoutSubviews];
  [self.view layoutIfNeeded];
  [self.hud setNeedsLayout];
  [self.hud setNeedsDisplay];
  [self.hud layoutSubviews];
  [self.hud layoutIfNeeded];*/
   
  
    //Enable gamepad navigation
  SDL_GameControllerEventState(SDL_ENABLE);
  SDL_JoystickEventState(SDL_ENABLE);
  mode=SDLMenuMode;
  }

- (IBAction)beginGame {
  haveNewGamePreferencesBeenSet = YES;
  self.viewGL.userInteractionEnabled = YES;//DCW: why are we disabling this, again? //NO; //This must be disabled after the game starts or a dialog is cancelled!
  /*
  CGPoint location = lastMenuTap;
  SDL_SendMouseMotion(0, location.x, location.y);
  SDL_SendMouseButton(SDL_PRESSED, SDL_BUTTON_LEFT);
  SDL_SendMouseButton(SDL_RELEASED, SDL_BUTTON_LEFT);
  SDL_GetRelativeMouseState(NULL, NULL);
   */
  mode = GameMode;
  [self menuHideReplacementMenu];
	
	showControlsOverview = NO;
  self.currentSavedGame = nil;
  [self zeroStats];
  MLog ( @"Current world ticks %d", dynamic_world->tick_count );
	
  // Do we show the overview?
  if ( dynamic_world->current_level_number == 0 ) {
    showControlsOverview = YES;
  }
  ////[Tracking trackPageview:[NSString stringWithFormat:@"/new/%@/%d", [Statistics difficultyToString:player_preferences->difficulty_level], dynamic_world->current_level_number]];
  ////[Tracking tagEvent:@"startup" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
  ////                                              @"difficulty",
  ////                                              [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
  ////                                              @"level", nil]];

	[self cancelNewGame];
  // [self performSelector:@selector(cancelNewGame) withObject:nil afterDelay:0.0];
  
  // Start the new game for real!
  [self switchToSDLMenu];
  [self performSelector:@selector(beginGameCommand) withObject:nil afterDelay:0];
}
- (IBAction)beginGameCommand {
  // New menus
  do_menu_item_command(mInterface, iNewGame, false);
  [self setDisplaylinkPaused: NO]; //Unpause CADL ater joining finished.

  #if defined(A1DEBUG)
    [self shieldCheat:nil];
    [self ammoCheat:nil];
    [self weaponsCheat:nil];
  #endif
}

- (IBAction)cancelNewGame {
  [self closeEvent];
  //[self.newGameView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.3];
  [self.newGameViewController disappear]; //DCW
	[Effects disappearHidingView:self.newGameView]; //DCW
}

- (void)hideHUD {
  self.hud.hidden = YES;
}

- (void)endReplay {
  MLog ( @"End Replay" );
  self.pauseView.hidden = YES;
  self.hud.hidden = YES;
  self.menuView.hidden = NO;
  mode = MenuMode;
  [self closeEvent];
}

- (void)epilog {
  self.hud.hidden = YES;
  mode = CutSceneMode;
}

- (void)playerKilled {
  ////[Tracking trackEvent:@"player" action:@"death" label:@"" value:0];
  ////[Tracking tagEvent:@"died" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
  ////                                          @"difficulty",
  ////                                          [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
  ////                                          @"level", nil]];

  //mode = DeadMode;
 /* self.hud.hidden = YES;
  self.HUDViewController.view.hidden = YES;*/
  
/*  self.restartView.hidden = NO;
  self.restartView.alpha = 0.6;
  [UIView animateWithDuration:2.0 animations:^{
    self.restartView.alpha = 0.8;
  }];*/

}

- (void)bringUpHUD {
  mode = GameMode;
  
  // Setup other views
  [self.moveView setup];
  [self menuHideReplacementMenu];
  [self updateReticule:get_player_desired_weapon(current_player_index)];
  
  /*
  key_definition *key = current_key_definitions;
  for (unsigned i=0; i<NUMBER_OF_STANDARD_KEY_DEFINITIONS; i++, key++) {
    if ( key->action_flag == _left_trigger_state ){
      [self.leftFireView setup:key->offset];
      self.lookView.primaryFire = key->offset;
    } else if ( key->action_flag == _right_trigger_state ){
      [self.rightFireView setup:key->offset];
      self.lookView.secondaryFire = key->offset;
    } else if ( key->action_flag == _toggle_map ){
      [self.mapView setup:key->offset];
      [self.mapView2 setup:key->offset];
    } else if ( key->action_flag == _action_trigger_state ) {
      [self.actionView setup:key->offset];
      [self.restartView setup:key->offset];
    } else if ( key->action_flag == _cycle_weapons_forward ) {
      [self.nextWeaponView setup:key->offset];
      [self.nextWeaponButton setup:key->offset];
    } else if ( key->action_flag == _cycle_weapons_backward ) {
      [self.previousWeaponView setup:key->offset];
      [self.previousWeaponButton setup:key->offset];
    }
  }
   */
#if defined(A1DEBUG)
  // [joyPad startFindingDevices];
#endif

  //  [self.inventoryToggleView setup:input_preferences->shell_keycodes[_key_inventory_left]];
  
  bool showAllControls = player_controlling_game();
  
  if ( player_controlling_game() && [[NSUserDefaults standardUserDefaults] boolForKey:kCrosshairs] ) {
    Crosshairs_SetActive(true);
  } else {
   Crosshairs_SetActive(false);
  }
  
  //Crosshairs_SetActive(false);
  self.hud.alpha = 1.0;
  self.hud.hidden = NO;
  self.HUDViewController.view.hidden = NO;

  /*CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  opacityAnimation.duration = 1.0;
  opacityAnimation.fromValue = [NSNumber numberWithFloat:0.0];
  opacityAnimation.toValue = [NSNumber numberWithFloat:1.0];
  
  CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
  scaleAnimation.duration = 1.0;
  scaleAnimation.fromValue = [NSNumber numberWithFloat:1.5];
  scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.animations = [NSArray arrayWithObjects:opacityAnimation, scaleAnimation, nil];
  group.duration = 1.0;
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  */
  if ( self.HUDViewController == nil ) {
    [self configureHUD:nil];
  }

    //The custom arrangement needs to be restored AFTER the HUD is sized correctly.
  if ([self.HUDViewController isKindOfClass:[BasicHUDViewController class]]) {
    [((BasicHUDViewController*)self.HUDViewController).lookView loadCustomArrangementFromPreferences];
  }
  
  NSMutableArray* views = [NSMutableArray arrayWithArray:[self.hud subviews]];
  [views addObjectsFromArray:[self.HUDViewController.view subviews]];
/*
  for ( UIView *v in views ) {
    // [self.hud.layer addAnimation:group forKey:nil];
    if ( v == self.savedGameMessage || v.tag == 400 || v == self.HUDViewController.view) { continue; }
		//v.hidden = NO; //DCW Commenting out. Some views we need control over visibility instead of setting everything to not hidden.
    if ( showAllControls ) {
      [v.layer addAnimation:group forKey:nil];
    } else {
      if ( v == self.pause ) {
        [v.layer addAnimation:group forKey:nil];
      } else {
        v.hidden = YES;
      }
    }
  }*/
	
  //DCW refresh preferences to update hud prefs.
  helperSetPreferences(true);
  
	//DCW: After updating to arm7, the newGameView would pop up after a new game starts. Setting to hidden here seems to fix the issue.
	[self newGameView].hidden = YES;

}

- (GLfloat) getPauseAlpha { return pauseAlpha; }

- (void)bringUpControlsOverview {
  showControlsOverview = NO;
  // Make the pause fully transparent
  pauseAlpha = 0.0;
  
  // Need to pause and show controls overview
  self.controlsOverviewView.hidden = NO;
  [self runMainLoopOnce:self];
  pause_game();
  // Add touch to continue animation
  CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
  pulse.duration = 1.0;
  pulse.repeatCount = HUGE_VALF;
  pulse.fromValue = [NSNumber numberWithFloat:1.0];
  pulse.toValue = [NSNumber numberWithFloat:0.0];
  pulse.autoreverses = YES;
  // use a timing curve of easy in, easy out..
  pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  for ( UIView *v in [self.controlsOverviewView subviews] ) {
    if ( v.tag == 200 ) {
      [v.layer addAnimation:pulse forKey:nil];
    }
  }
}  


- (void)teleportOut {
  CABasicAnimation *scaleY = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
  scaleY.duration = 0.2;
  scaleY.toValue = [NSNumber numberWithFloat:0.001];
  
  CABasicAnimation *scaleX = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
  scaleX.duration = 0.7;
  scaleX.toValue = [NSNumber numberWithFloat:100.0];
  
  CABasicAnimation *blank = [CABasicAnimation animationWithKeyPath:@"opacity"];
  blank.duration = 5.0;
  blank.beginTime = 0.6;
  blank.fromValue = [NSNumber numberWithFloat:0.0];
  blank.toValue = [NSNumber numberWithFloat:0.0];
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.animations = [NSArray arrayWithObjects:scaleX, scaleY, blank, nil];
  group.duration = 4.0;
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  
  NSMutableArray* views = [NSMutableArray arrayWithArray:[self.hud subviews]];
  [views addObjectsFromArray:[self.HUDViewController.view subviews]];
  for ( UIView *v in views ) {
    // [self.hud.layer addAnimation:group forKey:nil];
    if ( v != self.savedGameMessage ) {
      [v.layer addAnimation:group forKey:nil];
    }
  }
  [self performSelector:@selector(hideHUD) withObject:nil afterDelay:1.3];
  
  // Before we go, change our numbers
  livingBobs += [self livingBobs];
  livingEnemies += [self livingEnemies];
  
  vector<entry_point> levels;
  const int32 AllPlayableLevels = _single_player_entry_point;
  
}

- (void)teleportInLevel {
  CABasicAnimation *scaleY = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
  scaleY.duration = 0.5;
  scaleY.toValue = [NSNumber numberWithFloat:0.001];
  scaleY.repeatCount = 1;
  scaleY.autoreverses = YES;
  
  CABasicAnimation *scaleX = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
  scaleX.duration = 0.5;
  scaleX.toValue = [NSNumber numberWithFloat:100.0];
  scaleX.repeatCount = 1;
  scaleX.autoreverses = YES;
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.animations = [NSArray arrayWithObjects:scaleX, scaleY, nil];
  group.duration = 1.0;
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  
  for ( UIView *v in [self.hud subviews] ) {
    // [self.hud.layer addAnimation:group forKey:nil];
    if ( v != self.savedGameMessage ) {
      [v.layer addAnimation:group forKey:nil];
    }
  }
}


- (void)setOpenGLView:(SDL_uikitopenglview*)oglView {
  self.viewGL = oglView;
  self.viewGL.userInteractionEnabled = YES;//DCW: why are we disabling this, again? //NO;
  
  [self.view insertSubview:self.viewGL belowSubview:self.hud];

  //NSLog(@"Mainscreen bounds w: %f h:%f", [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
  //NSLog(@"Game view frame w: %f h:%f", self.view.frame.size.width, self.view.frame.size.height);
  //NSLog(@"ViewGL frame w: %f h:%f", self.viewGL.frame.size.width, self.viewGL.frame.size.height);
}

#pragma mark -
#pragma mark Pause actions
- (IBAction) resume:(id)sender {
  [self closeEvent];
  self.pauseView.hidden = YES;
  [self pause:sender];
}

- (IBAction) startRearranging:(id)sender {
  if ([self.HUDViewController isKindOfClass:[BasicHUDViewController class]]) {
    [((BasicHUDViewController*)self.HUDViewController).lookView shouldRearrange:YES];
    [((BasicHUDViewController*)self.HUDViewController).movePadView setHidden:YES];
  }
  [self closeEvent];
  self.pauseView.hidden = YES;
  
  UIImage *image = [UIImage imageNamed:@"PauseDone"];
  if(image) {
    [pause setImage:image forState:UIControlStateNormal];
    [pause setImage:image forState:UIControlStateHighlighted];
    [pause setImage:image forState:UIControlStateSelected];
  }
  
}

- (IBAction) stopRearranging:(id)sender {
  if ([self.HUDViewController isKindOfClass:[BasicHUDViewController class]]) {
    [((BasicHUDViewController*)self.HUDViewController).lookView shouldRearrange:NO];
    [((BasicHUDViewController*)self.HUDViewController).movePadView setHidden:NO];
  }
  UIImage *image = [UIImage imageNamed:@"Pause"];
  if(image) {
    [pause setImage:image forState:UIControlStateNormal];
    [pause setImage:image forState:UIControlStateHighlighted];
    [pause setImage:image forState:UIControlStateSelected];
  }
}

- (IBAction) gotoMenu:(id)sender {
  MLog ( @"How do we go back?!" );
  self.pauseView.hidden = YES;
  self.hud.hidden = YES;
  self.menuView.hidden = NO;
  mode = MenuMode;
  [self closeEvent];
  set_game_state(_close_game);
}

- (IBAction) gotoPreferences:(id)sender {
  ////[Tracking trackPageview:@"/settings"];
  [self.preferencesViewController setupUI:mode==MenuMode];
  //self.preferencesView.hidden = NO; //DCW commenting out after new appear animation
	[Effects appearRevealingView:self.preferencesView];
}
 
- (IBAction) closePreferences:(id)sender {
	//[self.preferencesView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5]; //DCW: commenting out after changing close animation.
	[Effects disappearHidingView:self.preferencesView]; //DCW
  [self closeEvent];
}

- (IBAction) help:(id)sender {
  ////[Tracking trackPageview:@"/help"];
  [self.helpViewController setupUI];
  [Effects appearRevealingView:helpView];
}
- (IBAction) closeHelp:(id)sender {
  [self closeEvent];
  self.helpView.alpha = 1.0;
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5];
  self.helpView.alpha = 0.0;
  [UIView commitAnimations];
  [self.helpView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5];
  if ( showingHelpBeforeFirstGame ) {
    showingHelpBeforeFirstGame = NO;
    [self beginGame];
  }
}

- (void)configureHUD:(NSString*)HUDType{
  
  if ( self.HUDTouchViewController == nil ) {
    self.HUDTouchViewController = [[BasicHUDViewController alloc] initWithNibName:@"BasicHUDViewController" bundle:[NSBundle mainBundle]];
   //// self.HUDJoypadViewController = [[JoypadHUDViewController alloc] initWithNibName:@"JoypadHUDViewController" bundle:[NSBundle mainBundle]];
  }
  
  [self.HUDViewController.view removeFromSuperview];
  if ( HUDType == nil ) {
    self.HUDTouchViewController = [[BasicHUDViewController alloc] initWithNibName:@"BasicHUDViewController" bundle:[NSBundle mainBundle]];
    self.HUDViewController = self.HUDTouchViewController;
  } else {
   //// self.HUDViewController = self.HUDJoypadViewController;
  }
  [self.HUDViewController.view setFrame:self.hud.bounds];//DCW: the inserted subview needs to be the same size as the superview.
  
  [self.hud insertSubview:self.HUDViewController.view belowSubview:self.pause];
}
/*- (IBAction) initiateJoypad:(id)sender {
  [self configureHUD:@"JoypadHUDViewController"];
  [((JoypadHUDViewController*) self.HUDViewController) connectToDevice];
}
- (IBAction) cancelJoypad:(id)sender {
  [self configureHUD:nil];
}*/

#pragma mark -
#pragma mark Choose saved game methods

extern void force_system_colors(void);
extern bool choose_saved_game_to_load(FileSpecifier& File);
extern bool load_and_start_game(FileSpecifier& File);

- (IBAction)chooseSaveGame {
  
  if ( [self.saveGameViewController numberOfSavedGames] == 0 ) {
    // Pop something up
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No saved games"
                                            message:@"There are no saved games, please start a new game"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
    [alert show];
    [alert release];
    return;
  }
  
  [self.saveGameViewController.tableView reloadData];
  self.loadGameView.hidden = NO;
  [self.saveGameViewController appear];
  [Effects appearRevealingView:self.loadGameView];
  ////[Tracking trackPageview:@"/load"];
}

- (IBAction) gameChosen:(SavedGame*)game {
  [self switchToSDLMenu];
  [self performSelector:@selector(gameChosenCommand:) withObject:game afterDelay:0];
}

- (IBAction) gameChosenCommand:(SavedGame*)game {
  [self performSelector:@selector(chooseSaveGameCanceled) withObject:nil afterDelay:0.0];

  MLog ( @"Current world ticks %d", dynamic_world->tick_count );
  self.currentSavedGame = game;
  int sessions = game.numberOfSessions.intValue + 1;
  game.numberOfSessions = [NSNumber numberWithInt:sessions];
  [game.managedObjectContext save:nil];

  
  MLog (@"Loading game: %@", game.filename );
  FileSpecifier FileToLoad ( (char*)[[self.saveGameViewController fullPath:game.filename] UTF8String] );
  load_and_start_game(FileToLoad);
  ////[Tracking trackPageview:[NSString stringWithFormat:@"/load/%@/%d", [Statistics difficultyToString:player_preferences->difficulty_level], dynamic_world->current_level_number]]; 

  ////[Tracking tagEvent:@"load" attributes:[NSDictionary dictionaryWithObjectsAndKeys:
  ////                                       [Statistics difficultyToString:player_preferences->difficulty_level],
  ////                                       @"difficulty",
  ////                                       [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
  ////                                       @"level",
  ////                                      nil]];
  if(local_player) {
    MLog ( @"Restored game in position %d, %d", local_player->location.x, local_player->location.y );
  } else {
     MLog ( @"Game loading cancelled.");
    
  }
  [self setDisplaylinkPaused: NO]; 
}

- (IBAction) chooseSaveGameCanceled {
  [self closeEvent];
  [Effects disappearHidingView:self.loadGameView];
  [self.saveGameViewController disappear];
  //[self.loadGameView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5];
}

extern SDL_Surface *draw_surface;

- (IBAction)saveGame {
  if ( self.currentSavedGame == nil ) {
    self.currentSavedGame = [self.saveGameViewController createNewGameFile];
  }
  
  //DCW Copy and paste of metadata generation from the quicksaver, to permit calling the normal savegame code.
  //We need to do this first, so that the map stuff is initialized so we can create the preview for ourself.
  //The map preview generation is redundant, so maybe we can do this more efficiently later.
  QuickSave save;
  time(&(save.save_time));
  char fmt_time[256];
  tm *time_info = localtime(&(save.save_time));
  strftime(fmt_time, 256, "%x %R", time_info);
  save.formatted_time = fmt_time;
  save.level_name = mac_roman_to_utf8(static_world->level_name);
  save.players = dynamic_world->player_count;
  save.ticks = dynamic_world->tick_count;
  char fmt_ticks[256];
  if (save.ticks < 60*TICKS_PER_MINUTE)
    sprintf(fmt_ticks, "%d:%02d",
            save.ticks/TICKS_PER_MINUTE,
            (save.ticks/TICKS_PER_SECOND) % 60);
  else
    sprintf(fmt_ticks, "%d:%02d:%02d",
            save.ticks/(60*TICKS_PER_MINUTE),
            (save.ticks/TICKS_PER_MINUTE) % 60,
            (save.ticks/TICKS_PER_SECOND) % 60);
  save.formatted_ticks = fmt_ticks;
  DirectorySpecifier quicksave_dir;
  quicksave_dir.SetToQuickSavesDir();
  std::ostringstream oss;
  oss << save.save_time;
  std::string base = oss.str();
  save.save_file.FromDirectory(quicksave_dir);
  save.save_file.AddPart(base + ".sgaA");
  std::string metadata = build_save_metadata(save);
  std::ostringstream image_stream;
  
  bool success = build_map_preview(image_stream);
  
  ofstream thumbFile;
  thumbFile.open ((char*)[[self.saveGameViewController fullPath:self.currentSavedGame.mapFilename] UTF8String]);
  thumbFile << image_stream.str();
  thumbFile.close();
  
  SavedGame* game = currentSavedGame;
  game.lastSaveTime = [NSDate date];
  game.level = [NSString stringWithFormat:@"%s", static_world->level_name];
  int seconds = (int) ( dynamic_world->tick_count ) / (float)TICKS_PER_SECOND;
  game.timeInSeconds = [NSNumber numberWithInt:seconds];
  
  game.damageGiven = [NSNumber numberWithInt:local_player->monster_damage_given.damage];
  game.damageTaken = [NSNumber numberWithInt:local_player->monster_damage_taken.damage];
  game.kills = [NSNumber numberWithInt:local_player->monster_damage_given.kills];
  self.currentSavedGame.killsByFist = [NSNumber numberWithInt:(self.currentSavedGame.killsByFist.intValue + KillRecord[_weapon_fist])];
  self.currentSavedGame.killsByPistol = [NSNumber numberWithInt:(self.currentSavedGame.killsByPistol.intValue + KillRecord[_weapon_pistol])];
  self.currentSavedGame.killsByPlasmaPistol = [NSNumber numberWithInt:(self.currentSavedGame.killsByPlasmaPistol.intValue + KillRecord[_weapon_plasma_pistol])];
  self.currentSavedGame.killsByAssaultRifle = [NSNumber numberWithInt:(self.currentSavedGame.killsByAssaultRifle.intValue + KillRecord[_weapon_assault_rifle])];
  self.currentSavedGame.killsByMissileLauncher = [NSNumber numberWithInt:(self.currentSavedGame.killsByMissileLauncher.intValue + KillRecord[_weapon_missile_launcher])];
  self.currentSavedGame.killsByFlamethrower = [NSNumber numberWithInt:(self.currentSavedGame.killsByFlamethrower.intValue + KillRecord[_weapon_flamethrower])];
  self.currentSavedGame.killsByAlienShotgun = [NSNumber numberWithInt:(self.currentSavedGame.killsByAlienShotgun.intValue + KillRecord[_weapon_alien_shotgun])];
  self.currentSavedGame.killsByShotgun = [NSNumber numberWithInt:(self.currentSavedGame.killsByShotgun.intValue + KillRecord[_weapon_shotgun])];
  self.currentSavedGame.killsBySMG = [NSNumber numberWithInt:(self.currentSavedGame.killsBySMG.intValue + KillRecord[_weapon_smg])];
  
  self.currentSavedGame.aliensLeftAlive = [NSNumber numberWithInt:(self.currentSavedGame.aliensLeftAlive.intValue + livingEnemies)];
  self.currentSavedGame.bobsLeftAlive = [NSNumber numberWithInt:(self.currentSavedGame.bobsLeftAlive.intValue + livingBobs)];

  // Calculate shots fired and accuracy
  extern player_weapon_data *get_player_weapon_data(const short player_index);
  player_weapon_data* weapon_data = get_player_weapon_data(local_player_index);
  int shotsFired = 0;
  int shotsHit = 0;
  for ( int widx = 0; widx < MAXIMUM_NUMBER_OF_WEAPONS; widx++ ) {
    for ( int tidx = 0; tidx < NUMBER_OF_TRIGGERS; tidx++ ) {
      shotsFired += weapon_data->weapons[widx].triggers[tidx].shots_fired;
      shotsHit += weapon_data->weapons[widx].triggers[tidx].shots_hit;
    }
  }
  game.shotsFired = [NSNumber numberWithInt:shotsFired];
  float accuracy;
  if ( shotsFired > 0 ) {
    accuracy = 100 * shotsHit / (float)shotsFired;
  } else {
    accuracy = 0.0;
  }
  game.accuracy = [NSNumber numberWithFloat:accuracy];
  
  [statistics updateLifetimeKills:KillRecord
                   withMultiplier:DifficultyMultiplier[dynamic_world->game_information.difficulty_level]];
  [statistics updateLifetimeDamage:DamageRecord
                    withMultiplier:DifficultyMultiplier[dynamic_world->game_information.difficulty_level]];
  
  [self zeroStats];
  
  game.scenario = [AlephOneAppDelegate sharedAppDelegate].scenario;
  [[AlephOneAppDelegate sharedAppDelegate].scenario addSavedGamesObject:game];
  
  MLog ( @"Saving game to %@", self.currentSavedGame.filename); 
  FileSpecifier file ( (char*)[[self.saveGameViewController fullPath:self.currentSavedGame.filename] UTF8String] );
  //save_game_file(file);
  
  success = save_game_file(file, metadata, image_stream.str());
  
  
  MLog ( @"Saving game: %@", game );
  NSError *error = nil;
  if (![game.managedObjectContext save:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
  }
  
  if (![game.scenario.managedObjectContext save:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
  }
  
  
  // Animate the saved game message
  self.savedGameMessage.hidden = NO;
  self.savedGameMessage.alpha = 1.0;
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDelay:1.0];
  [UIView setAnimationDuration:1.0];
  self.savedGameMessage.alpha = 0.0;
  [UIView commitAnimations];
  
}

#pragma mark -
#pragma mark Film Methods
extern bool handle_open_replay(FileSpecifier& File);
- (IBAction)chooseFilm {
  ////[Tracking trackPageview:@"/film"];
  if ( [self.filmViewController numberOfSavedFilms] == 0 ) {
    // Pop something up
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No saved films"
                                                    message:@"There are no saved films, please start a new game to record a film."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    return;
  }
  
  [self.filmViewController.tableView reloadData];
  self.filmView.hidden = NO;
  self.filmView.alpha = 1.0;
  [self.filmViewController appear];
}

- (IBAction) filmChosen:(Film*)film {
  self.filmView.alpha = 1.0;
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:1.4];
  self.filmView.alpha = 0.0;
  [UIView commitAnimations];
  
  FileSpecifier FileToLoad ( (char*)[film.filename UTF8String] );
  // load_and_start_game(FileToLoad);
  handle_open_replay(FileToLoad);
#if defined(A1DEBUG)
  [self shieldCheat:nil];
  [self ammoCheat:nil];
  [self weaponsCheat:nil];
#endif
  ////[Tracking trackPageview:@"/film/load"];
}

- (IBAction) chooseFilmCanceled {
  [self closeEvent];
  [self.filmViewController disappear];
  [self.filmView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5];
}

- (IBAction)saveFilm {
  if ( [[NSUserDefaults standardUserDefaults] boolForKey:kUseVidmasterMode] ) {
    saveFilmCheatWarning = [[UIAlertView alloc] initWithTitle:@"Really save?" message:@"You have enabled cheats, this may interfere with film playback.\nReally save?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    [saveFilmCheatWarning show];
  } else {
    [self saveFilmForReal];
  }
}
- (void)saveFilmForReal {
  AlertPrompt *passwordAlert = [[AlertPrompt alloc] initWithTitle:@"Film Name"
                                                         delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) okButtonTitle:NSLocalizedString(@"OK",nil)];
  [passwordAlert show];
  [passwordAlert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if ( alertView == rateGame ) {
    [Appirater rateApp];
    return;
  }
  if ( alertView == saveFilmCheatWarning ) {
    if ( buttonIndex != 0 ) {
      [self saveFilmForReal];
    }
    return;
  }
  if ( showingHelpBeforeFirstGame ) {
    alertView.hidden = YES;
    if ( buttonIndex == 0 ) {
      // User hit cancel, so start the game...
      showingHelpBeforeFirstGame = NO;
      [self performSelector:@selector(beginGame) withObject:nil afterDelay:0.0];
      ////[Tracking trackEvent:@"player" action:@"firsthelp" label:@"no" value:0];
    } else {
      ////[Tracking trackEvent:@"player" action:@"firsthelp" label:@"yes" value:0];
      [self help:self];
    }
    return;
  }
  
  if ( buttonIndex == 0 ) { showingHelpBeforeFirstGame = NO; return; }
  Film* film = [self.filmViewController createFilm];
  AlertPrompt *prompt = (AlertPrompt*)alertView;
  film.name = prompt.enteredText;
  film.lastSaveTime = [NSDate date];
  film.scenario = [AlephOneAppDelegate sharedAppDelegate].scenario;
  [[AlephOneAppDelegate sharedAppDelegate].scenario addFilmsObject:film];
  
  MLog ( @"Saving game to %@", film.filename);
  FileSpecifier src_file;
  get_recording_filedesc(src_file);
  
  FileSpecifier file ( (char*)[film.filename UTF8String] );
  MLog(@"Save film %s to %s", src_file.GetPath(), [film.filename UTF8String])
  file.CopyContents(src_file);

  MLog ( @"Saving film: %@", film );
  [film.managedObjectContext save:nil];
}

#pragma mark -
#pragma mark Replacement menus
- (IBAction)menuShowReplacementMenu {

  [self setDisplaylinkPaused: NO]; //dcw shit test

  self.logoView.hidden = YES;
  self.episodeImageView.image = nil;
  self.bungieAerospaceImageView.image = nil;
  self.splashView.image = nil;

  if ( !self.replacementMenuView.hidden && shouldAutoBot() ) {
    [self performSelector:@selector(menuGatherNetworkGame) withObject:nil afterDelay:2];
  }
  
  self.replacementMenuView.hidden = NO;
}

- (IBAction)menuHideReplacementMenu {
  //self.replacementMenuView.hidden = YES;
  [Effects disappearWithDelay:self.replacementMenuView];
}

- (IBAction)menuNewGame {
  [self PlayInterfaceButtonSound];
  [self newGame];
}
- (IBAction)menuJoinNetworkGame {
  [self PlayInterfaceButtonSound];
  [self joinNetworkGame];
}
- (IBAction)menuGatherNetworkGame {
  [self PlayInterfaceButtonSound];

    //If this is the autobot, don't queue the ok operation if we are already in sdl mode
  if (shouldAutoBot() && mode != SDLMenuMode ) {
    //Accept the Gather dialog after a bit of a delay.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      //NSLog(@"Queueing ok");
      sleep(10);
      doOkOnNextDialog(YES);
    });
  }
  
  [self gatherNetworkGame];
}
- (IBAction)menuLoadGame {
  [self PlayInterfaceButtonSound];
  do_menu_item_command(mInterface, iLoadGame, false);
}
- (IBAction)menuPreferences {
  [self PlayInterfaceButtonSound];
  do_menu_item_command(mInterface, iPreferences, false);
}
- (IBAction)menuStore {
  [self PlayInterfaceButtonSound];
  MLog ( @"Goto store" );
}

- (IBAction)cancelStore {
  [self PlayInterfaceButtonSound];
  [Effects disappearHidingView:self.purchaseView];
}

- (IBAction)menuAbout {
  [self PlayInterfaceButtonSound];
  [aboutText scrollRangeToVisible:NSMakeRange(0,1)]; //Scroll text to top.
  [Effects appearRevealingView:self.aboutView];
}

- (IBAction)cancelAbout {
  [self PlayInterfaceButtonSound];
  [Effects disappearHidingView:self.aboutView];
}

- (IBAction)finishIntro:(id)sender {
  [[AlephOneAppDelegate sharedAppDelegate] performSelector:@selector(finishIntro:) withObject:nil afterDelay:0];
  NSLog(@"Stopping intro early");
}

- (IBAction)menuTip {
  [self PlayInterfaceButtonSound];
  [self tipTheDeveloper];
}

-(void) PlayInterfaceButtonSound
{
  /*
    SoundManager::instance()->PlaySound(Sound_ButtonSuccess(), (world_location3d *) NULL,
                                        NONE);
   */
}


#pragma mark -
#pragma mark Gestures

- (void)controlsOverviewTap:(UITapGestureRecognizer *)recognizer {
  self.controlsOverviewView.hidden = YES;
  pauseAlpha = kPauseAlphaDefault;
  resume_game();
}


- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
  if ( mode == MenuMode || mode == CutSceneMode || mode == DeadMode ) {
    if ( recognizer == menuTapGesture ) {
      NSLog ( @"Handling menu tap" );
      // Send an action...
      [self.HUDViewController actionDown:self];
      // Delay a bit
      [self.HUDViewController performSelector:@selector(actionUp:) withObject:self afterDelay:0.2];
      CGPoint location = [self transformTouchLocation:[recognizer locationInView:self.menuView]];
      location = [recognizer locationInView:self.menuView];
      lastMenuTap = location;
      SDL_SendMouseMotion (NULL, SDL_TOUCH_MOUSEID, 0, location.x, location.y);
      SDL_SendMouseButton(NULL, SDL_TOUCH_MOUSEID, SDL_PRESSED, SDL_BUTTON_LEFT);
      SDL_SendMouseButton(NULL, SDL_TOUCH_MOUSEID, SDL_RELEASED, SDL_BUTTON_LEFT);
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

#pragma mark - Reticule
- (void)updateReticule:(int)index {
  
  //DCW all of this stuff is now replaced by engine reticule
  self.reticule.hidden = YES;
  Crosshairs_SetActive([[NSUserDefaults standardUserDefaults] boolForKey:kCrosshairs] );
  return;
  
  if ( mode == DeadMode ) { return; }
  if ( world_view->overhead_map_active || world_view->terminal_mode_active ) {
    self.reticule.hidden = YES;
    return;
  }   
  
  if ( ![[NSUserDefaults standardUserDefaults] boolForKey:kCrosshairs] ) {
    self.reticule.hidden = YES;
    return;
  }
  self.reticule.hidden = NO;
  
  if ( index < 0 ) {
    index = get_player_desired_weapon(current_player_index);
  }
  if ( index == currentReticleImage ) {
    return;
  }
  currentReticleImage = index;
  
  if ( [[NSUserDefaults standardUserDefaults] boolForKey:kHaveReticleMode] ) {
    // Fancy reticule
    //self.reticule.image = [UIImage imageNamed:[reticuleImageNames objectAtIndex:index]];
    Crosshairs_SetActive(true);
  } else {
    // Basic reticule
    self.reticule.image = [UIImage imageNamed:@"ret_default"];    
  }

  return;
}

#pragma mark -
#pragma mark Game controls

// If we are playing, pause...
- (IBAction)pauseForBackground:(id)from {
  if ( mode == GameMode && !isPaused ) {
    [self pause:from];
  }
  return;
}

- (IBAction)togglePause:(id)from{
  
  if ( mode != GameMode || !getLocalPlayer() ) {
    return;
  }
  
  if( isPaused ) {
    [self pause:self];
  } else {
    [self resume:self];
  }
    
  return;
}
  

- (IBAction)pause:(id)from {
  
  UIImage *image = [UIImage imageNamed:@"Pause"];
  if(image) {
    [pause setImage:image forState:UIControlStateNormal];
    [pause setImage:image forState:UIControlStateHighlighted];
    [pause setImage:image forState:UIControlStateSelected];
  }
  
    //The pause action, if we are in arrangemewnt, just stops re-arranging.
  if ([self.HUDViewController isKindOfClass:[BasicHUDViewController class]]) {
    if( ((BasicHUDViewController*)self.HUDViewController).lookView.inRearrangement ) {
      [self stopRearranging:self];
    }
  }
  
  
  // If we are dead, don't do anything
  if ( mode == DeadMode ) { return; }
  if ( from != nil ) {
    [self PlayInterfaceButtonSound];
  }
  // Level name is
  // static_world->level_name
  MLog (@"Camera Polygon Index: %d", local_player->camera_polygon_index );
  MLog (@"Supporting Polygon Index: %d", local_player->supporting_polygon_index );
  [self livingBobs];
  [self livingEnemies];
  // Normally would just darken the screen, here we may want to popup a list of things to do.
  if ( isPaused ) {
    self.pauseView.hidden = YES;
    resume_game();
    [self closeEvent];
  } else {
    ////[Tracking trackPageview:@"/pause"];
    pause_game();
    self.pauseView.hidden = NO;
    [self.pauseViewController setup];
    self.pauseView.alpha = 0.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    self.pauseView.alpha = 1.0;
    [UIView commitAnimations];    
  }
  [self updateReticule:get_player_desired_weapon(current_player_index)];
  isPaused = !isPaused;
}

- (void)zeroStats {
  livingBobs = livingEnemies = 0;
  for ( int i = 0; i < MAXIMUM_NUMBER_OF_WEAPONS; i++ ) {
    DamageRecord[i] = 0;
    KillRecord[i] = 0;
  }
}

- (void) projectileHit:(short)index withDamage:(int)damage {
  DamageRecord[index] += damage;
}
- (void) projectileKill:(short)index {
  KillRecord[index]++;
}

- (int) livingEnemies {
  struct monster_data *monster;
  short live_alien_count= 0;
  short monster_index;
  
  for (monster_index= 0, monster= monsters;
       monster_index<MAXIMUM_MONSTERS_PER_MAP; ++monster_index, ++monster)
  {
    if (SLOT_IS_USED(monster)) {
      struct monster_definition *definition= get_monster_definition_external(
                                                                    monster->type);
      if ((definition->flags&_monster_is_alien) ||
          ((static_world->environment_flags&_environment_rebellion) &&
           !MONSTER_IS_PLAYER(monster))) {
            live_alien_count+= 1;
          }
    }
  }
  MLog(@"Live aliens: %d", live_alien_count );
  return live_alien_count;
  
}


- (int) livingBobs {
  MLog (@"Current Bob Causalties: %d count: %d", dynamic_world->current_civilian_causalties, dynamic_world->current_civilian_count );
  MLog (@"Total Bob Causalties: %d count: %d", dynamic_world->total_civilian_causalties, dynamic_world->total_civilian_count );
  
  struct monster_data *monster;
  short live_alien_count= 0;
  short monster_index;
  
  for (monster_index= 0, monster= monsters;
       monster_index<MAXIMUM_MONSTERS_PER_MAP; ++monster_index, ++monster)
  {
    if (SLOT_IS_USED(monster)) {
      struct monster_definition *definition= get_monster_definition_external( monster->type);
      if ( (definition->_class & (_class_human_civilian|_class_madd|_class_possessed_hummer)) && !MONSTER_IS_PLAYER(monster)) {
        live_alien_count ++;
      }
    }
  }
  MLog(@"Live bobs: %d", live_alien_count );
#if SCENARIO == 1
  // Can't get to the first bob...
  if ( strcmp ( static_world->level_name, "Arrival" ) == 0 ) {
    live_alien_count--;
  }
#endif
  return live_alien_count;
  
#if 0
_civilian_crew,
_civilian_science,
_civilian_security,
_civilian_assimilated,
_civilian_fusion_crew,
_civilian_fusion_science,
_civilian_fusion_security,
_civilian_fusion_assimilated,
  struct monster_data *monster;
  short live_alien_count= 0;
  short LIVE_ALIEN_THRESHHOLD = 8;
  short threshhold= LIVE_ALIEN_THRESHHOLD;
  short monster_index;
  
  for (monster_index= 0, monster= monsters;
       monster_index<MAXIMUM_MONSTERS_PER_MAP; ++monster_index, ++monster)
  {
    if (SLOT_IS_USED(monster)) {
      struct monster_definition *definition= get_monster_definition_external(monster->type);
      if ((definition->flags&_monster_is_alien) ||
          ((static_world->environment_flags&_environment_rebellion) &&
           !MONSTER_IS_PLAYER(monster))) {
            live_alien_count+= 1;
          }
    }
  }
  
  if (static_world->environment_flags&_environment_rebellion) {
    threshhold= 0;
  }
  
  return live_alien_count;
#endif
}

#pragma mark -
#pragma mark Cheats

- (IBAction)shieldCheat:(id)sender {
  [self PlayInterfaceButtonSound];

  // [self invincibilityCheat:sender];
  ////[Tracking trackEvent:@"player" action:@"cheat" label:@"shield" value:dynamic_world->current_level_number];
  ////[Tracking tagEvent:@"shieldCheat" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
   ////                                         @"difficulty",
   ////                                         [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
   ////                                         @"level", nil]];

  local_player->suit_energy= MAX(local_player->suit_energy, 3*PLAYER_MAXIMUM_SUIT_ENERGY);
  local_player->suit_oxygen = MAX ( local_player->suit_oxygen, PLAYER_MAXIMUM_SUIT_OXYGEN );
  mark_shield_display_as_dirty();  
  currentSavedGame.haveCheated = [NSNumber numberWithBool:YES];
}

- (IBAction)invincibilityCheat:(id)sender {
  ////[Tracking trackEvent:@"player" action:@"cheat" label:@"invincibility" value:dynamic_world->current_level_number];
  ////[Tracking tagEvent:@"invincibilityCheat" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
  ////                                              @"difficulty",
  ////                                              [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
  ////                                              @"level", nil]];
  process_player_powerup(local_player_index, _i_invincibility_powerup);
  // process_player_powerup(local_player_index, _i_infravision_powerup );
  currentSavedGame.haveCheated = [NSNumber numberWithBool:YES];
}

- (IBAction)saveCheat:(id)sender {
  [self PlayInterfaceButtonSound];

  ////[Tracking trackEvent:@"player" action:@"cheat" label:@"save" value:dynamic_world->current_level_number];
  ////[Tracking tagEvent:@"saveCheat" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
  ////                                            @"difficulty",
  ////                                            [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
  ////                                            @"level", nil]];


  currentSavedGame.haveCheated = [NSNumber numberWithBool:YES];
  MLog ( @"Damage given %d (%d kills) Damage taken %d (%d kills)",
        local_player->monster_damage_given.damage,
        local_player->monster_damage_given.kills,
        local_player->monster_damage_taken.damage,
        local_player->monster_damage_taken.kills
        );
  MLog ( @"Ticks at last save: %d", local_player->ticks_at_last_successful_save );
  save_game();
}

- (void)pickedUp:(short)itemType {
  
}
short items[]=
{ 
  // Only get the SMG/Flechette gun in Infinity
#if SCENARIO == 3
  _i_smg_ammo,
#endif
  _i_assault_rifle_magazine, _i_assault_grenade_magazine,
  _i_magnum_magazine, _i_missile_launcher_magazine,
  _i_flamethrower_canister,
  _i_plasma_magazine, _i_shotgun_magazine, _i_shotgun
  
};


- (IBAction)ammoCheat:(id)sender {
  ////[Tracking trackEvent:@"player" action:@"cheat" label:@"ammo" value:dynamic_world->current_level_number];
  ////[Tracking tagEvent:@"ammoCheat" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
  ////                                              @"difficulty",
  ////                                              [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
  ////                                              @"level", nil]];

  currentSavedGame.haveCheated = [NSNumber numberWithBool:YES];
  short items[]=
  { 
    // Only get the SMG/Flechette gun in Infinity
#if SCENARIO == 3
    _i_smg_ammo,
#endif
    _i_assault_rifle_magazine, _i_assault_grenade_magazine,
    _i_magnum_magazine, _i_missile_launcher_magazine,
    _i_flamethrower_canister,
    _i_plasma_magazine, _i_shotgun_magazine, _i_shotgun
  
  };
  
  for(unsigned index= 0; index<sizeof(items)/sizeof(short); ++index)
  {
    switch(get_item_kind(items[index]))
    {
      case _ammunition:
        AddItemsToPlayer(items[index],10);
        break;        
      default:
        break;
    }
    process_new_item_for_reloading(local_player_index, items[index]);
  }
  
}
- (IBAction)weaponsCheat:(id)sender {
  ////[Tracking trackEvent:@"player" action:@"cheat" label:@"weapons" value:dynamic_world->current_level_number];
  ////[Tracking tagEvent:@"weaponsCheat" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
  ////                                              @"difficulty",
  ////                                              [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
  ////                                              @"level", nil]];

  currentSavedGame.haveCheated = [NSNumber numberWithBool:YES];
  short items[]=
  {
    // Only get the SMG/Flechette gun in Infinity
#if SCENARIO == 3
    _i_smg,
#endif
    _i_assault_rifle, _i_magnum, _i_missile_launcher, _i_flamethrower,
    _i_plasma_pistol, _i_alien_shotgun, _i_shotgun

  };
  
  for(unsigned index= 0; index<sizeof(items)/sizeof(short); ++index)
  {
    switch(get_item_kind(items[index]))
    {
      case _weapon:
        if(items[index]==_i_shotgun || items[index]==_i_magnum) {
          AddOneItemToPlayer(items[index],2);
        }
        else {
          AddItemsToPlayer(items[index],1);
        }
        break;
      default:
        break;
    }
    process_new_item_for_reloading(local_player_index, items[index]);
  }
  
}


#pragma mark -
#pragma mark Animation Methods

- (void)startAnimation {
  if ( !animating ) {
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
        //dcw changing this to an alternative... [displayLink setFrameInterval:animationFrameInterval];
        [displayLink setPreferredFramesPerSecond:30]; //DCW changed from deprecated setFrameInterval
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    } else {
      animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(runMainLoopOnce:) userInfo:nil repeats:TRUE];
    }
    inMainLoop = NO;
    animating = YES;
  }
}
- (void)stopAnimation
{
  if (animating)
  {
    inMainLoop = NO;
    if (displayLinkSupported)
    {
      [displayLink invalidate];
      displayLink = nil;
    }
    else
    {
      [animationTimer invalidate];
      animationTimer = nil;
    }
    
    animating = FALSE;
  }
}

- (void)runMainLoopOnce:(id)sender {
      //Capture touch movement deltas immediately!
    grabMovementDeltasForCurrentFrameAtInterval( (NSTimeInterval)[(CADisplayLink*)displayLink timestamp] ); //This will probably crash if displayLink is not supported.
  
    // Do some house keeping here
    if (world_view->overhead_map_active) {
        self.zoomInButton.hidden = NO;
        self.zoomOutButton.hidden = NO;
    } else {
        self.zoomInButton.hidden = YES;
        self.zoomOutButton.hidden = YES;
    }
    [self updateReticule:get_player_desired_weapon(current_player_index)];
    if ( get_game_state() == _display_main_menu && ( mode == SDLMenuMode || mode == MenuMode || mode == CutSceneMode ) ) {
        //[self menuShowReplacementMenu];
      [self switchBackToGameView];
      self.viewGL.userInteractionEnabled = YES; //DCW: why are we disabling this, again? NO; //DCW
      mode = MenuMode;
      
    }
    // Causing a bug, always dim
    // [self.HUDViewController dimActionKey:0];
    if ( mode == GameMode ) {
        short target_type, object_index;
        object_index = localFindActionTarget(current_player_index, MAXIMUM_ACTIVATION_RANGE, &target_type);
        if ( NONE == object_index ) {
          if ([self.HUDViewController isKindOfClass:[BasicHUDViewController class]] && [((BasicHUDViewController*)self.HUDViewController).lookView inRearrangement]) {
            [self.HUDViewController lightActionKeyWithTarget:_target_is_platform objectIndex:NONE];
          } else {
            [self.HUDViewController dimActionKey];
          }
        } else {
            [self.HUDViewController lightActionKeyWithTarget:target_type objectIndex:object_index];    
        }
      
      if(gameController.mainController != nil) {
        moveMouseRelative(gameController.rightXAxis, gameController.rightYAxis);
        
        if (gameController.rightXAxis != 0.0 || gameController.rightYAxis != 0.0) {
          [[GameViewController sharedInstance].HUDViewController.lookPadView unPauseGyro]; //Any movement unpauses gyro.
        }
        
        //Always run above media. Never check headBelowMedia or set preferences if no game is active, otherwise it will crash!
        //This logic is essentially duplicated in the AOGameController... we just need it to work when there is no controller input also.
        if ([[GameViewController sharedInstance] mode] == GameMode) {
          if(headBelowMedia()){
            SET_FLAG(input_preferences->modifiers,_inputmod_interchange_swim_sink, true);
          } else {
            SET_FLAG(input_preferences->modifiers,_inputmod_interchange_swim_sink, false);
          }
        }
        
      }
      
      [self.HUDViewController updateSwimmingIndicator];
      [self.HUDViewController updateEscapeButtonVisibility];
      if(shouldHideHud() || gameController.mainController != nil) {
          //If alpha is too low, the UI won't respond to input responding. Don't use 0 if you still want interaction.
          //Of course, use zero if there is a controller connected
        float hudAlpha = gameController.mainController != nil ? 0.0 : 0.03;
        
        self.HUDViewController.view.alpha = hudAlpha;
      } else {
        self.HUDViewController.view.alpha = 1.0;
      }
      
      if( shouldAutoBot() ) {
        
          //If autobot sees anything, run forward!
        if(isMonsterCentered() || isMonsterOnLeft() || isMonsterOnRight()) {
          setKey(((BasicHUDViewController*)self.HUDViewController).movePadView.forwardKey, 1);
        } else {
          setKey(((BasicHUDViewController*)self.HUDViewController).movePadView.forwardKey, 0);
        }
        
          //Autobot just toggles action key constantly.
        if (machine_tick_count() % 7 == 0) {
          [self.HUDViewController actionDown:self];
        } else if (machine_tick_count() % 19 == 0) {
          [self.HUDViewController actionUp:self];
        }
      }
    }
  
    //DCW adding check for SDLMenuMode, so we don't run the main loop. It slurps up SDL events, which the menus need instead.
    if ( !inMainLoop && mode != SDLMenuMode )
    {
        inMainLoop = YES;
        AlephOneMainLoop();
        inMainLoop = NO;
    }

      //Hide or show hud based on teleporting status. This prevents HUD from being visible during level changes.
    if (dynamic_world->player_count) {
      struct player_data *player= get_player_data(0);
        [self.hud setHidden:PLAYER_IS_TELEPORTING(player)];
    }
}

- (void)setDialogOk {
  doOkOnNextDialog(1);
}

#pragma mark -
#pragma mark Progress methods
- (void) startProgress:(int)total {
  self.progressView.hidden = NO;
  self.hud.hidden = YES;
  self.restartView.hidden = YES;
  [self.progressViewController startProgress:total];
  MLog ( @"total = %d", total );
}

- (void) progressCallback:(int)delta {
  [self.progressViewController progressCallback:delta];
}
- (void) stopProgress {
  self.progressView.hidden = YES;
  [self.progressViewController progressFinished];
  [self performSelector:@selector(bringUpHUD) withObject:nil afterDelay:0.0];
  MLog ( @"stopProgress" );
}

#pragma mark -
#pragma mark Map and Inventory methods
- (IBAction)changeInventory {
  PlayInterfaceButtonSound(Sound_ButtonSuccess());
  scroll_inventory(-1);
  ////[Tracking trackEvent:@"player" action:@"inventory" label:@"" value:0];
  ////[Tracking tagEvent:@"inventory" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
  ////                                              @"difficulty",
  ////                                              [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
  ////                                              @"level", nil]];

}

- (IBAction)startPrimaryFire {
  [HUDViewController primaryFireDown:self];
}
- (IBAction)stopPrimaryFire{
  [HUDViewController primaryFireUp:self];
}
- (IBAction)startSecondaryFire{
  [HUDViewController secondaryFireDown:self];
}
- (IBAction)stopSecondaryFire{
  [HUDViewController secondaryFireUp:self];
}


- (IBAction)zoomMapIn {
  if (zoom_overhead_map_in()) {
    PlayInterfaceButtonSound(Sound_ButtonSuccess());
    ////[Tracking trackEvent:@"player" action:@"zoomin" label:@"success" value:0];
    ////[Tracking tagEvent:@"zoomin" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
    ////                                              @"difficulty",
   ////                                               [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
    ////                                              @"level", nil]];

  }
  else{
    PlayInterfaceButtonSound(Sound_ButtonFailure());
    ////[Tracking trackEvent:@"player" action:@"zoomin" label:@"failure" value:0];
  }
}  
- (IBAction)zoomMapOut {
  if (zoom_overhead_map_out()) {
    PlayInterfaceButtonSound(Sound_ButtonSuccess());
    ////[Tracking trackEvent:@"player" action:@"zoomout" label:@"success" value:0];
    ////[Tracking tagEvent:@"zoomout" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
    ////                                              @"difficulty",
    ////                                              [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
    ////                                              @"level", nil]];

  }
  else{
    PlayInterfaceButtonSound(Sound_ButtonFailure());
    ////[Tracking trackEvent:@"player" action:@"zoomout" label:@"failure" value:0];
  }
}  


#pragma mark -
#pragma mark View Controller Methods


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
  MLog ( @"AUTOROTATE!\n" );


	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight
          || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
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
