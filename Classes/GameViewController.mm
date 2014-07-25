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
#import "Achievements.h"
#include "FileHandler.h"
#import "Tracking.h"
#import "FloatingTriggerHUDViewController.h"
#import "AlephOneHelper.h"

extern float DifficultyMultiplier[];

// Useful functions
extern bool save_game(void);
extern "C" void setOpenGLView ( SDL_uikitopenglview* view );

// For cheats
#include "game_window.h"
extern void AddItemsToPlayer(short ItemType, short MaxNumber);
extern void AddOneItemToPlayer(short ItemType, short MaxNumber);


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
  
    struct player_data *player= get_player_data(player_index);
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
@synthesize previousWeaponButton, nextWeaponButton;
@synthesize filmView, filmViewController;
@synthesize controlsOverviewView, controlsOverviewGesture;
@synthesize zoomInButton, zoomOutButton;
@synthesize replacementMenuView;
@synthesize purchaseViewController, purchaseView, aboutView;
@synthesize saveFilmButton, loadFilmButton;
@synthesize HUDViewController;
@synthesize reticule, bungieAerospaceImageView, episodeImageView, logoView, waitingImageView, episodeLoadingImageView;
@synthesize HUDTouchViewController, HUDJoypadViewController;
@synthesize leaderboardButton, achievementsButton;

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
  
  // Bogus reticule
  currentReticleImage = -1000;
  
  self.saveGameViewController = [[SaveGameViewController alloc] initWithNibName:@"SaveGameViewController" bundle:nil];
  self.saveGameViewController.view;
  MLog ( @"Save Game View: %@", self.saveGameViewController.view );
  // Since the SaveGameViewController was initialized from a nib, add it's view to the proper place
  [self.loadGameView addSubview:self.saveGameViewController.uiView];
  
  self.progressViewController = [[ProgressViewController alloc] initWithNibName:@"ProgressViewController" bundle:[NSBundle mainBundle]];
  [self.progressViewController view];
  [self.progressViewController mainView];
  [self.progressView addSubview:self.progressViewController.mainView];
  // self.progressView.hidden = YES;
  
  self.preferencesViewController = [[PreferencesViewController alloc] initWithNibName:@"PreferencesViewController" bundle:[NSBundle mainBundle]];
  [self.preferencesViewController view];
  MLog ( @"self.preferencesViewController.view = %@", self.preferencesViewController.view);
  [self.preferencesView addSubview:self.preferencesViewController.view];
  
  self.helpViewController = [[HelpViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
  [self.helpView addSubview:self.helpViewController.view];
  
  self.pauseViewController = [[PauseViewController alloc] initWithNibName:@"PauseViewController" bundle:[NSBundle mainBundle]];
  [self.pauseViewController view];
  [self.pauseView addSubview:self.pauseViewController.view];
  
  self.newGameViewController = [[NewGameViewController alloc] initWithNibName:@"NewGameViewController" bundle:[NSBundle mainBundle]];
  [self.newGameViewController view];
  [self.newGameView addSubview:self.newGameViewController.view];
  
  self.filmViewController = [[FilmViewController alloc] initWithNibName:@"FilmViewController" bundle:[NSBundle mainBundle]];
  [self.filmViewController view];
  [self.filmViewController enclosingView];
  [self.filmView addSubview:self.filmViewController.enclosingView];
  
  self.purchaseViewController = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:[NSBundle mainBundle]];
  [self.purchaseViewController view];
  [self.purchaseView addSubview:self.purchaseViewController.view];
    
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
                             self.purchaseView,
                             self.aboutView,
                             nil] autorelease];
  for ( UIView *v in viewList ) {
    v.hidden = YES;
  }
  
#if defined(A1DEBUG)
  self.saveFilmButton.hidden = NO;
  self.loadFilmButton.hidden = NO;
  // joyPad = [[JoyPad alloc] init];

#endif
  
#if SCENARIO == 3
  self.leaderboardButton.hidden = YES;
  self.achievementsButton.hidden = YES;
