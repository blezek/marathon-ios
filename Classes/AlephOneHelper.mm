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

void helperSaveGame () {
  [[GameViewController sharedInstance] saveGame];
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

// Some calls defined in the interface.cpp
extern void force_system_colors(void);
extern bool choose_saved_game_to_load(FileSpecifier& File);
extern bool load_and_start_game(FileSpecifier& File);

void helperHandleLoadGame ( ) {
  
  [[GameViewController sharedInstance] chooseSaveGame];
  return;
  FileSpecifier FileToLoad;
  bool success= false;
  
  force_system_colors();
  show_cursor();       // JTP: Was hidden by force system colors
  if(choose_saved_game_to_load(FileToLoad)) {
    if(load_and_start_game(FileToLoad)) {
      success= true;
    }
  }
  
  if(!success) {
    hide_cursor();             // JTP: Will be shown when fade stops
    display_main_menu();
  }
  
  // return [[GameViewController sharedInstance] chooseSaveGame:&saved_game];
}


extern "C" void setOpenGLView ( SDL_uikitopenglview* view ) {
  // DJB
  // Construct the Game view controller
  // GameViewController *game = [GameViewController createNewSharedInstance];
  GameViewController *game = [GameViewController sharedInstance];
  
  [game setOpenGLView:view];
  
}