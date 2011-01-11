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
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  dataDir = [paths objectAtIndex:0];
  // dataDir = [[NSBundle mainBundle] resourcePath];
  dataDir = [NSString stringWithFormat:@"%@/%@/", dataDir, [AlephOneAppDelegate sharedAppDelegate].scenario.path];
  MLog ( @"DataDir: %@", dataDir );
  return (char*)[dataDir UTF8String];
  
}


char* getLocalDataDir() {
  NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  return (char*)[docsDir UTF8String];
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
bool helperNewGame () {
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

extern GLfloat helperPauseAlpha() {
  return [[GameViewController sharedInstance] getPauseAlpha];
}

void helperSetPreferences( bool notify) {
  [PreferencesViewController setAlephOnePreferences:notify];
}

short pRecord[128][2];
void helperNewProjectile( short projectile_index, short which_weapon, short which_trigger ) {
  if ( projectile_index >= 128 ) { return; };
  pRecord[projectile_index][0] = which_weapon;
  pRecord[projectile_index][1] = which_trigger;
}

extern player_weapon_data *get_player_weapon_data(const short player_index);
void helperProjectileHit ( short projectile_index ) {
  if ( projectile_index >= 128 ) { return; };
  player_weapon_data* weapon_data = get_player_weapon_data(local_player_index);
  short widx = pRecord[projectile_index][0];
  short tidx = pRecord[projectile_index][1];
  weapon_data->weapons[widx].triggers[tidx].shots_hit++;
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