#endif
  
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
#pragma mark Debugging info
- (IBAction)sendDebugInfo:(id)sender {
  MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
  controller.mailComposeDelegate = self;
  [controller setSubject:@"Marathon debugging information"];
  NSMutableString* buffer = [NSMutableString string];
  [buffer appendFormat:@"Running on iPad: %@\n", [[AlephOneAppDelegate sharedAppDelegate] runningOniPad] ? @"YES" : @"NO" ];
  [buffer appendFormat:@"Retina display: %@\n", helperRetinaDisplay() ? @"YES" : @"NO"];
  [buffer appendFormat:@"Screen dimensions: %@\n", NSStringFromCGRect([[UIScreen mainScreen] bounds])];
  [buffer appendFormat:@"View dimensions: %@\n", NSStringFromCGRect([viewGL bounds])];
  [buffer appendFormat:@"Scale factor: %f\n", [[UIScreen mainScreen] scale]];
  [buffer appendFormat:@"GL Dimensions: %d,%d\n", helperOpenGLWidth(), helperOpenGLHeight()];
  [buffer appendFormat:@"GL Version: %d\n", getOpenGLESVersion()];
  [buffer appendFormat:@"-----\n"];
  [buffer appendFormat:@"Engine screen size: %d,%d\n", alephone::Screen::instance()->width(), alephone::Screen::instance()->height()];
  [buffer appendFormat:@"Engine window size: %d,%d\n", alephone::Screen::instance()->window_width(), alephone::Screen::instance()->window_height()];
  SDL_Rect rect;
  rect = alephone::Screen::instance()->view_rect();
  [buffer appendFormat:@"Engine viewRect offset: %d,%d size: %d,%d\n", rect.x, rect.y, rect.w, rect.h];
  rect = alephone::Screen::instance()->hud_rect();
  [buffer appendFormat:@"Engine hudRect offset: %d,%d size: %d,%d\n", rect.x, rect.y, rect.w, rect.h];
  rect = alephone::Screen::instance()->window_rect();
  [buffer appendFormat:@"Engine windowRect offset: %d,%d size: %d,%d\n", rect.x, rect.y, rect.w, rect.h];
  [buffer appendFormat:@"Modes\n"];
  std::vector<std::pair<int, int> > modes = alephone::Screen::instance()->GetModes();
  for ( int i = 0; i < modes.size(); ++i ) {
    [buffer appendFormat:@"\t%d, %d\n", modes[i].first, modes[i].second];
  }
  
  [buffer appendFormat:@"-----\nScreenMode:\n"];

  [buffer appendFormat:@"HudScale Level: %d\n", graphics_preferences->screen_mode.hud_scale_level];
  [buffer appendFormat:@"Width: %d\n", graphics_preferences->screen_mode.width];
  [buffer appendFormat:@"Height: %d\n", graphics_preferences->screen_mode.height];
  

  
  
  [controller setMessageBody:buffer isHTML:NO];
  [controller setToRecipients:[NSArray arrayWithObject:@"daniel.blezek@gmail.com"]];
  if (controller) [self presentModalViewController:controller animated:YES];
  [controller release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
  if (result == MFMailComposeResultSent) {
    NSLog(@"It's away!");
  }
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Game control

- (void)closeEvent {
  switch ( mode ) {
    case MenuMode:
      [Tracking trackPageview:@"/menu"];
      [Tracking tagEvent:@"menu"];
      break;
    case CutSceneMode:
      [Tracking trackPageview:@"/cutscene"];
      [Tracking tagEvent:@"cutsecene"];
      break;
    case AutoMapMode:
      [Tracking trackPageview:@"/automap"];
      [Tracking tagEvent:@"automap"];
      break;
    case DeadMode:
      [Tracking trackPageview:@"/dead"];
      [Tracking tagEvent:@"dead"];
     break;
    case GameMode:
    default:
      [Tracking trackPageview:@"/game"];
      [Tracking tagEvent:@"game"];
      break;
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
  [Tracking trackPageview:@"/new"];
  [self.newGameViewController appear];
  self.newGameView.hidden = NO;
  self.currentSavedGame = nil;
  [self zeroStats];
}

- (IBAction)beginGame {
  haveNewGamePreferencesBeenSet = YES;
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
  [Tracking trackPageview:[NSString stringWithFormat:@"/new/%@/%d", [Statistics difficultyToString:player_preferences->difficulty_level], dynamic_world->current_level_number]];
  [Tracking tagEvent:@"startup" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
                                                @"difficulty",
                                                [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
                                                @"level", nil]];

  [self cancelNewGame];
  // [self performSelector:@selector(cancelNewGame) withObject:nil afterDelay:0.0];
  
  // Start the new game for real!
    [[AlephOneAppDelegate sharedAppDelegate].purchases checkPurchases];

  
  // New menus
  do_menu_item_command(mInterface, iNewGame, false);
#if defined(A1DEBUG)
  [self shieldCheat:nil];
  [self ammoCheat:nil];
  [self weaponsCheat:nil];
#endif

}

- (IBAction)cancelNewGame {
  [self closeEvent];
  [self.newGameView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.3];
  [self.newGameViewController disappear];
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
  [Tracking trackEvent:@"player" action:@"death" label:@"" value:0];
  [Tracking tagEvent:@"died" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
                                            @"difficulty",
                                            [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
                                            @"level", nil]];

  mode = DeadMode;
  self.hud.hidden = YES;
  self.HUDViewController.view.hidden = YES;
  
  self.restartView.hidden = NO;
  self.restartView.alpha = 0.6;
  [UIView animateWithDuration:2.0 animations:^{
    self.restartView.alpha = 0.8;
  }];
  /*
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:2.0];
  self.restartView.alpha = 0.8;
  [UIView commitAnimations];
   */
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
  
  /*
  if ( player_controlling_game() && [[NSUserDefaults standardUserDefaults] boolForKey:kCrosshairs] ) {
    Crosshairs_SetActive(true);
  } else {
   Crosshairs_SetActive(false);
  }
   */
  Crosshairs_SetActive(false);
  self.hud.alpha = 1.0;
  self.hud.hidden = NO;
  self.HUDViewController.view.hidden = NO;

  CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
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
  
  if ( self.HUDViewController == nil ) {
    [self configureHUD:nil];
  }

  NSMutableArray* views = [NSMutableArray arrayWithArray:[self.hud subviews]];
  [views addObjectsFromArray:[self.HUDViewController.view subviews]];

  for ( UIView *v in views ) {
    // [self.hud.layer addAnimation:group forKey:nil];
    if ( v == self.savedGameMessage || v.tag == 400 || v == self.HUDViewController.view) { continue; }
    v.hidden = NO;
    if ( showAllControls ) {
      [v.layer addAnimation:group forKey:nil];
    } else {
      if ( v == self.pause ) {
        [v.layer addAnimation:group forKey:nil];
      } else {
        v.hidden = YES;
      }
    }
  }
  
  if ( showControlsOverview ) {
    [self performSelector:@selector(bringUpControlsOverview) withObject:nil afterDelay:0.0];
  }
  
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
  
  if (get_entry_points(levels, AllPlayableLevels)) {
    // Figure out where we are
    for ( size_t idx = 0; idx < levels.size(); idx++ ) {
      if ( strcmp ( static_world->level_name, levels[idx].level_name ) == 0 ) {
        // OK, we are leaving this level so give the player some credit
        if ( idx < NumberOfLevels ) {
          
          // We are leaving level idx...
          [statistics reportAchievementsLeavingLevel:idx];
          if ( !currentSavedGame.haveCheated ) {
#if SCENARIO==1
            switch (idx) {
              case 2:
                [Achievements reportAchievementNoPrefix:@"Arrival" progress:100];
                break;
              case 9:
                [Achievements reportAchievementNoPrefix:@"Counterattack" progress:100];
                break;
              case 11:
                [Achievements reportAchievementNoPrefix:@"Reprisal" progress:100];
                break;
              case 15:
                [Achievements reportAchievementNoPrefix:@"Durandal" progress:100];
                break;
              case 23:
                [Achievements reportAchievementNoPrefix:@"Pfhor" progress:100];
                break;
              case 26:
                [Achievements reportAchievementNoPrefix:@"Rebellion" progress:100];
                break;
            }
#endif
#if SCENARIO==2
            switch (idx) {
              case 3:
                [Achievements reportAchievementNoPrefix:@"Lhowon" progress:100];
                break;
              case 6:
                [Achievements reportAchievementNoPrefix:@"Volunteers" progress:100];
                break;
              case 9:
                [Achievements reportAchievementNoPrefix:@"Garrison" progress:100];
                break;
              case 13:
                [Achievements reportAchievementNoPrefix:@"M2Durandal" progress:100];
                break;
              case 18:
                [Achievements reportAchievementNoPrefix:@"Captured" progress:100];
                break;
              case 22:
                [Achievements reportAchievementNoPrefix:@"Blake" progress:100];
                break;
              case 25:
                [Achievements reportAchievementNoPrefix:@"Simulacrums" progress:100];
                break;
              case 28:
                [Achievements reportAchievementNoPrefix:@"SphtKr" progress:100];
                break;
            }
#endif
          }
        }
      }
    }
  }
  
  
  
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
  self.viewGL.userInteractionEnabled = NO;
  [self.view insertSubview:self.viewGL belowSubview:self.hud];
}

#pragma mark -
#pragma mark Pause actions
- (IBAction) resume:(id)sender {
  [self closeEvent];
  self.pauseView.hidden = YES;
  [self pause:sender];
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
  [Tracking trackPageview:@"/settings"];
  [self.preferencesViewController setupUI:mode==MenuMode];
  self.preferencesView.hidden = NO;
  [self.preferencesViewController appear];
}
 
- (IBAction) closePreferences:(id)sender {
    [self.preferencesView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5];
  [self.preferencesViewController disappear];
  [self closeEvent];
}

- (IBAction) help:(id)sender {
  [Tracking trackPageview:@"/help"];
  [self.helpViewController setupUI];
  self.helpView.hidden = NO;
  self.helpView.alpha = 0.0;
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5];
  self.helpView.alpha = 1.0;
  [UIView commitAnimations];
  
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
    self.HUDJoypadViewController = [[JoypadHUDViewController alloc] initWithNibName:@"JoypadHUDViewController" bundle:[NSBundle mainBundle]];
  }
  
  [self.HUDViewController.view removeFromSuperview];
  if ( HUDType == nil ) {
    self.HUDTouchViewController = [[BasicHUDViewController alloc] initWithNibName:@"BasicHUDViewController" bundle:[NSBundle mainBundle]];
    self.HUDViewController = self.HUDTouchViewController;
  } else {
    self.HUDViewController = self.HUDJoypadViewController;
  }
  [self.hud insertSubview:self.HUDViewController.view belowSubview:self.pause];
  

}
- (IBAction) initiateJoypad:(id)sender {
  [self configureHUD:@"JoypadHUDViewController"];
  [((JoypadHUDViewController*) self.HUDViewController) connectToDevice];
}
- (IBAction) cancelJoypad:(id)sender {
  [self configureHUD:nil];
}

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
  [Tracking trackPageview:@"/load"];
}

