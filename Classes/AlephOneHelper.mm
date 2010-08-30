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

NSString *dataDir;

char* getDataDir() {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  dataDir = [paths objectAtIndex:0];
  // dataDir = [[NSBundle mainBundle] resourcePath];
  dataDir = [dataDir stringByAppendingString:@"/M1A1/"];
  return (char*)[dataDir UTF8String];
  
}


char* getLocalDataDir() {
  NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  return (char*)[docsDir UTF8String];
}

void helperBringUpHUD () {
  [[GameViewController sharedInstance] bringUpHUD];
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

int helperChooseSaveGame ( FileSpecifier &saved_game ) {
  return [[GameViewController sharedInstance] chooseSaveGame:&saved_game];
}


extern "C" void setOpenGLView ( SDL_uikitopenglview* view ) {
  // DJB
  // Construct the Game view controller
  // GameViewController *game = [GameViewController createNewSharedInstance];
  GameViewController *game = [GameViewController sharedInstance];
  
  [game setOpenGLView:view];
  
}