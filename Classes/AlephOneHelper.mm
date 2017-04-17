//
//  AlephOneHelper.m
//  AlephOne
//
//  Created by Daniel Blezek on 5/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
#import "AlephOneHelper.h"
#include "interface.h"
#import "AlephOneAppDelegate.h"
#include "projectiles.h"
#include "player.h"
#import "Prefs.h"
#include "screen.h"

extern "C" {
  #include "SDL_mouse_c.h"
}

//DCW
float iosDeltaX;
float iosDeltaY;



NSString *dataDir;

void printGLError( const char* message ) {
  switch ( glGetError() ) {
  case GL_NO_ERROR: {
    break;
  }
  case GL_INVALID_ENUM: {
    MLog ( @"%s GL_INVALID_ENUM", message );
    break;
  }
  case GL_INVALID_VALUE: {
    MLog ( @"%s GL_INVALID_VALUE", message );
    break;
  }          
  case GL_INVALID_OPERATION: {
    MLog ( @"%s GL_INVALID_OPERATION", message );
    break;
  }          
  case GL_STACK_OVERFLOW: {
    MLog ( @"%s GL_STACK_OVERFLOW", message );
    break;
  }          
  case GL_STACK_UNDERFLOW: {
    MLog ( @"%s GL_STACK_UNDERFLOW", message );
    break;
  }          
  case GL_OUT_OF_MEMORY: {
    MLog ( @"%s GL_OUT_OF_MEMORY", message );
    break;
  }          
  }
}

char* getDataDir() {
  // NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  // dataDir = [paths objectAtIndex:0];
  dataDir = [[AlephOneAppDelegate sharedAppDelegate] getDataDirectory];
  dataDir = [NSString stringWithFormat:@"%@/%@/", dataDir, [AlephOneAppDelegate sharedAppDelegate].scenario.path];
  MLog ( @"DataDir: %@", dataDir );
  return (char*)[dataDir UTF8String];
  
}


char* getLocalDataDir() {
  NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  return (char*)[docsDir UTF8String];
}

char* getLocalPrefsDir() {
  NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  return (char*)[docsDir UTF8String];
}

void  setDefaultA1PrefsIfNeeded() {
  char temporary[256];
  getcstr(temporary, strFILENAMES, filenamePREFERENCES);
  
  NSString *A1DefaultPrefs = [NSString stringWithFormat:@"%s/%s", getDataDir(), temporary];
  NSString *A1TargetPrefs = [NSString stringWithFormat:@"%s/%s", getLocalPrefsDir(), temporary];

  //Copy fresh preferences into place. won't overwrite existing prefs.
    [[NSFileManager defaultManager] copyItemAtPath:A1DefaultPrefs toPath:A1TargetPrefs error:nil];
 }

void helperQuit() {
  MLog ( @"helperQuit()" );
  [[GameViewController sharedInstance] quitPressed];
}

void helperNetwork() {
  MLog ( @"helperNetwork()" );
  [[GameViewController sharedInstance] networkPressed];
}

void helperBringUpHUD () {
  [[GameViewController sharedInstance] bringUpHUD];
}

void helperSaveGame () {
  [[GameViewController sharedInstance] saveGame];
}

void helperDoPreferences() {
  [[GameViewController sharedInstance] gotoPreferences:nil];
}

int getOpenGLESVersion() {
  return [AlephOneAppDelegate sharedAppDelegate].OpenGLESVersion;
}


// Should we start a new game?
int helperNewGame () {
  if ( [GameViewController sharedInstance].haveNewGamePreferencesBeenSet ) {
    [GameViewController sharedInstance].haveNewGamePreferencesBeenSet = NO;
    return true;
  } else {
    // We need to handle some preferences here
    [[GameViewController sharedInstance] performSelector:@selector(newGame) withObject:nil afterDelay:0.01];
    return false;
  }
}

void helperPlayerKilled() {
  [[GameViewController sharedInstance] playerKilled];
}

void switchBackToGameView() {
  [[GameViewController sharedInstance] switchBackToGameView];
}

void gotoMenu() {
  [[GameViewController sharedInstance] gotoMenu:nil];
}

void switchToSDLMenu() {
  [[GameViewController sharedInstance] switchToSDLMenu];
}