- (IBAction) gameChosen:(SavedGame*)game {
  [self performSelector:@selector(chooseSaveGameCanceled) withObject:nil afterDelay:0.0];

  MLog ( @"Current world ticks %d", dynamic_world->tick_count );
  self.currentSavedGame = game;
  int sessions = game.numberOfSessions.intValue + 1;
  game.numberOfSessions = [NSNumber numberWithInt:sessions];
  [game.managedObjectContext save:nil];

  // load the HD textures if needed
  [[AlephOneAppDelegate sharedAppDelegate].purchases checkPurchases];

  MLog (@"Loading game: %@", game.filename );
  FileSpecifier FileToLoad ( (char*)[[self.saveGameViewController fullPath:game.filename] UTF8String] );
  load_and_start_game(FileToLoad);
  [Tracking trackPageview:[NSString stringWithFormat:@"/load/%@/%d", [Statistics difficultyToString:player_preferences->difficulty_level], dynamic_world->current_level_number]]; 

  [Tracking tagEvent:@"load" attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [Statistics difficultyToString:player_preferences->difficulty_level],
                                         @"difficulty",
                                         [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
                                         @"level",
                                        nil]]; 
MLog ( @"Restored game in position %d, %d", local_player->location.x, local_player->location.y );
  
}

- (IBAction) chooseSaveGameCanceled {
  [self closeEvent];
  [self.saveGameViewController disappear];
  [self.loadGameView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5];
}

