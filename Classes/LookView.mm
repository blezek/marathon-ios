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
@synthesize actionBox;
@synthesize tapLocationIndicator;
@synthesize smartFireIndicator;
@synthesize primaryFire, secondaryFire;
@synthesize firstTouch, firstTouchTime, lastPrimaryFire, touchesEndedTime;
@synthesize inRearrangement;

- (void)viewDidLoad {
  firstTouch = nil;
  secondTouch = nil;
  tapID=0;
  inRearrangement=NO;
  lastTouchWasTap = NO;
  autoFireShouldStop = YES;
	self.touchesEndedTime = [NSDate date];
  [smartFireIndicator setHidden:YES];
  [tapLocationIndicator setHidden:![[NSUserDefaults standardUserDefaults] boolForKey:kHiLowTapsAltFire]];
}

- (void)alignTLIWithPoint:(CGPoint) location; {
  CGRect TLIframe=[tapLocationIndicator frame];
  TLIframe.size.height=HiLowTapDistance;
  TLIframe.origin.y = location.y-(float)HiLowTapDistance/2.0;
  [tapLocationIndicator setFrame:TLIframe];
  [tapLocationIndicator setNeedsLayout];
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
  id anything = [touches anyObject];

  if (inRearrangement) {
    if( [anything isKindOfClass:[UITouch class]] ){
      [self moveSomeViewToTouch: (UITouch*)anything];
    }
    return;
  }
  
  //NSLog ( @"Touch started ");
  
  [lookPadView unPauseGyro];

	//DCW
	lastForce = 0;
	primaryForceThreshold = .4;
	secondaryForceThreshold = .9;
  swipePrimaryFiring=0;
  swipeSecondaryFiring=0;
  autoFireShouldStop=0;
  
  [tapLocationIndicator setHidden:![[NSUserDefaults standardUserDefaults] boolForKey:kHiLowTapsAltFire]];
  
    //Assign firstTouch, if needed.
    //Also, if there is only one touch and firstTouch appears wrong, re-assign in. We can get in this state if control center is brought up and we never get a touches-ended event.
  if ( firstTouch == nil || (anything != firstTouch && [[event touchesForView:self] count] == 1)) {
    // grab the first
    [self setFirstTouch: (UITouch*)anything];
    self.firstTouchTime = [NSDate date];
    firstMoveSinceTouchStarted = YES;
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
          if ([self touchInPrimaryPlusSecondaryFireZone:touch] && [[NSUserDefaults standardUserDefaults] boolForKey:kHiLowTapsAltFire]) {
            autoFireShouldStop = NO;
            setKey(primaryFire, 1);
            setKey(secondaryFire, 1);
          } else if ([self touchInSecondaryFireZone:touch] && [[NSUserDefaults standardUserDefaults] boolForKey:kHiLowTapsAltFire]) {
            autoFireShouldStop = NO;
            setKey(secondaryFire, 1);
          } else {
            setSmartFirePrimary(YES);
            autoFireShouldStop = YES;
            [smartFireIndicator setHidden:NO];
          }
          
        }
        
      }
      
    } /*else {
      if ( [[NSUserDefaults standardUserDefaults] boolForKey:kSecondTapShoots] ) {
        // start the second fire
        setKey(secondaryFire, 1);
      }
    }*/
  }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  id anything = [touches anyObject];
  
  if (inRearrangement) {
    if( [anything isKindOfClass:[UITouch class]] ){
      [self moveSomeViewToTouch: (UITouch*)anything];
    }
    return;
  }
  
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
      
      [self setFirstTouch: nil];
      autoFireShouldStop=1;
      [smartFireIndicator setHidden:YES];
      setSmartFirePrimary(NO);
      
      //if ( [[NSUserDefaults standardUserDefaults] boolForKey:kTapShoots] ) {
        if ( lastTouchWasTap ) {
          tapID ++;
          
          //if( [[NSUserDefaults standardUserDefaults] boolForKey:kHiLowTapsAltFire] && [[NSUserDefaults standardUserDefaults] boolForKey:kTapShoots])
         // {
            if ([self touchInPrimaryPlusSecondaryFireZone:touch] && [[NSUserDefaults standardUserDefaults] boolForKey:kHiLowTapsAltFire]) {
              //MLog ( @"PRIMARY+SECONDARY TAP");
              setKey(primaryFire, 1);
              setKey(secondaryFire, 1);
              [self performSelector:@selector(stopAllFire:) withObject:[NSNumber numberWithShort:tapID] afterDelay:0.20];
            } else if ([self touchInSecondaryFireZone:touch] && [[NSUserDefaults standardUserDefaults] boolForKey:kHiLowTapsAltFire]) {
              //MLog ( @"SECONDARY TAP");
              setKey(secondaryFire, 1);
              [self performSelector:@selector(stopAllFire:) withObject:[NSNumber numberWithShort:tapID] afterDelay:0.20];
            } else if ([[NSUserDefaults standardUserDefaults] boolForKey:kTapShoots]) {
              //MLog ( @"PRIMARY TAP");
              lastNonTapPoint = thisTouch; //Middle taps always re-center the non-tap point.
              setKey(primaryFire, 1);
              [self performSelector:@selector(stopAllFire:) withObject:[NSNumber numberWithShort:tapID] afterDelay:0.20]; //DCW: was originally .2
            }
          //}
        }
        else
        {
          lastNonTapPoint = thisTouch;
          [self stopAllFire:[NSNumber numberWithShort:tapID]];
        }
      //}
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
    /*if ( touch == secondTouch && [[NSUserDefaults standardUserDefaults] boolForKey:kSecondTapShoots] ) {
      secondTouch = nil;
      setKey(secondaryFire, 0);
    }*/
  }
  
  if(lookPadView){
    [lookPadView stopGyro];
    lookPadView.specialGyroModeActive = NO;
  }
  
  self.touchesEndedTime = [NSDate date];
}

