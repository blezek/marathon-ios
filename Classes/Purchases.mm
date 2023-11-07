//
//  Purchases.m
//  AlephOne
//
//  Created by Daniel Blezek on 2/19/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "Purchases.h"
#import "Prefs.h"
#import "Secrets.h"
//#include "XML_Loader_SDL.h"
#include "XML_ParseTreeRoot.h"
#import "AlephOneAppDelegate.h"
#import "GameViewController.h"

// Big wad of AlephOne headers
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
#include "player.h"
#include "tags.h"
#include "items.h"
#include "interface.h"
#import "game_wad.h"
#include "overhead_map.h"
#include "weapons.h"
#include "vbl.h"
#include "render.h"
#include "interface_menus.h"

@implementation Purchases

-(NSString*)purchasesDirectory {
  NSString* dir = [NSString stringWithFormat:@"%@/ua/downloads/",
                   [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
  return dir;
}

-(void)checkPurchases {
  BOOL haveTTEP = [[NSUserDefaults standardUserDefaults] boolForKey:kHaveTTEP];
  
  // Do something about it
  BOOL useTTEP = [[NSUserDefaults standardUserDefaults] boolForKey:kUseTTEP];
  
#if defined(A1DEBUG)
  // haveTTEP = YES;
#endif
  
  NSString *dataDir = [[AlephOneAppDelegate sharedAppDelegate] getDataDirectory];
  NSString * pathToMML;
  if ( haveTTEP && useTTEP ) {
    MLog ( @"Loading HD Textures" );
    // Load the new textures...
    pathToMML = [NSString stringWithFormat:@"%@/%@/TTEP-%@/TTEP.mml",
                 dataDir,
                 [AlephOneAppDelegate sharedAppDelegate].scenario.path,
                 SCENARIO_DESIGNATION];
  } else {
    MLog ( @"Loading SD Textures" );
    pathToMML = [NSString stringWithFormat:@"%@/%@/StandardTextures-%@/StandardTextures.mml",
                 dataDir,
                 [AlephOneAppDelegate sharedAppDelegate].scenario.path,
                 SCENARIO_DESIGNATION];
  }
  
  // Install the file
  
  // Create the Scripts directory
  NSString *scriptsDirectory = [NSString stringWithFormat:@"%@/Scripts/", 
                             [[AlephOneAppDelegate sharedAppDelegate] applicationDocumentsDirectory]];
  
  NSError *error = 0;
  [[NSFileManager defaultManager] createDirectoryAtPath:scriptsDirectory
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:&error];
  
  NSString* outputFile = [NSString stringWithFormat:@"%@/WallTextures.mml", scriptsDirectory];
  NSLog ( @"Creating saved scripts directory %@", scriptsDirectory );
  
  BOOL removeSuccessful = [[NSFileManager defaultManager] removeItemAtPath:outputFile error:&error];
  if ( !removeSuccessful ) {
    MLog ( @"Failed to remove old file: %@", error );
  }
  
  BOOL copySuccessful = [[NSFileManager defaultManager] copyItemAtPath:pathToMML toPath:outputFile error:&error];
  if ( !copySuccessful ) {
    MLog ( @"Failed to copy!" );
  }
  MLog ( @"Copied %@ to %@", pathToMML, outputFile );
  // Force a re-parse
  LoadBaseMMLScripts();
  // unload_all_collections();
  /*
   XML_Loader_SDL loader;
   FileSpecifier file ( (char*)[pathToMML UTF8String] );
   loader.CurrentElement = &RootParser;
   loader.ParseFile(file);
   */
}
  

@end
