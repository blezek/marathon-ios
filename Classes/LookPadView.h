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

		SDLKey primaryFireKey;
		SDLKey secondaryFireKey;
	
		CMMotionManager *motionManager;
		CMRotationRate rotationRate;
	  double gyroDeltaX, gyroDeltaY, gyroDeltaZ; //Accumulated change in gyro rotation, minus any mouselook that ocurred. Will typically be less than 1.
		//double lookDeltaX, lookDeltaY;
		NSDate *lastGyroUpdate;
		bool specialGyroModeActive;
		bool gyroActive;

	}

  @property (nonatomic, retain) NSDate *lastGyroUpdate;
	@property (nonatomic) CMRotationRate rotationRate;


	- (void)setup;
	- (void) stopGyro;
	- (void) resetGyro;
	- (void) startGyro;

	
@end