extern SDL_Surface *draw_surface;

- (IBAction)saveGame {
  if ( self.currentSavedGame == nil ) {
    self.currentSavedGame = [self.saveGameViewController createNewGameFile];
  }
  [Tracking trackEvent:@"player" action:@"save" label:@"" value:0];
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
  SDL_SaveBMP ( map, (char*)[[self.saveGameViewController fullPath:self.currentSavedGame.mapFilename] UTF8String] );
  SDL_FreeSurface ( map );
  
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
  [statistics reportAchievementsForSaveGame];
  
  game.scenario = [AlephOneAppDelegate sharedAppDelegate].scenario;
  [[AlephOneAppDelegate sharedAppDelegate].scenario addSavedGamesObject:game];
  
  MLog ( @"Saving game to %@", self.currentSavedGame.filename); 
  FileSpecifier file ( (char*)[[self.saveGameViewController fullPath:self.currentSavedGame.filename] UTF8String] );
  save_game_file(file);
  
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
  [Tracking trackPageview:@"/film"];
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
  [Tracking trackPageview:@"/film/load"];
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
      [Tracking trackEvent:@"player" action:@"firsthelp" label:@"no" value:0];
    } else {
      [Tracking trackEvent:@"player" action:@"firsthelp" label:@"yes" value:0];
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
  self.logoView.hidden = YES;
  self.episodeImageView.image = nil;
  self.bungieAerospaceImageView.image = nil;
  self.splashView.image = nil;

  self.replacementMenuView.hidden = NO;
}

