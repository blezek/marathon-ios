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


#include "cseries.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "shell.h"
#include "render.h"
#include "interface.h"
#include "collection_definition.h"
#include "screen.h"
#include "game_errors.h"
#include "FileHandler.h"
#include "progress.h"

#include "map.h"

#ifdef HAVE_OPENGL
// LP addition: OpenGL support
#include "OGL_Render.h"
#include "OGL_LoadScreen.h"
#endif

// LP addition: infravision XML setup needs colors
#include "ColorParser.h"

#include "Packing.h"
#include "SW_Texture_Extras.h"

#include <SDL_rwops.h>
#include <memory>
#include "OGL_Textures.h"
void dumpTextures() {
  return;
  // Build all possible shape descriptors
  shape_descriptor texture;
  for ( int collection = 0; collection < 32; collection++ ) {
    for ( int shape = 0; shape < MAXIMUM_SHAPES_PER_COLLECTION; shape++ ) {
      for ( int clut = 0; clut < MAXIMUM_CLUTS_PER_COLLECTION; clut++ ) {
        
        texture = BUILD_DESCRIPTOR(BUILD_COLLECTION(collection, clut), shape);
  
  TextureManager TMgr;
  TMgr.ShapeDesc = texture;
  get_shape_bitmap_and_shading_table(
                                     TMgr.ShapeDesc,
                                     &TMgr.Texture,
                                     &TMgr.ShadingTables,
                                      _shading_normal);
  if (!TMgr.Texture) {
    return;
  }
  
  TMgr.IsShadeless = false;
  
  int16 TMgr_TransferMode = _textured_transfer;
  TMgr.TransferMode = TMgr_TransferMode;
  TMgr.TransferData = 0;
    
  // After all this setting up, now use it!
  TMgr.Setup();
      }
    }
  }
}
