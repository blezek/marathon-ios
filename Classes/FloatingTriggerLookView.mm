//
//  FloatingTriggerLookView.m
//  AlephOne
//
//  Created by Daniel Blezek on 7/28/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "FloatingTriggerLookView.h"
#import <QuartzCore/QuartzCore.h>
#import "Prefs.h"
#import "AlephOneAppDelegate.h"
#import "AlephOneHelper.h"

#include "SDL_keyboard_c.h"
#include "SDL_keyboard.h"
#include "SDL_stdinc.h"
#include "SDL_mouse_c.h"
#include "SDL_mouse.h"
#include "SDL_events.h"

@implementation FloatingTriggerLookView
@synthesize hudViewController;
@synthesize primaryFireButton, secondaryFireButton;
@synthesize trackingTouch, lookTouch, primaryTouch, secondaryTouch;

- (id)initWithCoder:(NSCoder *)decoder {
  self = [super initWithCoder:decoder];
  if ( self != nil ) {
    mode = NotTouching;
    self.primaryFireButton.hidden = YES;
    self.secondaryFireButton.hidden = YES;
    self.primaryFireButton.center = CGPointMake(-1000, -1000);
    self.secondaryFireButton.center = CGPointMake(-1000, -1000);
    startingAlpha = self.primaryFireButton.alpha;
    startingAlpha = 0.4;
    if ( [[AlephOneAppDelegate sharedAppDelegate] runningOniPad] ) {
      deviceMultiplier = 1.0;
    } else {
      deviceMultiplier = 1.5;
    }
  }
  return self;
}

- (BOOL)touch:(UITouch*)touch hitView:(UIView*)view {
  return CGRectContainsPoint ( view.bounds, [touch locationInView:view] );
}

- (void)updateButtons:(CGPoint)point {
  if ( ![[NSUserDefaults standardUserDefaults] boolForKey:kTapShoots] ) {
    self.primaryFireButton.hidden = YES;
    self.secondaryFireButton.hidden = YES;
    self.primaryFireButton.center = CGPointMake(-1000, -1000);
    self.secondaryFireButton.center = CGPointMake(-1000, -1000);
    return;
  }

  
  if ( isFadingOut ) {
    [UIView animateWithDuration:.1
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionOverrideInheritedDuration|UIViewAnimationOptionOverrideInheritedCurve
                     animations:^{
                     self.primaryFireButton.alpha = startingAlpha;
                     self.secondaryFireButton.alpha = startingAlpha;
                   }
                   completion:^(BOOL completed) {
                     if (completed) {
                     }
                   }];
  }
  isFadingOut = NO;
  
  self.primaryFireButton.hidden = NO;
  self.secondaryFireButton.hidden = NO;
  self.primaryFireButton.alpha = startingAlpha;
  self.secondaryFireButton.alpha = startingAlpha;

  self.primaryFireButton.center = point;
  self.secondaryFireButton.center = point;
  
  float dx = self.primaryFireButton.bounds.size.width / 2.0;
  
  switch (mode) {
    case PrimaryFire:
    {
      self.secondaryFireButton.center = CGPointMake ( point.x + 2 * dx, point.y );
      break;
    }
    case SecondaryFire:
    {
      self.primaryFireButton.center = CGPointMake ( point.x - 2*dx, point.y );
      break;
    }
      
    default:
    {
      self.secondaryFireButton.center = CGPointMake ( point.x + dx, point.y );
      self.primaryFireButton.center = CGPointMake ( point.x - dx, point.y );
      break;
    }
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if ( self.trackingTouch == nil ) {
    // grab the first
    self.trackingTouch = [touches anyObject];
    mode = Looking;
  }
  // See if any of the touches hit a button
  for ( UITouch *touch in [event touchesForView:self] ) {
    if ( [self touch:touch hitView:self.primaryFireButton] ) {
      self.primaryTouch = touch;
      [self.hudViewController primaryFireDown:self];
      if ( self.primaryTouch == self.trackingTouch ) {
        mode = PrimaryFire;
      }
    }
    if ( [self touch:touch hitView:self.secondaryFireButton] ) {
      self.secondaryTouch = touch;
      [self.hudViewController secondaryFireDown:self];
      if ( self.secondaryTouch == self.trackingTouch ) {
        mode = SecondaryFire;
      }
    }
  }
  [self updateButtons:[self.trackingTouch locationInView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  for ( UITouch *touch in touches ) {
    if ( touch == self.primaryTouch ) {
      [self.hudViewController primaryFireUp:self];
      self.primaryTouch = nil;
    }
    if ( touch == self.secondaryTouch ) {
      [self.hudViewController secondaryFireUp:self];
      self.secondaryTouch = nil;
    }
    if ( self.trackingTouch == touch ) {
      self.trackingTouch = nil;
    }
  }
  if ( self.trackingTouch == nil ) {
    self.trackingTouch = self.primaryTouch == nil ? self.secondaryTouch : self.primaryTouch;
  }
  
  // Hide if nothing touching
  if ( self.trackingTouch == nil && self.primaryTouch == nil && self.secondaryTouch == nil ) {
    mode = NotTouching;
    isFadingOut = YES;
    [UIView animateWithDuration:.7
                          delay:.5
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                       self.primaryFireButton.alpha = 0.0;
                       self.secondaryFireButton.alpha = 0.0;
                     }
                     completion:^(BOOL completed){
                       if ( self.trackingTouch == nil && self.primaryTouch == nil && self.secondaryTouch == nil ) {
                         self.primaryFireButton.hidden = YES;
                         self.secondaryFireButton.hidden = YES;
                         self.primaryFireButton.center = CGPointMake(-1000, -1000);
                         self.secondaryFireButton.center = CGPointMake(-1000, -1000); 
                       } else {
                         self.primaryFireButton.alpha = startingAlpha;
                         self.secondaryFireButton.alpha = startingAlpha;
                       }
                     }];
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if ( self.trackingTouch == nil ) {
    self.trackingTouch = [[event touchesForView:self] anyObject];
  } else {
    // Verify that it's in the set!
    if ( ![[event touchesForView:self] containsObject:self.trackingTouch] ) {
      NSLog(@"Lost tracking touch!!!!" );
      self.trackingTouch = [[event touchesForView:self] anyObject];
    }
  }
  if ( self.trackingTouch == nil ) {
    NSLog(@"Totally lost the tracking...");
    mode = NotTouching;
  }
  for ( UITouch *touch in [event touchesForView:self] ) {
    if ( touch == self.trackingTouch ) {
      CGPoint currentPoint = [touch locationInView:self];
      CGPoint lastPanPoint = [touch previousLocationInView:self];

      int dx, dy;
      dx = deviceMultiplier * ( currentPoint.x - lastPanPoint.x );
      dy = deviceMultiplier * ( currentPoint.y - lastPanPoint.y );
      moveMouseRelative(dx,dy);
      // Move the buttons
      [self updateButtons:currentPoint];
    }
  }
}

- (void)dealloc {
  // Kill a warning
  [super dealloc];
}


@end
