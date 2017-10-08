//
//  LookPadView.h
//  AlephOne
//
//  Created by Dustin Wenz on 10/9/16.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

#import "SDL_uikitopenglview.h"
#include "SDL_keyboard.h"


@interface LookPadView : UIView {

		SDL_Keycode primaryFireKey;
		SDL_Keycode secondaryFireKey;
    SDL_Keycode nextWeaponKey;
    SDL_Keycode previousWeaponKey;
	
		CMMotionManager *motionManager;
		CMRotationRate rotationRate;
	  double gyroDeltaX, gyroDeltaY, gyroDeltaZ; //Accumulated change in gyro rotation, minus any mouselook that ocurred. Will typically be less than 1.
		CGPoint lastMovedPoint;
    NSDate *lastGyroUpdate;
		bool specialGyroModeActive;
		bool gyroActive;
    bool gyroPaused;

	}

  @property (nonatomic, retain) NSDate *lastGyroUpdate;
	@property (nonatomic) CMRotationRate rotationRate;
  @property (nonatomic) bool specialGyroModeActive;



	- (void) setup;
	- (void) stopGyro;
	- (void) resetGyro;
	- (void) startGyro;
  - (void) pauseGyro;
  - (void) unPauseGyro;
  - (void) nextWeaponKeyUp;
  - (void) previousWeaponKeyUp;


	
@end