- (IBAction)menuHideReplacementMenu {
  self.replacementMenuView.hidden = YES;
}

- (IBAction)menuNewGame {
  [self PlayInterfaceButtonSound];
  [self newGame];
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
  [Tracking trackPageview:@"/store"];
  // Recommended way to present StoreFront. Alternatively you can open to a specific product detail.
  //[UAStoreFront displayStoreFront:self withProductID:@"oxygen34"];
  /*
  [UAStoreFront displayStoreFront:self animated:YES];
  
  // Specify the sorting of the list of products.
  [UAStoreFront setOrderBy:UAContentsDisplayOrderPrice ascending:YES];
  */
  
  self.purchaseView.hidden = NO;
  [self.purchaseViewController openDoors];
  [self.purchaseViewController appear];
}
- (IBAction)cancelStore {
  [self PlayInterfaceButtonSound];
  [self closeEvent];
  [self.purchaseView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5];
  [self.purchaseViewController disappear];
}

- (IBAction)menuAbout {
  [self PlayInterfaceButtonSound];
  [Tracking trackPageview:@"/about"];
  CAAnimation *group = [Effects appearAnimation];
  for ( UIView *v in self.aboutView.subviews ) {
    [v.layer removeAllAnimations];
    [v.layer addAnimation:group forKey:@"Appear"];
  }
  self.aboutView.hidden = NO;
}