- (bool) touchInPrimaryFireZone:(UITouch*)touch{
  float y = [touch locationInView:self].y;
  CGRect TLIframe=[tapLocationIndicator frame];
  return y >= TLIframe.origin.y && y <= TLIframe.origin.y+TLIframe.size.height;
}
- (bool) touchInSecondaryFireZone:(UITouch*)touch{
  float y = [touch locationInView:self].y;
  CGRect TLIframe=[tapLocationIndicator frame];
  return y < TLIframe.origin.y;
}
- (bool) touchInPrimaryPlusSecondaryFireZone:(UITouch*)touch{
  float y = [touch locationInView:self].y;
  CGRect TLIframe=[tapLocationIndicator frame];
  return y > TLIframe.origin.y+TLIframe.size.height;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  
  if (inRearrangement) {
    [self moveSomeViewToTouch: [touches anyObject]];
    return;
  }

  
  // If first touch goes away, make this one the first
   if ( firstTouch == nil ) {
     firstTouch = [touches anyObject];
     lastPanPoint = [firstTouch locationInView:self];
   }
   for ( UITouch *touch in [event touchesForView:self] ) {
     if ( firstTouch != nil && touch != firstTouch ) {
       continue;
     }
     
     for ( UITouch *highFrequencyTouch in [event coalescedTouchesForTouch:touch] ) {
       [self handleTouch:highFrequencyTouch];
     }
   }
                           
}


