//
//  LookView.h
//  AlephOne
//
//  Created by Daniel Blezek on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDL_uikitopenglview.h"
#include "SDL_keyboard.h"

@interface LookView : UIView {
  CGPoint lastPanPoint;
  SDL_Keycode primaryFire;
  SDL_Keycode secondaryFire;
  UITouch *secondTouch;
  UITouch *firstTouch;
  NSDate *firstTouchTime;
  NSDate *lastPrimaryFire;

	double lastForce, primaryForceThreshold, secondaryForceThreshold; //DCW
}

@property (nonatomic) SDL_Keycode primaryFire;
@property (nonatomic) SDL_Keycode secondaryFire;
@property (nonatomic,retain) NSDate *firstTouchTime;
@property (nonatomic,retain) NSDate *lastPrimaryFire;

- (void)stopPrimaryFire;
- (void)stopSecondaryFire;

@end
