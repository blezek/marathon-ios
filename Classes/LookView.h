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
  bool swipePrimaryFiring;
  bool swipeSecondaryFiring;
  bool autoFireShouldStop;
  short tapID;
  LookPadView *lookPadView;

	double lastForce, primaryForceThreshold, secondaryForceThreshold;
}

@property (nonatomic,retain) IBOutlet LookPadView* lookPadView;
@property (nonatomic) SDL_Keycode primaryFire;
@property (nonatomic) SDL_Keycode secondaryFire;
@property (nonatomic,retain) NSDate *firstTouchTime;
@property (nonatomic,retain) NSDate *lastPrimaryFire;
@property (nonatomic,retain) NSDate *touchesEndedTime;

- (void)stopAllFire: (NSNumber *) thisTapID;
- (void)stopSecondaryFire;
- (float)distanceFromPoint:(CGPoint)p1 to:(CGPoint)p2;
@end
