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
@synthesize lookPadView;
@synthesize smartFireIndicator;
@synthesize primaryFire, secondaryFire;
@synthesize firstTouchTime, lastPrimaryFire, touchesEndedTime, lastMovementTime;

- (void)viewDidLoad {
  firstTouch = nil;
  secondTouch = nil;
  tapID=0;
  lastTouchWasTap=NO;
	self.touchesEndedTime = [NSDate date];
  [smartFireIndicator setHidden:YES];
}

- (void)stopAllFire: (NSNumber *) thisTapID {
  
  if ( autoFireShouldStop && tapID <= [thisTapID shortValue] ) {
    setKey(secondaryFire, 0);
    setKey(primaryFire, 0);
    tapID = 0;
  }
}

- (void)stopSecondaryFire {
  setKey(secondaryFire, 0);
}

- (float)distanceFromPoint:(CGPoint)p1 to:(CGPoint)p2
{
  return sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.y,2));
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  //NSLog ( @"Touch started");
  
  [lookPadView unPauseGyro];

	//DCW
	lastForce = 0;
	primaryForceThreshold = .4;
	secondaryForceThreshold = .9;
  swipePrimaryFiring=0;
  swipeSecondaryFiring=0;
  autoFireShouldStop=0;
  self.lastMovementTime=[NSDate date];
  
  if ( firstTouch == nil ) {
    // grab the first
    firstTouch = [touches anyObject];
    self.firstTouchTime = [NSDate date];
  } else {
    secondTouch = [touches anyObject];
  }
  
  startSwipe.x = [firstTouch locationInView: self].x;
  startSwipe.y = [firstTouch locationInView: self].y;

  if(lookPadView && [[NSUserDefaults standardUserDefaults] boolForKey:kTiltTurning]){
    [lookPadView startGyro];
    lookPadView.specialGyroModeActive = YES;
  }
  
  for ( UITouch *touch in [event touchesForView:self] ) {
    if ( touch == firstTouch ) {
      lastPanPoint = [touch locationInView:self];
      
      CGPoint p1 = lastTapPoint;
      CGPoint p2 = lastPanPoint;
      //NSLog(@"last Tap: %f %f  Last Pan: %f %f", p1.x, p1.y, p2.x, p2.y);
      
      if( [self distanceFromPoint:lastPanPoint to:lastTapPoint] > TapContinuousFireDistance ) {
        autoFireShouldStop = 1;
      } else {
          //If last touch was a tap, activate smart fire.
        if ( lastTouchWasTap > 0 ) {
          setSmartFirePrimary(YES);
          [smartFireIndicator setHidden:NO];
        }
        
        autoFireShouldStop = 1; //remove this to just fire continuously
      }
      
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
      
      NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:self.firstTouchTime];
      NSTimeInterval touchEndDelta = [[NSDate date] timeIntervalSinceDate:self.touchesEndedTime];
      CGPoint thisTouch = [touch locationInView:self];
      self.firstTouchTime = nil;
      
      lastTouchWasTap = ( delta < TapToShootDelta && [self distanceFromPoint:startSwipe to:thisTouch] < 20 );
      if ( lastTouchWasTap ) {
        lastTapPoint=thisTouch;
      }
      
      firstTouch = nil;
      autoFireShouldStop=1;
      [smartFireIndicator setHidden:YES];
      if ( [[NSUserDefaults standardUserDefaults] boolForKey:kTapShoots] ) {
        if ( lastTouchWasTap ) {
          tapID ++;
          
          if(touchEndDelta < HiLowTapReset &&
             ((thisTouch.y > lastNonTapPoint.y + HiLowTapDistance) || (thisTouch.y < lastNonTapPoint.y - HiLowTapDistance)) &&
               [[NSUserDefaults standardUserDefaults] boolForKey:kHiLowTapsAltFire] )
          {
            //High touch does secondary+primary fire, and low touch does secondary only.
            if (thisTouch.y < lastNonTapPoint.y - HiLowTapDistance) {
              //MLog ( @"HIGH TAP");
              setKey(primaryFire, 1);
              setKey(secondaryFire, 1);
              [self performSelector:@selector(stopAllFire:) withObject:[NSNumber numberWithShort:tapID] afterDelay:0.20];
            } else {
              //MLog ( @"LOW TAP");
              setKey(secondaryFire, 1);
              [self performSelector:@selector(stopAllFire:) withObject:[NSNumber numberWithShort:tapID] afterDelay:0.20];
            }
          } else {
            //MLog ( @"MIDDLE TAP");
            lastNonTapPoint = thisTouch; //Middle taps always re-center the non-tap point.
            setKey(primaryFire, 1);
            [self performSelector:@selector(stopAllFire:) withObject:[NSNumber numberWithShort:tapID] afterDelay:0.20]; //DCW: was originally .2
          }
        }
        else
        {
          lastNonTapPoint = thisTouch;
          [self stopAllFire:[NSNumber numberWithShort:tapID]];
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
  
  if(lookPadView){
    [lookPadView stopGyro];
    lookPadView.specialGyroModeActive = NO;
  }
  
  setSmartFirePrimary(NO);
  setSmartFireSecondary(NO);
  
  self.touchesEndedTime = [NSDate date];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  //NSLog(@"Touches moved" );
	
  [lookPadView unPauseGyro];
  
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
    
    double forceNormalized = touch.force / touch.maximumPossibleForce;
    CGPoint currentPoint = [touch locationInView:self];
    float dx, dy;
    dx = currentPoint.x - lastPanPoint.x;
    dy = currentPoint.y - lastPanPoint.y;
    
    dy *=4; //DCW Lets bump up the vertical sensitivity.
    
    //moveMouseRelative(dx,dy);
    NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:self.lastMovementTime];
    moveMouseRelativeAcceleratedOverTime(dx, dy, delta);
    self.lastMovementTime=[NSDate date];

    lastPanPoint = currentPoint;
    
    int big = 50;
    big = big*big;
    if ( (dx*dx + dy*dy) > big ) {
      MLog(@"Big motion!" );
    }
		
    //setSmartFirePrimary(NO);
    //setSmartFireSecondary(NO);
    
		//DCW: Fire primary trigger if force is sufficient, otherwise disable trigger.

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
