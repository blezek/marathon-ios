//
//  MovePadView.m
//  AlephOne
//
//  Created by Daniel Blezek on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MovePadView.h"
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

@implementation MovePadView

- (void)setup {
  // Initialization code
  moveCenterPoint = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0 );
  moveRadius = ( moveCenterPoint.x + moveCenterPoint.y ) / 2.0;
  runRadius = moveRadius / 2.0;
  deadSpaceRadius = moveRadius / 5.0;
  key_definition *key = current_key_definitions;
  for (unsigned i=0; i<NUMBER_OF_STANDARD_KEY_DEFINITIONS; i++, key++) {
    if ( key->action_flag == _moving_forward ) {
      forwardKey = key->offset;
    }
    if ( key->action_flag == _moving_backward ) {
      backwardKey = key->offset;
    }
    if ( key->action_flag == _sidestepping_left ){
      leftKey = key->offset;
    }
    if ( key->action_flag == _sidestepping_right ) {
      rightKey = key->offset;
    }
    if ( key->action_flag == _run_dont_walk ) {
      runKey = key->offset;
    }
  }
}

- (void)handleTouch:(CGPoint)currentPoint {
  Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  
  // Doesn't matter where we are in this control, just find the position relative to the center
  
  float dx, dy;
  dx = currentPoint.x - moveCenterPoint.x;
  dy = currentPoint.y - moveCenterPoint.y;
  // NSLog ( @"Move delta: %f, %f", dx, dy );
  // Do we move left or right?
  
  float fdx = fabs ( dx );
  float fdy = fabs ( dy );
  // Are we running?
  if ( fdx > runRadius || fdy > runRadius ) {
    // key_map[runKey] = 1;
  } else {
    key_map[runKey] = 0;
  }
  // Left
  if ( dx < -deadSpaceRadius ) {
    // Just move for now
    // NSLog ( @"Move left" );
    key_map[leftKey] = 1;
  } else {
    key_map[leftKey] = 0;
  }
  // Right
  if ( dx > deadSpaceRadius ) {
    // NSLog(@"Move right" );
    key_map[rightKey] = 1;
  } else {
    key_map[rightKey] = 0;
  }
  
  // Forward, remember that y is increasing up
  if ( dy < -deadSpaceRadius ) {
    // NSLog(@"Move forward");
    key_map[forwardKey] = 1;
  } else {
    key_map[forwardKey] = 0;    
  }
  // Backward
  if ( dy > deadSpaceRadius ) {
    // NSLog(@"Move backward");
    key_map[backwardKey] = 1;
  } else {
    key_map[backwardKey] = 0;    
  }
  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for ( UITouch *touch in [event touchesForView:self] ) {
    [self handleTouch:[touch locationInView:self]];
    break;
  }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  // See if there are still touches in the
  Uint8 *key_map = SDL_GetKeyboardState ( NULL );

 // NSLog(@"Touches ended");
  // lift up on all the keys
  key_map[leftKey] = 0;
  key_map[rightKey] = 0;
  key_map[forwardKey] = 0;
  key_map[backwardKey] = 0;
  key_map[runKey] = 0;
  return;
  
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  // NSLog(@"Touches moved" );
  for ( UITouch *touch in [event touchesForView:self] ) {
    [self handleTouch:[touch locationInView:self]];
    break;
  }
}

- (void)dealloc {
    [super dealloc];
}


@end
