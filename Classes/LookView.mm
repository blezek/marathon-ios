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



@implementation LookView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for ( UITouch *touch in [event touchesForView:self] ) {
    lastPanPoint = [touch locationInView:self];
    break;
  }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
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
