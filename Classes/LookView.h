//
//  LookView.h
//  AlephOne
//
//  Created by Daniel Blezek on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LookPadView.h"
#import "SDL_uikitopenglview.h"
#include "SDL_keyboard.h"

@interface LookView : UIView {
  CGPoint lastPanPoint;
  CGPoint lastNonTapPoint; //The last point released that was not a tap.
  CGPoint lastTapPoint; //The last point that registered as a tap.
  SDL_Keycode primaryFire;
  SDL_Keycode secondaryFire;
  UITouch *secondTouch;
  UITouch *firstTouch;
  NSDate *firstTouchTime;
  NSDate *lastPrimaryFire;
  NSDate *touchesEndedTime;
  CGPoint startSwipe;
  bool lastTouchWasTap;
  bool swipePrimaryFiring;
  bool swipeSecondaryFiring;
  bool autoFireShouldStop;
  bool firstMoveSinceTouchStarted;
  short tapID;
  LookPadView *lookPadView;
  UIView *actionBox;
  UIView *smartFireIndicator;
  UIView *tapLocationIndicator;
  
	double lastForce, primaryForceThreshold, secondaryForceThreshold;
  
  bool inRearrangement;
}

@property (nonatomic,retain) IBOutlet LookPadView *lookPadView;
@property (nonatomic,retain) IBOutlet UIView *actionBox;
@property (nonatomic,retain) IBOutlet UIView *tapLocationIndicator;
@property (nonatomic,retain) IBOutlet UIView *smartFireIndicator;
@property (nonatomic) SDL_Keycode primaryFire;
@property (nonatomic) SDL_Keycode secondaryFire;
@property (nonatomic,retain) UITouch *firstTouch;
@property (nonatomic,retain) NSDate *firstTouchTime;
@property (nonatomic,retain) NSDate *lastPrimaryFire;
@property (nonatomic,retain) NSDate *touchesEndedTime;
@property (nonatomic) bool inRearrangement;

- (void) unPauseGyro;
- (void) alignTLIWithPoint:(CGPoint) location;
- (bool) touchInPrimaryFireZone:(UITouch*)touch;
- (bool) touchInSecondaryFireZone:(UITouch*)touch;
- (bool) touchInPrimaryPlusSecondaryFireZone:(UITouch*)touch;
- (void) stopAllFire: (NSNumber *) thisTapID;
- (void) stopSecondaryFire;
- (float)distanceFromPoint:(CGPoint)p1 to:(CGPoint)p2;
- (void) shouldRearrange:(bool)rearrange;
- (void) loadCustomArrangementFromPreferences;
- (void) moveSomeViewToTouch:(UITouch*)touch;
@end