- (IBAction)cancelAbout {
  [self PlayInterfaceButtonSound];
  [self closeEvent];
  CAAnimation *group = [Effects disappearAnimation];
  for ( UIView *v in self.aboutView.subviews ) {
    [v.layer removeAllAnimations];
    [v.layer addAnimation:group forKey:nil];
  }
  [self.aboutView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5];
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

#pragma mark - Reticule
- (void)updateReticule:(int)index {
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
    self.reticule.image = [UIImage imageNamed:[reticuleImageNames objectAtIndex:index]];
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
  

- (IBAction)pause:(id)from {
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
    [Tracking trackPageview:@"/pause"];
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

#pragma mark -
#pragma mark Achievements
- (void) gameFinished {
  // Need to do much more than this...
  [Achievements reportAchievement:Achievement_Marathon progress:100.0];
  [Tracking trackEvent:@"player" action:@"finished" label:[Statistics difficultyToString:player_preferences->difficulty_level] value:0];
  [Tracking tagEvent:@"finished" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
                                                @"difficulty", nil]];

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
#pragma mark GameKit
// Achievements and leader boards
- (IBAction)displayLeaderboard:(id)sender {
  if ( ![GKLocalPlayer localPlayer].isAuthenticated ) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not logged in"
                                                    message:@"You are not logged into GameCenter, so I can't show the Leaderboards"
                                                   delegate:nil
                                          cancelButtonTitle:@"Bummer"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
      return;
  }

  GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
  if (leaderboardController != nil) {
      leaderboardController.leaderboardDelegate = self;
      [self presentModalViewController:leaderboardController animated: YES];
  }
}
- (IBAction)displayAchievements:(id)sender {
  if ( ![GKLocalPlayer localPlayer].isAuthenticated ) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not logged in"
                                                    message:@"You are not logged into GameCenter, so I can't show your Achievements"
                                                   delegate:nil
                                          cancelButtonTitle:@"Bummer"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
      return;
  }
  GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
  if (achievements != nil) {
    achievements.achievementDelegate = self;
    [self presentModalViewController: achievements animated: YES];
  }
  [achievements release];
}
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
  [self dismissModalViewControllerAnimated:YES];
}
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
  [self dismissModalViewControllerAnimated:YES];
}




#pragma mark -
#pragma mark Cheats

- (IBAction)shieldCheat:(id)sender {
  [self PlayInterfaceButtonSound];

  // [self invincibilityCheat:sender];
  [Tracking trackEvent:@"player" action:@"cheat" label:@"shield" value:dynamic_world->current_level_number];
  [Tracking tagEvent:@"shieldCheat" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
                                            @"difficulty",
                                            [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
                                            @"level", nil]];

  local_player->suit_energy= MAX(local_player->suit_energy, 3*PLAYER_MAXIMUM_SUIT_ENERGY);
  local_player->suit_oxygen = MAX ( local_player->suit_oxygen, PLAYER_MAXIMUM_SUIT_OXYGEN );
  mark_shield_display_as_dirty();  
  currentSavedGame.haveCheated = [NSNumber numberWithBool:YES];
}

- (IBAction)invincibilityCheat:(id)sender {
  [Tracking trackEvent:@"player" action:@"cheat" label:@"invincibility" value:dynamic_world->current_level_number];
  [Tracking tagEvent:@"invincibilityCheat" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
                                                @"difficulty",
                                                [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
                                                @"level", nil]];
  process_player_powerup(local_player_index, _i_invincibility_powerup);
  // process_player_powerup(local_player_index, _i_infravision_powerup );
  currentSavedGame.haveCheated = [NSNumber numberWithBool:YES];
}

