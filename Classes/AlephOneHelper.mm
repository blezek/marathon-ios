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
#include <ifaddrs.h>
#include <arpa/inet.h>
#include "computer_interface.h" //Used for player in terminal check
#include "SDL_syswm.h"

#import "PreferencesViewController.h"


extern "C" {
  #include "SDL_mouse_c.h"
}

//raw movement deltas for gyro and misc. input
float iosDeltaX;
float iosDeltaY;

//raw movement deltas for touches.
float iosDeltaTouchX;
float iosDeltaTouchY;

  //Deltas intended for not the next frame, but the one after that.
float futureFrameDeltaX;
float futureFrameDeltaY;

//movement deltas as of start of new frame.
float thisFrameDX;
float thisFrameDY;

NSTimeInterval frameEndTime;

bool smartTriggerActive;
bool monsterOnLeft;
bool monsterOnRight;
bool canSmartFirePrimary;

bool shouldDoOk;

bool swapJoypadSticks;

bool shouldUseClassicRenderer;
bool shouldUseClassicTextures;
bool shouldUseClassicSprites;
bool shouldUseTransparentLiquids;
bool shouldUseBloom;
bool shouldUseExtraFOV;

int screenLongDimension;
int screenShortDimension;
float screenScale;

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

void* getLayerFromSDLWindow(SDL_Window *main_screen)
{
  SDL_SysWMinfo wmi;
  SDL_VERSION(&wmi.version);
  SDL_GetWindowWMInfo(main_screen, &wmi);

  NSLog(@"SDL UIView type: %@", NSStringFromClass([wmi.info.uikit.window.rootViewController.view class]));
  NSLog(@"SDL UIView Layer type: %@", NSStringFromClass([wmi.info.uikit.window.rootViewController.view.layer class]));
  NSLog(@"SDL UIView Layer size (h,w): %f, %f", wmi.info.uikit.window.rootViewController.view.layer.bounds.size.height, wmi.info.uikit.window.rootViewController.view.layer.bounds.size.width);

  if( [wmi.info.uikit.window.rootViewController.view.layer isKindOfClass:[CAMetalLayer class]] ) {
    NSLog(@"Setting CAMetalLayer size?");
    CAMetalLayer *mLayer = (CAMetalLayer*)wmi.info.uikit.window.rootViewController.view.layer;
    NSLog(@"CAMetalLayer drawable size (h,w): %f, %f", [mLayer drawableSize].height, [mLayer drawableSize].width);

  }
  
  return wmi.info.uikit.window.rootViewController.view.layer;
}

void setDefaultA1View()
{
  UIWindow *a1Window = [[UIApplication sharedApplication] keyWindow];
  UIView *a1View = [a1Window rootViewController].view;
  GameViewController *game = [GameViewController sharedInstance];
  [game setOpenGLView:(SDL_uikitopenglview*)a1View];
}


char* randomName31() {
  NSString *randomWords = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"web2a" ofType:@""] encoding:NSUTF8StringEncoding error:nil];
  NSArray *randomWordList = [randomWords componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  
  NSString *aRandomName = [randomWordList count] == 0 ? nil : randomWordList[arc4random_uniform([randomWordList count])];
  aRandomName = (aRandomName.length > 31 ) ? [aRandomName substringToIndex:31] : aRandomName; //Make sure it fits in PREFERENCES_NAME_LENGTH and MAX_NET_PLAYER_NAME_LENGTH
  
  return (char*)(aRandomName ? [aRandomName UTF8String] : [@"Bobert" UTF8String]);
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

char* getLocalTmpDir() {
  NSString *tmpDir = NSTemporaryDirectory();
  return (char*)[tmpDir UTF8String];
}

char* LANIP( char *prefix, char *suffix) {
  NSString *address = @"N/A";
  bool foundOurFavoriteInterface = NO;
  struct ifaddrs *interfaces = NULL;
  struct ifaddrs *temp_addr = NULL;
  int success = 0;
  // retrieve the current interfaces - returns 0 on success
  success = getifaddrs(&interfaces);
  if (success == 0) {
    // Loop through linked list of interfaces
    temp_addr = interfaces;
    while(temp_addr != NULL) {
      if(temp_addr->ifa_addr->sa_family == AF_INET) {
        // Check if interface is en0 which is the wifi connection on the iPhone
        if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
          // Get NSString from C String
          address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
          foundOurFavoriteInterface=YES;
        } else if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"bridge100"] && !foundOurFavoriteInterface) {
          address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
        }
        
      }
      
      temp_addr = temp_addr->ifa_next;
    }
  }
  // Free memory
  freeifaddrs(interfaces);
  
  return (char*)[[NSString stringWithFormat:@"%@%@%@", [NSString stringWithCString:prefix],address,[NSString stringWithCString:suffix]] UTF8String];
}

