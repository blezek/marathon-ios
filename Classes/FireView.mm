//
//  FireView.mm
//  AlephOne
//
//  Created by Daniel Blezek on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FireView.h"
#import "GameViewController.h"
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


@implementation FireView

- (void)setup:(bool)isLeftFireButton {
  key_definition *key = current_key_definitions;
  for (unsigned i=0; i<NUMBER_OF_STANDARD_KEY_DEFINITIONS; i++, key++) {
    if ( isLeftFireButton ) {
      if ( key->action_flag == _left_trigger_state ){
        fireKey = key->offset;
      }
    } else {
      if ( key->action_flag == _right_trigger_state ){
        fireKey = key->offset;
      }
    }
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  for ( UITouch *touch in [event touchesForView:self] ) {
    NSLog(@"Touch in fire button");
    key_map[fireKey] = 1;
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  NSLog(@"starting touchesEnded in fire button");

  for ( UITouch *touch in [event touchesForView:self] ) {
    NSLog(@"Touch ended in fire button");
    key_map[fireKey] = 0;
  }
  return;
  
}

- (void)dealloc {
    [super dealloc];
}


@end