//This is an iOS text input dialog, to replace the crappy SDL keyboard handling. It just simulates keystrokes, based on what the user enters.
void getSomeTextFromIOS(char *label, const char *currentText)  {

  NSString *currentNString = [NSString stringWithUTF8String:currentText];
  NSString *labelNSString=[NSString stringWithUTF8String:label];
  NSString *actionTitle=@"Done";
  NSString *messageText=nil;
  
  if( [labelNSString isEqualToString:@"Say:"]) {
    actionTitle = @"Say it";
    messageText = @"Sent a message to chat";
  }
  if( [labelNSString isEqualToString:@"Join address"]) {
    messageText = @"Enter the IP Address of the host you wish to connect to.";
  }
  
  
  
  UIAlertController* alert = [UIAlertController alertControllerWithTitle:labelNSString
                                                                 message:messageText
                                                          preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                          NSString *inputText=alert.textFields[0].text;
                                                          int length = [inputText length];
                                                          int chunksize = 10; //Arbitrary string chunk size
                                                          for(int i = 0; i < length; i+=chunksize) {
                                                            NSRange range = NSMakeRange(i, min(chunksize, length-i));
                                                            NSString *chunk=[inputText substringWithRange:range];
                                                            //Convert the first text field to a c string and copy it's data into a new text input event that gets fed into the dialog event loop.
                                                            SDL_Event event;
                                                            event.type = SDL_TEXTINPUT;
                                                            SDL_utf8strlcpy(event.text.text, [chunk cStringUsingEncoding:NSUTF8StringEncoding], SDL_arraysize(event.text.text));
                                                            SDL_PushEvent(&event);
                                                          }
                                                          //Simulate SDLK_KP_ENTER key pressed, (Because SDLK_RETURN gets wedged for some reason) in case this is a Say: box or something.
                                                          SDL_Event enter, unenter;
                                                          enter.type = SDL_KEYDOWN;
                                                          SDL_utf8strlcpy(enter.text.text, "E", SDL_arraysize(enter.text.text));
                                                          enter.key.keysym.sym=SDLK_KP_ENTER;
                                                          SDL_PushEvent(&enter);
                                                          unenter.type = SDL_KEYUP;
                                                          SDL_utf8strlcpy(unenter.text.text, "E", SDL_arraysize(unenter.text.text));
                                                          unenter.key.keysym.sym=SDLK_KP_ENTER;
                                                          SDL_PushEvent(&unenter);
                                                        }];
  UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                         //User cancelled, so send the same text as was sent in:
                                                         SDL_Event event;
                                                         event.type = SDL_TEXTINPUT;
                                                         SDL_utf8strlcpy(event.text.text, [currentNString cStringUsingEncoding:NSUTF8StringEncoding], SDL_arraysize(event.text.text));
                                                         SDL_PushEvent(&event);
                                                         
                                                         //Simulate SDLK_KP_ENTER key pressed, (Because SDLK_RETURN gets wedged for some reason) in case this is a Say: box or something.
                                                         SDL_Event enter, unenter;
                                                         enter.type = SDL_KEYDOWN;
                                                         SDL_utf8strlcpy(enter.text.text, "E", SDL_arraysize(enter.text.text));
                                                         enter.key.keysym.sym=SDLK_KP_ENTER;
                                                         SDL_PushEvent(&enter);
                                                         unenter.type = SDL_KEYUP;
                                                         SDL_utf8strlcpy(unenter.text.text, "E", SDL_arraysize(unenter.text.text));
                                                         unenter.key.keysym.sym=SDLK_KP_ENTER;
                                                         SDL_PushEvent(&unenter);
                                                       }];
  [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    //Set the text field to whatever the current text is:
    [textField setText:currentNString];
    
      //Pick a special keyboard type, if we want one.
    if( [labelNSString isEqualToString:@"Join address"])
      textField.keyboardType=UIKeyboardTypeDecimalPad;
    
  }];
  [alert addAction:defaultAction];
  [alert addAction:cancelAction];

  
  
  [[[[UIApplication sharedApplication] keyWindow] rootViewController]  presentViewController:alert animated:YES completion:nil];
  
}


void helperHideHUD() {
  [[GameViewController sharedInstance] hideHUD];
}

void helperBeginTeleportOut() {
  [[GameViewController sharedInstance] teleportOut];
}

void helperTeleportInLevel() {
  [[GameViewController sharedInstance] teleportInLevel];
}

void helperEpilog() {  
  [[GameViewController sharedInstance] epilog];
  pumpEvents();
}

void helperEndReplay() {
  [[GameViewController sharedInstance] endReplay];
  pumpEvents();
}

float helperGamma() {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  float g = [defaults floatForKey:kGamma];
  return g;
};

int helperAlwaysPlayIntro () {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL g = [defaults boolForKey:kAlwaysPlayIntro];
  if ( g ) {
    return 1;
  } else {
    return 0;
  }
};

int helperAutocenter () {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL g = [defaults boolForKey:kAutocenter];
  if ( g ) {
    return 1;
  } else {
    return 0;
  }
};

  //DCW
Uint8 fake_key_map[SDL_NUM_SCANCODES];
void setKey(SDL_Keycode key, bool down) {
  /*SDL_Event sdlevent;
  sdlevent.type = down?SDL_KEYDOWN:SDL_KEYUP;
  sdlevent.key.keysym.sym = key;
  
  SDL_PushEvent(&sdlevent);*/
  
  fake_key_map[key] = down;
}