void  overrideSomeA1Prefs() {
  [PreferencesViewController setAlephOnePreferences:NO checkPurchases:YES]; //DCW write prefs; do this first in case this is the initial launch of the app and there is no prefs file on disk yet.
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

void display_net_game_stats_helper() {
  [[GameViewController sharedInstance] switchToSDLMenu];
  [[GameViewController sharedInstance] performSelectorOnMainThread:@selector(displayNetGameStatsCommand) withObject:nil waitUntilDone:NO];
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
                                                            NSLog(@"Sending chunk as input: %@" , chunk);
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

bool smoothMouselookPreference() {
  return [[NSUserDefaults standardUserDefaults] boolForKey:kSmoothMouselook];
}

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
void moveMouseRelativeAtInterval(float dx, float dy, double movedInterval)
{
  if ( movedInterval >= frameEndTime ) {
    futureFrameDeltaX+=dx;
    futureFrameDeltaY+=dy;
    //NSLog(@"Touches moved for next frame" );
  } else {
    iosDeltaTouchX+=dx;
    iosDeltaTouchY+=dy;
    //NSLog(@"Touches moved" );
  }
}

void moveMouseRelative(float dx, float dy)
{
  iosDeltaX+=dx;
  iosDeltaY+=dy;
  
  return;
}

void grabMovementDeltasForCurrentFrameAtInterval(double timeStamp) {
  
    //Calculate when this frame will end. It should be 1/30th of a second.
  frameEndTime = timeStamp + (1.0/30.0);
  
  thisFrameDX += iosDeltaX + iosDeltaTouchX;
  thisFrameDY += iosDeltaY + iosDeltaTouchY;
  
  iosDeltaX=0;
  iosDeltaY=0;
  iosDeltaTouchX=futureFrameDeltaX;
  iosDeltaTouchY=futureFrameDeltaY;
  futureFrameDeltaX = 0;
  futureFrameDeltaY = 0;
}

void slurpMouseDelta(float *dx, float *dy) {
  
  *dx=thisFrameDX;
  *dy=-thisFrameDY;
  
  thisFrameDX = 0;
  thisFrameDY = 0;
}

void helperGetMouseDelta ( int *dx, int *dy ) {
  // Get the mouse delta from the JoyPad HUD controller, if possible
  [[GameViewController sharedInstance].HUDViewController mouseDeltaX:dx deltaY:dy];
}

void clearSmartTrigger() {
  
  if(smartTriggerActive){
    //Stop firing!
    [[GameViewController sharedInstance] stopPrimaryFire];
  }
  smartTriggerActive=0;
  monsterOnLeft=0;
  monsterOnRight=0;
}
bool smartTriggerEngaged(){
  MLog(@"Smart trigger: %d", smartTriggerActive);
  return smartTriggerActive;
}
void monsterIsCentered () {
  
  if(canSmartFirePrimary)
  {
    smartTriggerActive = 1;
  }
  
  if (smartTriggerActive && canSmartFirePrimary){
    [[GameViewController sharedInstance] startPrimaryFire];
  }
  
  return;
}

void monsterIsOnLeft (){
  monsterOnLeft=YES;
}
void monsterIsOnRight (){
  monsterOnRight=YES;
}

bool isMonsterCentered (){
  return smartTriggerActive;
}
bool isMonsterOnLeft (){
  return monsterOnLeft;
}
bool isMonsterOnRight (){
  return monsterOnRight;
}

void setSmartFirePrimary(bool fire){
  canSmartFirePrimary=fire;
}

extern GLfloat helperPauseAlpha() {
  return [[GameViewController sharedInstance] getPauseAlpha];
}

void helperSetPreferences( int notify) {
  [PreferencesViewController setAlephOnePreferences:notify checkPurchases:YES];
}

bool getLocalPlayer () {
  return local_player;
}

float extraFieldOfView () {
  return shouldUseExtraFOV ? 20 : 0;
}

bool headBelowMedia () {
  
  if( !local_player ) {
    return 0;
  }
  
  return local_player->variables.flags&_HEAD_BELOW_MEDIA_BIT;
}

bool playerInTerminal () {
  return player_in_terminal_mode(local_player_index);
}

//Hide HUD for filming and screenshot purposes
bool shouldHideHud () {
  return 0;
}

void cacheInputPreferences() {
  swapJoypadSticks = [[NSUserDefaults standardUserDefaults] boolForKey:kSwapJoysticks];
}

bool shouldswapJoysticks() {
  return swapJoypadSticks;
}


void cacheRendererPreferences() {
  shouldUseClassicRenderer = [[NSUserDefaults standardUserDefaults] boolForKey:kUseClassicRenderer];
  shouldUseClassicTextures = [[NSUserDefaults standardUserDefaults] boolForKey:kUseClassicTextures];
  shouldUseClassicSprites = [[NSUserDefaults standardUserDefaults] boolForKey:kUseClassicSprites];

  cacheRendererQualityPreferences();
}

void cacheRendererQualityPreferences() {
  shouldUseBloom = [[NSUserDefaults standardUserDefaults] boolForKey:kUseBloom];
  shouldUseTransparentLiquids = [[NSUserDefaults standardUserDefaults] boolForKey:kUseTransparentLiquids];
  shouldUseExtraFOV = [[NSUserDefaults standardUserDefaults] boolForKey:kUseExtraFOV];
}

bool useClassicVisuals() {
  return shouldUseClassicRenderer;
}

bool useShaderRenderer() {
  return true; // From now on, alway use shader, even for classic style!
  //return !shouldUseClassicRenderer;
}
bool useShaderPostProcessing() {
  return shouldUseBloom;
}
  //Set to 1 for fast debugging, by lauching directly into last saved game.
bool fastStart () {
  return 0;
}

bool usingA1DEBUG () {
  #if defined(A1DEBUG)
    return 1;
  #endif
  
  return 0;
}

bool survivalMode () {
  return 0;
}

bool shouldAutoBot() {
  return 0;
}

void doOkInASec() {
  
  [[GameViewController sharedInstance] performSelector:@selector(setDialogOk) withObject:nil afterDelay:2];

}

void doOkOnNextDialog( bool ok ) {
  shouldDoOk = ok;
}

bool okOnNextDialog() {
  if(shouldDoOk) {
    shouldDoOk = 0;
    return 1;
  }
  return 0;
}

  //Do we ever want to allow double cliock actions?
  //Probable never, so tapping movepad doesn't trigger action.
bool shouldAllowDoubleClick () {
  return NO;
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
void helperCacheScreenDimension() {
  screenLongDimension = [AlephOneAppDelegate sharedAppDelegate].longScreenDimension ;
  screenShortDimension = [AlephOneAppDelegate sharedAppDelegate].shortScreenDimension;
  screenScale = [[UIScreen mainScreen] scale];
}

int helperLongScreenDimension() {
  if (screenLongDimension == 0) helperCacheScreenDimension();
  return screenLongDimension;
}

int helperShortScreenDimension() {
	if (screenShortDimension == 0) helperCacheScreenDimension();
  return screenShortDimension;
}

float helperScreenScale(){
  if (screenScale == 0) helperCacheScreenDimension();
  return screenScale;
}

