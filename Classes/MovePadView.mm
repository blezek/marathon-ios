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
@synthesize dPadView, knobView;

- (void)setup {
	
	
	//DCW
	feedbackSecondary = [[UIImpactFeedbackGenerator alloc] init];
	[feedbackSecondary initWithStyle:UIImpactFeedbackStyleHeavy];
  originalFrame=CGRectMake(0, 0, 0, 0);

  // Kill a warning
  (void)all_key_definitions;

  // Initialization code
  //moveCenterPoint = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0 );
  moveCenterPoint = CGPointMake(dPadView.frame.origin.x + dPadView.bounds.size.width / 2.0, dPadView.frame.origin.y + dPadView.bounds.size.height / 2.0 );
  //moveRadius = ( moveCenterPoint.x + moveCenterPoint.y ) / 2.0;
  moveRadius = dPadView.bounds.size.width / 2.0; //DCW?
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
  
    //Move our desired knob location based on movement delta.
    //We will limit the knob location to stay within our run limit.
    //The reason for doing this is to provide a consistent swipe distance for a "stop/change-direction" operation.
  knobLocation.x += currentPoint.x - lastLocation.x;
  knobLocation.y += currentPoint.y - lastLocation.y;

  
  // Doesn't matter where we are in this control, just find the position relative to the center
  float dx, dy;
  dx = knobLocation.x - moveCenterPoint.x;
  dy = knobLocation.y - moveCenterPoint.y;
  
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
    self.knobView.center = knobLocation;
  }
  // NSLog ( @"Move delta: %f, %f", dx, dy );
  // Do we move left or right?
  
  float fdx = fabs ( dx );
  float fdy = fabs ( dy );
  
  float tightClamp = [[NSUserDefaults standardUserDefaults] boolForKey:kAlwaysRun] && (useForceTouch || !headBelowMedia()); //Whether to clamp the knob close to center or not.
  bool running = ( fdx > runRadius || fdy > runRadius || tightClamp);
  float runThresholdBufferX=5; //How far we let the knob move into the run delta threshold for strafing.
  float runThresholdBufferY=30; //How far we let the knob move into the run delta threshold for forward/back movement.
  
  // Are we running?
  if ( running ) {
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
    
    if (dx < 0.0-deadSpaceRadius-runThresholdBufferX-((!tightClamp)*runRadius)) {
      knobLocation.x=moveCenterPoint.x-deadSpaceRadius-((!tightClamp)*runRadius)-runThresholdBufferX;
    }
  } else {
    setKey(leftKey, 0);
  }
  // Right
  if ( dx > deadSpaceRadius ) {
    // NSLog(@"Move right" );
    setKey(rightKey, 1);
    if (dx > deadSpaceRadius+runThresholdBufferX+((!tightClamp)*runRadius)) {
      knobLocation.x=moveCenterPoint.x+deadSpaceRadius+((!tightClamp)*runRadius)+runThresholdBufferX;
    }
  } else {
    setKey(rightKey, 0);
  }
  
  // Forward, remember that y is increasing up
  if ( dy < -deadSpaceRadius ) {
    // NSLog(@"Move forward");
    setKey(forwardKey, 1);
    
    
    if (dy < 0.0-deadSpaceRadius-runThresholdBufferY-((!tightClamp)*runRadius)) {
      knobLocation.y=moveCenterPoint.y-deadSpaceRadius-((!tightClamp)*runRadius)-runThresholdBufferY;
    }
  } else {
    setKey(forwardKey, 0);
  }
  // Backward
  if ( dy > deadSpaceRadius ) {
    // NSLog(@"Move backward");
    setKey(backwardKey, 1);
    
    if (dy > deadSpaceRadius+runThresholdBufferY+((!tightClamp)*runRadius)) {
      knobLocation.y=moveCenterPoint.y+deadSpaceRadius+((!tightClamp)*runRadius)+runThresholdBufferY;
    }
  } else {
    setKey(backwardKey, 0);
  }
  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  useForceTouch = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable; //DCW: force capability must be checked often, because it fails when view is not in the view hierarchy.
  if (originalFrame.size.width == 0) {
    originalFrame=[self frame];
  }
  
  for ( UITouch *touch in [event touchesForView:self] ) {
    //DCW: I think I'm going to auto-center the control under the touch to prevent immediate movement.
    
    CGRect newFrame=[dPadView frame];
    CGPoint center = CGPointMake(newFrame.size.width/2,newFrame.size.height/2 );
    lastLocation=[touch locationInView:self];
    knobLocation=lastLocation;
    newFrame.origin.x = lastLocation.x-center.x;
    newFrame.origin.y = lastLocation.y-center.y;
    [dPadView setFrame:newFrame];
    
    moveCenterPoint = CGPointMake(dPadView.frame.origin.x + dPadView.bounds.size.width / 2.0, dPadView.frame.origin.y + dPadView.bounds.size.height / 2.0 );
    //[self handleTouch:[touch locationInView:self]]; //Irrelevant when control is centered.
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

  SET_FLAG(input_preferences->modifiers,_inputmod_interchange_swim_sink, false); //DCW
	
	//DCW. Do open/activate key when released
  setKey(actionKey, 1);
  if ([[GameViewController sharedInstance].HUDViewController lookingAtRefuel]){
    [[GameViewController sharedInstance].HUDViewController.lookPadView pauseGyro];
  }
	[self performSelector:@selector(actionKeyUp) withObject:nil afterDelay:0.15];

  // Animate the knob returning to home...
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
  [UIView setAnimationDuration:0.2];
  self.knobView.center = moveCenterPoint;
  [UIView commitAnimations];
  
  //Animate entire control returning to default location.
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
  [UIView setAnimationDuration:0.1];
  self.frame = originalFrame;
  [UIView commitAnimations];

  return;
  
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  // NSLog(@"Touches moved" );
  for ( UITouch *touch in [event touchesForView:self] ) {
			//DCW: Added force to handleTouch call
    [self handleTouch:[touch locationInView:self] withNormalizedForce:touch.force / touch.maximumPossibleForce ];
    lastLocation=[touch locationInView:self];
    break;
  }
}

- (void)dealloc {
  self.knobView = nil;
    [super dealloc];
}


@end
