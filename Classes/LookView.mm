//
//  LookView.mm
//  AlephOne
//
//  Created by Daniel Blezek on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LookView.h"
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

#import "Prefs.h"

@implementation LookView
@synthesize primaryFire, secondaryFire;
@synthesize firstTouchTime, lastPrimaryFire;
- (void)viewDidLoad {
  firstTouch = nil;
  secondTouch = nil;
  tapID=0;
	
}

- (void)stopPrimaryFire: (NSNumber *) thisTapID {
  
  if ( tapID <= [thisTapID shortValue] ) {
    setKey(primaryFire, 0);
    tapID = 0;
  }
}
- (void)stopSecondaryFire {
  setKey(secondaryFire, 0);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  //NSLog ( @"Touch started");

	//DCW
	lastForce = 0;
	primaryForceThreshold = .4;
	secondaryForceThreshold = .9;
  swipePrimaryFiring=0;
  swipeSecondaryFiring=0;
  
  if ( firstTouch == nil ) {
    // grab the first
    firstTouch = [touches anyObject];
    self.firstTouchTime = [NSDate date];
  } else {
    secondTouch = [touches anyObject];
  }
  
  startSwipe.x = [firstTouch locationInView: self].x;
  startSwipe.y = [firstTouch locationInView: self].y;

  for ( UITouch *touch in [event touchesForView:self] ) {
    if ( touch == firstTouch ) {
      lastPanPoint = [touch locationInView:self];
    } else {
      if ( [[NSUserDefaults standardUserDefaults] boolForKey:kSecondTapShoots] ) {
        // start the second fire
        setKey(secondaryFire, 1);
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
         MLog ( @"Might fire here");
        NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:self.firstTouchTime];
        self.firstTouchTime = nil;
        if ( delta < TapToShootDelta ) {
          setKey(primaryFire, 1);
          tapID ++;
          [self performSelector:@selector(stopPrimaryFire:) withObject:[NSNumber numberWithShort:tapID] afterDelay:0.35]; //DCW: was originally .2
        }
      }
				//DCW: Release trigger(s) if we were firing using force touch.
			if (lastForce >= primaryForceThreshold)
        setKey(primaryFire, 0);
			if (lastForce >= secondaryForceThreshold)
        setKey(secondaryFire, 0);
      
      if(swipePrimaryFiring)
         setKey(primaryFire, 0);
      if(swipeSecondaryFiring)
         setKey(secondaryFire, 0);
			
    }
    if ( touch == secondTouch && [[NSUserDefaults standardUserDefaults] boolForKey:kSecondTapShoots] ) {
      secondTouch = nil;
      setKey(secondaryFire, 0);
    }
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  //NSLog(@"Touches moved" );
	
  // If first touch goes away, make this one the first
  if ( firstTouch == nil ) {
    firstTouch = [touches anyObject];
    lastPanPoint = [firstTouch locationInView:self];
  }
  for ( UITouch *touch in [event touchesForView:self] ) {
    if ( firstTouch != nil 
        && touch != firstTouch ) {
      continue;
    }
    CGPoint currentPoint = [touch locationInView:self];
    float dx, dy;
    dx = currentPoint.x - lastPanPoint.x;
    dy = currentPoint.y - lastPanPoint.y;
    
    
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:kswipeToFire] ) {
      dy = 0;
      double swipeFireDelta = 30;
      if (startSwipe.y - currentPoint.y > swipeFireDelta ){
        swipePrimaryFiring=1;
        setKey(primaryFire, 1);
      }
      else if(swipePrimaryFiring) {
        swipePrimaryFiring=0;
        setKey(primaryFire, 0);
      }
      
      if (currentPoint.y - startSwipe.y > swipeFireDelta ){
        swipeSecondaryFiring=1;
        setKey(secondaryFire, 1);
      }
      else if(swipeSecondaryFiring) {
        swipeSecondaryFiring=0;
        setKey(secondaryFire, 0);
      }
    }
    dy *=4; //DCW Lets bump up the vertical sensitivity.
    moveMouseRelative(dx,dy);
    
    lastPanPoint = currentPoint;
    
    int big = 50;
    big = big*big;
    if ( (dx*dx + dy*dy) > big ) {
      MLog(@"Big motion!" );
    }
		
		//DCW: Fire primary trigger if force is sufficient, otherwise disable trigger.
		double forceNormalized = touch.force / touch.maximumPossibleForce;

		//This needs to track whether it activated triggers, otherwise is shuts down triggers from other controls. Maybe just yank it. it sucks anyway.
    /*
    if ( [touches count] >= 2 ) {
			//MLog(@"2 touches" );
			key_map[primaryFire] = 1;
		}
		else {
			key_map[primaryFire] = 0;
      MLog(@"DEBUGGING PRIMARY STOP1" );
		}
		
		if ( [touches count] >= 3 ) {
			//MLog(@"3 touches" );
			key_map[secondaryFire] = 1;
		}
		else {
			key_map[secondaryFire] = 0;
		}*/
		
		if (lastForce < primaryForceThreshold && forceNormalized >= primaryForceThreshold){
      setKey(primaryFire, 1);
			UISelectionFeedbackGenerator *feedback = [[[UISelectionFeedbackGenerator alloc] init] autorelease];
			[feedback selectionChanged];
			[feedback prepare];
		}
		if (lastForce < secondaryForceThreshold && forceNormalized >= secondaryForceThreshold){
      setKey(secondaryFire, 1);

			UIImpactFeedbackGenerator *feedback = [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy] autorelease];
			[feedback impactOccurred];
			[feedback prepare];


		}
		if (lastForce >= primaryForceThreshold && forceNormalized < primaryForceThreshold){
      setKey(primaryFire, 0);
			UISelectionFeedbackGenerator *feedback = [[[UISelectionFeedbackGenerator alloc] init] autorelease];
			[feedback selectionChanged];
			[feedback prepare];
		}
		if (lastForce >= secondaryForceThreshold && forceNormalized < secondaryForceThreshold){
      setKey(secondaryFire, 0);
			UIImpactFeedbackGenerator *feedback = [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy] autorelease];
			[feedback impactOccurred];
			[feedback prepare];
		}
		lastForce = forceNormalized;
		
    // NSLog(@"touches moved, sending delta" );
    
    break;
  }
}

- (void)dealloc {
  // Kill a warning
  (void)all_key_definitions;
  self.lastPrimaryFire = nil;
  self.firstTouchTime = nil;
    [super dealloc];
}


@end