//DCW
void moveMouseRelative(float dx, float dy)
{
    //DCW Amplify our input by 100 we don't lose as much precision in the int conversion below
    //DCW This must be de-amplified in mouse_idle() later on.
  //dx *= 100;
  //dy *= 100;
  
  float w, h;
  w = MainScreenWindowWidth();
  h = MainScreenWindowHeight();
  
  iosDeltaX+=dx;
  iosDeltaY+=dy;

  //SDL_SendMouseMotion (NULL, SDL_TOUCH_MOUSEID, true, dx + w/2.0, dy + h/2.0); //Movement is relative to center of screen
  
  return;
}

void slurpMouseDelta(float *dx, float *dy) {
  *dx=iosDeltaX;
  *dy=-iosDeltaY;
  iosDeltaX=0;
  iosDeltaY=0;
}

void helperGetMouseDelta ( int *dx, int *dy ) {
  // Get the mouse delta from the JoyPad HUD controller, if possible
  [[GameViewController sharedInstance].HUDViewController mouseDeltaX:dx deltaY:dy];
}



extern GLfloat helperPauseAlpha() {
  return [[GameViewController sharedInstance] getPauseAlpha];
}

void helperSetPreferences( int notify) {
  BOOL check = notify ? YES : NO;
  [PreferencesViewController setAlephOnePreferences:notify checkPurchases:check];
}

short pRecord[128][2];
void helperNewProjectile( short projectile_index, short which_weapon, short which_trigger ) {
  if ( projectile_index >= 128 ) { return; };
  pRecord[projectile_index][0] = which_weapon;
  pRecord[projectile_index][1] = which_trigger;
}

extern player_weapon_data *get_player_weapon_data(const short player_index);
void helperProjectileHit ( short projectile_index, int damage ) {
  if ( projectile_index >= 128 ) { return; };
  player_weapon_data* weapon_data = get_player_weapon_data(local_player_index);
  short widx = pRecord[projectile_index][0];
  short tidx = pRecord[projectile_index][1];
  weapon_data->weapons[widx].triggers[tidx].shots_hit++;
  [[GameViewController sharedInstance] projectileHit:widx withDamage:damage];
}

void helperProjectileKill ( short projectile_index ) {
  if ( projectile_index >= 128 ) { return; };
  short widx = pRecord[projectile_index][0];

  [[GameViewController sharedInstance] projectileKill:widx];
}

void helperGameFinished() {
  [[GameViewController sharedInstance] gameFinished];
}

void helperHandleLoadGame ( ) {
  [[GameViewController sharedInstance] chooseSaveGame];
  return;
}


extern "C" SDL_uikitopenglview* getOpenGLView() {
  GameViewController *game = [GameViewController sharedInstance];
  return game.viewGL;
}

extern "C" void setOpenGLView ( SDL_uikitopenglview* view ) {
  // DJB
  // Construct the Game view controller
  // GameViewController *game = [GameViewController createNewSharedInstance];
  GameViewController *game = [GameViewController sharedInstance];
  
  [game setOpenGLView:view];
  
}

void pumpEvents() {
  SInt32 result;
  do {
    // MoreEvents = [theRL runMode:currentMode beforeDate:future];
    result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE);
  } while(result == kCFRunLoopRunHandledSource);  
  
}

void helperSwitchWeapons ( int weapon ) {
  [[GameViewController sharedInstance] updateReticule:weapon];
}

void startProgress ( int t ) {
  [[GameViewController sharedInstance] startProgress:t];
}
void progressCallback ( int d ) {
  [[GameViewController sharedInstance] progressCallback:d];
}
void stopProgress() {
  [[GameViewController sharedInstance] stopProgress];
}

short helperGetEntryLevelNumber() {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults integerForKey:kEntryLevelNumber];
}

void helperHandleSaveFilm() {
  [[GameViewController sharedInstance] saveFilm];
}

void helperHandleLoadFilm() {
  [[GameViewController sharedInstance] chooseFilm];
}

extern void helperPickedUp ( short itemType ) {
  // picked something up
  MLog ( @"Picked something up");
  [[GameViewController sharedInstance] pickedUp:itemType];
}

// C linkage
extern "C" int helperRunningOniPad() {
  return [[AlephOneAppDelegate sharedAppDelegate] runningOniPad];
}
extern "C" int helperOpenGLWidth() {
  return [AlephOneAppDelegate sharedAppDelegate].oglWidth;
}
extern "C" int helperOpenGLHeight() {
  return [AlephOneAppDelegate sharedAppDelegate].oglHeight;
}
extern "C" int helperRetinaDisplay() {
  return [AlephOneAppDelegate sharedAppDelegate].retinaDisplay;
}

	//DCW
extern "C" int helperLongScreenDimension() {
  return [AlephOneAppDelegate sharedAppDelegate].longScreenDimension;
}
extern "C" int helperShortScreenDimension() {
	return [AlephOneAppDelegate sharedAppDelegate].shortScreenDimension;
}




