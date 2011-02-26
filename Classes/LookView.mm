//
//  LookView.mm
//  AlephOne
//
//  Created by Daniel Blezek on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LookView.h"
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
#include "interface.h"
#include "shell.h"
#include "preferences.h"
#include "mouse.h"
#include "player.h"
#include "key_definitions.h"
#include "tags.h"

#import "Prefs.h"

@implementation LookView
@synthesize primaryFire, secondaryFire;
@synthesize firstTouchTime, lastPrimaryFire;
- (void)viewDidLoad {
  firstTouch = nil;
  secondTouch = nil;
}

- (void)stopPrimaryFire {
  Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  key_map[primaryFire] = 0;
}
- (void)stopSecondaryFire {
  Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  key_map[secondaryFire] = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if ( firstTouch == nil ) {
    // grab the first
    firstTouch = [touches anyObject];
    self.firstTouchTime = [NSDate date];
  } else {
    secondTouch = [touches anyObject];
  }
  
  for ( UITouch *touch in [event touchesForView:self] ) {
    if ( touch == firstTouch ) {
      lastPanPoint = [touch locationInView:self];
    } else {
      if ( [[NSUserDefaults standardUserDefaults] boolForKey:kSecondTapShoots] ) {
        // start the second fire
        Uint8 *key_map = SDL_GetKeyboardState ( NULL );
        key_map[secondaryFire] = 1;
      }
    }
  }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  for ( UITouch *touch in touches ) {
    if ( touch == firstTouch ) {
      firstTouch = nil;
      if ( [[NSUserDefaults standardUserDefaults] boolForKey:kTapShoots] ) {
        // Check the time, fire 
        // MLog ( @"Might fire here");
        NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:self.firstTouchTime];
        self.firstTouchTime = nil;
        if ( delta < TapToShootDelta ) {
          Uint8 *key_map = SDL_GetKeyboardState ( NULL );
          key_map[primaryFire] = 1;
          [self performSelector:@selector(stopPrimaryFire) withObject:nil afterDelay:0.2];
        }
      }
    }
    if ( touch == secondTouch && [[NSUserDefaults standardUserDefaults] boolForKey:kSecondTapShoots] ) {
      secondTouch = nil;
      Uint8 *key_map = SDL_GetKeyboardState ( NULL );
      key_map[secondaryFire] = 0;
    }
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  // NSLog(@"Touches moved" );
  for ( UITouch *touch in [event touchesForView:self] ) {
    CGPoint currentPoint = [touch locationInView:self];
    int dx, dy;
    dx = currentPoint.x - lastPanPoint.x;
    dy = currentPoint.y - lastPanPoint.y;
    SDL_SendMouseMotion ( true, dx, dy );
    // NSLog(@"touches moved, sending delta" );
    lastPanPoint = currentPoint;
    break;
  }
}

- (void)dealloc {
  // Kill a warning
  (void)all_key_definitions;

    [super dealloc];
}


@end
