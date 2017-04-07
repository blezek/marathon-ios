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

@implementation MovePadView
@synthesize knobView;

- (void)setup {
	
	
	//DCW
	feedbackSecondary = [[UIImpactFeedbackGenerator alloc] init];
	[feedbackSecondary initWithStyle:UIImpactFeedbackStyleHeavy];
	
  // Kill a warning
  (void)all_key_definitions;

  // Initialization code
  moveCenterPoint = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0 );
  moveRadius = ( moveCenterPoint.x + moveCenterPoint.y ) / 2.0;
  moveRadius2 = moveRadius * moveRadius;
  runRadius = moveRadius / 2.0;
  deadSpaceRadius = moveRadius / 5.0;
  key_definition *key = standard_key_definitions;
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
		
		//DCW
		if ( key->action_flag == _right_trigger_state ){
			secondaryFireKey = key->offset;
		}
		if ( key->action_flag == _action_trigger_state ){
			actionKey = key->offset;
		}
		
  }
}

	//DCW
- (void) actionKeyUp {
	if(actionKey){
		setKey(actionKey, 0);
	}
}

	//DCW added withNormalizedForce input with handleTouch. withNormalizedForce must be 0-1.
- (void)handleTouch:(CGPoint)currentPoint { [self handleTouch: currentPoint withNormalizedForce: 0.0]; }
- (void)handleTouch:(CGPoint)currentPoint withNormalizedForce:(double)force{
  const Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  
  // Doesn't matter where we are in this control, just find the position relative to the center
  
  float dx, dy;
  dx = currentPoint.x - moveCenterPoint.x;
  dy = currentPoint.y - moveCenterPoint.y;
  
  // Move the knob...
  float distance2 = dx * dx + dy * dy;
  if ( distance2 > moveRadius2 ) {
    // Limit to the radius
    float tx, ty;
    float length = 1.0 / sqrt ( distance2 );
    tx = dx * length;
    ty = dy * length;
    tx = moveCenterPoint.x + tx * moveRadius;
    ty = moveCenterPoint.y + ty * moveRadius;
    self.knobView.center = CGPointMake(tx, ty);
  } else {
    self.knobView.center = currentPoint;
  }
  // NSLog ( @"Move delta: %f, %f", dx, dy );
  // Do we move left or right?
  
  float fdx = fabs ( dx );
  float fdy = fabs ( dy );
	
  // Are we running?
  if ( fdx > runRadius || fdy > runRadius ) {
    setKey(runKey, 1);
    // MLog ( @"Running!" );
		
			//DCW: If we support forcetouch, and the force is low, invert sink/swim because running is also swim.
		if(useForceTouch) {
			if ( force > 0.5 ) {
				SET_FLAG(input_preferences->modifiers,_inputmod_interchange_swim_sink, false);
			}
			else {
				SET_FLAG(input_preferences->modifiers,_inputmod_interchange_swim_sink, true);
			}
		}
  } else {
		setKey(runKey, 0);
			//DCW: If we support forcetouch, and it the force is high, we can invert sink/swim so we will swim under pressure.
		if(useForceTouch) {
			if ( force > 0.5 ) {
				SET_FLAG(input_preferences->modifiers,_inputmod_interchange_swim_sink, true);
			}
			else {
				SET_FLAG(input_preferences->modifiers,_inputmod_interchange_swim_sink, false);
			}
		}
  }
  // Left
  if ( dx < -deadSpaceRadius ) {
    // Just move for now
    // NSLog ( @"Move left" );
    setKey(leftKey, 1);
  } else {
    setKey(leftKey, 0);
  }
  // Right
  if ( dx > deadSpaceRadius ) {
    // NSLog(@"Move right" );
    setKey(rightKey, 1);
  } else {
    setKey(rightKey, 0);
  }
  
  // Forward, remember that y is increasing up
  if ( dy < -deadSpaceRadius ) {
    // NSLog(@"Move forward");
    setKey(forwardKey, 1);
  } else {
    setKey(forwardKey, 0);
  }
  // Backward
  if ( dy > deadSpaceRadius ) {
    // NSLog(@"Move backward");
    setKey(backwardKey, 1);
  } else {
    setKey(backwardKey, 0);
  }
  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  useForceTouch = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable; //DCW: force capability must be checked often, because it fails when view is not in the view hierarchy.
  
  for ( UITouch *touch in [event touchesForView:self] ) {
    [self handleTouch:[touch locationInView:self]];
    break;
  }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  // See if there are still touches in the

 // NSLog(@"Touches ended");
  // lift up on all the keys
  setKey(leftKey, 0);
  setKey(rightKey, 0);
  setKey(forwardKey, 0);
  setKey(backwardKey, 0);
  setKey(runKey, 0);
  setKey(secondaryFireKey, 0);
  SET_FLAG(input_preferences->modifiers,_inputmod_interchange_swim_sink, false); //DCW
	
	//DCW. Do open/activate key when released
  setKey(actionKey, 1);
	[self performSelector:@selector(actionKeyUp) withObject:nil afterDelay:0.15];

  // Animate the knob returning to home...
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
  [UIView setAnimationDuration:0.2];
  self.knobView.center = moveCenterPoint;
  [UIView commitAnimations];
  return;
  
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  // NSLog(@"Touches moved" );
  for ( UITouch *touch in [event touchesForView:self] ) {
			//DCW: Added force to handleTouch call
    [self handleTouch:[touch locationInView:self] withNormalizedForce:touch.force / touch.maximumPossibleForce ];
    break;
  }
}

- (void)dealloc {
  self.knobView = nil;
    [super dealloc];
}


@end
