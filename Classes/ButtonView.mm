//
//  ButtonView.mm
//  AlephOne
//
//  Created by Daniel Blezek on 8/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ButtonView.h"
#import "GameViewController.h"
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
#include "interface.h"
#include "shell.h"
#include "preferences.h"
#include "mouse.h"
#include "player.h"
#include "key_definitions.h"
#include "tags.h"

#include "AlephOneHelper.h"

@implementation ButtonView

- (void)setup:(SDL_Keycode)k {
  key = k;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for ( UITouch *touch in [event touchesForView:self] ) {
    setKey(key, 1);
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {  
  for ( UITouch *touch in [event touchesForView:self] ) {
    // NSLog(@"Touch ended in fire button");
    setKey(key, 0);
    
  }
  return;
  
}


- (void)dealloc {
  // Kill a warning
  (void)all_key_definitions;
  [super dealloc];
}


@end