- (void)handleTouch:(UITouch *)touch {
  
  if (inRearrangement) {
    [self moveSomeViewToTouch: touch];
    return;
  }
  
  [lookPadView unPauseGyro];
  
  double forceNormalized = [[NSUserDefaults standardUserDefaults] boolForKey:kThreeDTouchFires] ? touch.force / touch.maximumPossibleForce : 0;
  CGPoint currentPoint = [touch locationInView:self];
  //NSLog(@"Force %f", forceNormalized);
  //Throw out dealts from first movement since touch began, to avoid big jump.
  if (firstMoveSinceTouchStarted && (lastPanPoint.x != currentPoint.x || lastPanPoint.y != currentPoint.y) ) {
    lastPanPoint = currentPoint;
    firstMoveSinceTouchStarted = NO;
    //NSLog(@"Go Touches!");
  }

  float dx, dy;
  dx = currentPoint.x - lastPanPoint.x;
  dy = currentPoint.y - lastPanPoint.y;

  dy *=4; //DCW Lets bump up the vertical sensitivity.
  //NSLog(@"touches moved %f", dx );

  moveMouseRelativeAtInterval(dx, dy, touch.timestamp);

  lastPanPoint = currentPoint;

  int big = 50;
  big = big*big;
  if ( (dx*dx + dy*dy) > big ) {
    MLog(@"Big motion!" );
  }

    //Always update TLI when touch is in the primary fire zone.
    //Or, only update TLI when we actually pan, and that pan was longer than the tap-to-fire timer.
  if ( (dx || dy) ) {// && ([self touchInPrimaryFireZone:firstTouch] || [[NSDate date] timeIntervalSinceDate:self.firstTouchTime] > TapToShootDelta) ) {
      //Yeah, and also, don't move the TLI when we are in continuous-fire mode.
    if( autoFireShouldStop || tapID == 0 ) {
        [self alignTLIWithPoint: currentPoint];
    }
  }

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

  //NSLog(@"touches moved, sending delta" );

}

- (void) shouldRearrange:(bool)rearrange {
  inRearrangement=rearrange;
  
  [lookPadView setUserInteractionEnabled:!inRearrangement];
  [actionBox setUserInteractionEnabled:!inRearrangement];
  
    //Un-hide lookPadView, but the actionbox will be shown by runmainlooponce.
  [lookPadView setHidden:!(rearrange || [[NSUserDefaults standardUserDefaults] boolForKey:kOnScreenTrigger])];
  
  if (!rearrange) {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCustomTriggerLocation];
    [[NSUserDefaults standardUserDefaults] setFloat:[lookPadView frame].origin.x forKey:kCustomTriggerLocationX];
    [[NSUserDefaults standardUserDefaults] setFloat:[lookPadView frame].origin.y forKey:kCustomTriggerLocationY];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCustomActionLocation];
    [[NSUserDefaults standardUserDefaults] setFloat:[actionBox frame].origin.x forKey:kCustomActionLocationX];
    [[NSUserDefaults standardUserDefaults] setFloat:[actionBox frame].origin.y forKey:kCustomActionLocationY];
  }
}

- (void) loadCustomArrangementFromPreferences {
  if([[NSUserDefaults standardUserDefaults] boolForKey:kCustomTriggerLocation]) {
    CGRect newFrame=CGRectMake([[NSUserDefaults standardUserDefaults] floatForKey:kCustomTriggerLocationX],
                               [[NSUserDefaults standardUserDefaults] floatForKey:kCustomTriggerLocationY],
                               [lookPadView frame].size.width, [lookPadView frame].size.height);
    
    [lookPadView setFrame:newFrame];
  }
  
  if([[NSUserDefaults standardUserDefaults] boolForKey:kCustomActionLocation]) {
    CGRect newFrame=CGRectMake([[NSUserDefaults standardUserDefaults] floatForKey:kCustomActionLocationX],
                               [[NSUserDefaults standardUserDefaults] floatForKey:kCustomActionLocationY],
                               [actionBox frame].size.width, [actionBox frame].size.height);
    
    [actionBox setFrame:newFrame];
  }
}

- (void) moveSomeViewToTouch:(UITouch*)touch {
  bool centerViewOnTouch = NO;
  UIView *viewOfInterest = actionBox;
  if ([touch locationInView:self].x > self.frame.size.width / 2) {
    viewOfInterest = lookPadView;
    centerViewOnTouch=YES;
  }
  
  CGRect newFrame = [viewOfInterest frame];
  CGPoint halfDimensions= CGPointMake(newFrame.size.width/2, newFrame.size.height/2);
  CGPoint newOrigin = [touch locationInView:self];
  if (centerViewOnTouch) { newOrigin.x -= halfDimensions.x; }
  newOrigin.y -= halfDimensions.y;
  newFrame.origin=newOrigin;
  [viewOfInterest setFrame:newFrame];
}

- (void)dealloc {
  // Kill a warning
  (void)all_key_definitions;
  self.lastPrimaryFire = nil;
  self.firstTouchTime = nil;
    [super dealloc];
}


@end