- (IBAction)saveCheat:(id)sender {
  [self PlayInterfaceButtonSound];

  [Tracking trackEvent:@"player" action:@"cheat" label:@"save" value:dynamic_world->current_level_number];
  [Tracking tagEvent:@"saveCheat" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
                                              @"difficulty",
                                              [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
                                              @"level", nil]];


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
  if ( currentSavedGame.haveCheated ) { return; }
  switch (itemType) {
    case _i_smg:
      [Achievements reportAchievement:@"SMG" progress:100.0];
      break;
    case _i_assault_rifle :
      [Achievements reportAchievement:@"AssaultRifle" progress:100.0];
      break;
    case _i_magnum:
      [Achievements reportAchievement:@"Pistol" progress:100.0];
      break;
    case _i_missile_launcher:
      [Achievements reportAchievement:@"MissileLauncherItem" progress:100.0];
      break;
    case _i_flamethrower:
      [Achievements reportAchievement:@"Flamethrower" progress:100.0];
      break;
    case _i_plasma_pistol:
      [Achievements reportAchievement:@"PlasmaPistol" progress:100.0];
      break;
    case _i_alien_shotgun:
      [Achievements reportAchievement:@"AlienShotgun" progress:100.0];
      break;
    case _i_shotgun:
      [Achievements reportAchievement:@"Shotgun" progress:100.0];
      break;
  }
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
  [Tracking trackEvent:@"player" action:@"cheat" label:@"ammo" value:dynamic_world->current_level_number];
  [Tracking tagEvent:@"ammoCheat" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
                                                @"difficulty",
                                                [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
                                                @"level", nil]];

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
  [Tracking trackEvent:@"player" action:@"cheat" label:@"weapons" value:dynamic_world->current_level_number];
  [Tracking tagEvent:@"weaponsCheat" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
                                                @"difficulty",
                                                [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
                                                @"level", nil]];

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
      [displayLink setFrameInterval:animationFrameInterval];
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
    // Do some house keeping here
    
    if (world_view->overhead_map_active) {
        self.zoomInButton.hidden = NO;
        self.zoomOutButton.hidden = NO;
    } else {
        self.zoomInButton.hidden = YES;
        self.zoomOutButton.hidden = YES;
    }
    [self updateReticule:get_player_desired_weapon(current_player_index)];
    if ( get_game_state() == _display_main_menu && ( mode == MenuMode || mode == CutSceneMode ) ) {
        [self menuShowReplacementMenu];
        mode = MenuMode;
    }
    // Causing a bug, always dim
    // [self.HUDViewController dimActionKey:0];
    if ( mode == GameMode ) {
        short target_type, object_index;
        object_index = localFindActionTarget(current_player_index, MAXIMUM_ACTIVATION_RANGE, &target_type);
        if ( NONE == object_index ) {
            [self.HUDViewController dimActionKey];
        } else {
            [self.HUDViewController lightActionKeyWithTarget:target_type objectIndex:object_index];    
        }
    }
    
    if ( !inMainLoop ) {
        inMainLoop = YES;
        AlephOneMainLoop();
        inMainLoop = NO;
    }
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
  [Tracking trackEvent:@"player" action:@"inventory" label:@"" value:0];
  [Tracking tagEvent:@"inventory" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
                                                @"difficulty",
                                                [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
                                                @"level", nil]];

}

- (IBAction)zoomMapIn {
  if (zoom_overhead_map_in()) {
    PlayInterfaceButtonSound(Sound_ButtonSuccess());
    [Tracking trackEvent:@"player" action:@"zoomin" label:@"success" value:0];
    [Tracking tagEvent:@"zoomin" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
                                                  @"difficulty",
                                                  [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
                                                  @"level", nil]];

  }
  else{
    PlayInterfaceButtonSound(Sound_ButtonFailure());
    [Tracking trackEvent:@"player" action:@"zoomin" label:@"failure" value:0];
  }
}  
- (IBAction)zoomMapOut {
  if (zoom_overhead_map_out()) {
    PlayInterfaceButtonSound(Sound_ButtonSuccess());
    [Tracking trackEvent:@"player" action:@"zoomout" label:@"success" value:0];
    [Tracking tagEvent:@"zoomout" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[Statistics difficultyToString:player_preferences->difficulty_level],
                                                  @"difficulty",
                                                  [NSString stringWithFormat:@"%d", dynamic_world->current_level_number],
                                                  @"level", nil]];

  }
  else{
    PlayInterfaceButtonSound(Sound_ButtonFailure());
    [Tracking trackEvent:@"player" action:@"zoomout" label:@"failure" value:0];
  }
}  


#pragma mark -
#pragma mark View Controller Methods


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
  MLog ( @"AUTOROTATE!!!!!!!!!\n\n\n\n" );


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
