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
#include "XML_Loader_SDL.h"
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
  return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

-(void)checkPurchases {

  BOOL isDirectory;
  BOOL haveTTEP = [[NSFileManager defaultManager] 
                   fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", [self purchasesDirectory], TTEP_FILENAME]
                   isDirectory:&isDirectory];
  BOOL haveVidmaster = [[NSFileManager defaultManager] 
                        fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", [self purchasesDirectory], VIDMASTER_MODE_FILENAME]
                        isDirectory:&isDirectory];
  
  MLog ( @"haveTTEP: %@ haveVidmaster: %@", haveTTEP, haveVidmaster );
  
  // Do something about it
  [[NSUserDefaults standardUserDefaults] setBool:haveVidmaster forKey:kCheatsEnabled];
  
  NSString *dataDir = [[AlephOneAppDelegate sharedAppDelegate] getDataDirectory];
  NSString * pathToMML;
  XML_Loader_SDL loader;
  if ( haveTTEP ) {
    // Load the new textures...
    pathToMML = [NSString stringWithFormat:@"%@/%@/TTEP-%@/TTEP.mml",
                 dataDir,
                 [AlephOneAppDelegate sharedAppDelegate].scenario.path,
                 SCENARIO_DESIGNATION];
  } else {
    pathToMML = [NSString stringWithFormat:@"%@/%@/StandardTextures-%@/StandardTextures.mml",
                 dataDir,
                 [AlephOneAppDelegate sharedAppDelegate].scenario.path,
                 SCENARIO_DESIGNATION];
  }
  FileSpecifier file ( (char*)[pathToMML UTF8String] );
  loader.ParseFile(file);
}
  
  
#pragma mark -
#pragma mark StoreFrontDelegate

-(void)productPurchased:(UAProduct*) product {
  MLog(@"[StoreFrontDelegate] Purchased: %@ -- %@", product.productIdentifier, product.title);
  [self checkPurchases];
}

-(void)storeFrontDidHide {
  MLog(@"[StoreFrontDelegate] StoreFront quit, do something with content");
}

-(void)storeFrontWillHide {
  MLog(@"[StoreFrontDelegate] StoreFront will hide");
  [self checkPurchases];
}

- (void)productsDownloadProgress:(float)progress count:(int)count {
  MLog(@"[StoreFrontDelegate] productsDownloadProgress: %f count: %d", progress, count);
  if (count == 0) {
    MLog(@"Downloads complete");
    [self checkPurchases];
  }
}


/*
+ (void)ReParse {
 // Unload the collections, the reparse the file.   
 void unload_all_collections(

 XML_Loader_SDL loader;
  // Construct full path name
  FileSpecifier file_name = dir + i->name;
  
  // Parse file
  ParseFile(file_name);
*/  

@end
