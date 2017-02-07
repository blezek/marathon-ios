//
//  LookPadView.m
//  AlephOne
//
//  Created by Dusti Wenz on 10/9/16.
//

#import "LookPadView.h"
#import "GameViewController.h"
extern "C" {
  extern  int
  SDL_SendMouseMotion(int relative, int x, int y);
  
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


@implementation LookPadView

@synthesize rotationRate;
@synthesize lastGyroUpdate;

- (void)setup {
	
	motionManager = [[CMMotionManager alloc] init];
	
  // Kill a warning
  (void)all_key_definitions;

  // Initialization code
	key_definition *key = current_key_definitions;
	for (unsigned i=0; i<NUMBER_OF_STANDARD_KEY_DEFINITIONS; i++, key++) {
		if ( key->action_flag == _left_trigger_state ){
			primaryFireKey = key->offset;
		}
		if ( key->action_flag == _right_trigger_state ){
			secondaryFireKey = key->offset;
		}
  }
	
	specialGyroModeActive = 0;
	[self startGyro];

}

- (void)handleTouch:(CGPoint)currentPoint {	
	Uint8 *key_map = SDL_GetKeyboardState ( NULL );
  
	double height = [self bounds].size.height;
	double width = [self bounds].size.width;

  double dx, dy;
	dx = currentPoint.x;
	dy = currentPoint.y;
	
	if (currentPoint.y < height * (1.0/3.0) && currentPoint.x < width * (2.0/3.0)) {
		key_map[primaryFireKey] = 1;
		NSLog(@"fire!");
	} else {
		key_map[primaryFireKey] = 0;
		NSLog(@"stop firing!");
	}
	
	if (currentPoint.y < height * (1.0/3.0) && currentPoint.x > width * (1.0/3.0)) {
		key_map[secondaryFireKey] = 1;
		NSLog(@"fire 2!");
	} else {
		key_map[secondaryFireKey] = 0;
		NSLog(@"stop firing 2!");
	}
	
	if ( !specialGyroModeActive ) {
		[self resetGyro];
		specialGyroModeActive = 1;
	}
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	for ( UITouch *touch in [event touchesForView:self] ) {
		[self handleTouch:[touch locationInView:self]];
		break;
	}

	
}

- (void) stopGyro {
	[motionManager stopGyroUpdates];
	gyroActive = 0;
}

- (void) resetGyro {
	gyroDeltaX = 0;
	gyroDeltaY = 0;
	gyroDeltaZ = 0;
	//lookDeltaX = 0;
	//lookDeltaY = 0;
	[self setLastGyroUpdate:[NSDate date]];
}

- (void) startGyro {

	[self resetGyro];
	gyroActive = 1;
	
	[motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyro, NSError *error)
						 {
							 
							 [(id) self setRotationRate:gyro.rotationRate];
							 [self performSelectorOnMainThread:@selector(handleGyro) withObject:nil waitUntilDone:NO];
						 }];
}

- (void)handleGyro {

	double elapsedtime = 0.0 - [lastGyroUpdate timeIntervalSinceNow];
	[self setLastGyroUpdate:[NSDate date]];
	double tiltFactor = 300; //Arbitrary number multiplied by the amount of rotation used for aiming/look.
	double turnFactor = 900; //Arbitrary number multiplied by the amount of rotation used for tilt turning.
	
	
	//double acceleration = 10;
	double cutoff = 0.01 * elapsedtime; //Gyro movements below this threshold will be ignored.
	
	//double accelerationDeadband = 50;
	
		//How much we rotated on this call. Small rotations don't count.
	double rotatedX = abs(rotationRate.x) < cutoff ? 0.0 : rotationRate.x * elapsedtime;
	double rotatedY = abs(rotationRate.y) < cutoff ? 0.0 : rotationRate.y * elapsedtime;
	double rotatedZ = abs(rotationRate.z) < cutoff ? 0.0 : rotationRate.z * elapsedtime;

	//Apply comfortable rotation rate adjustment.
	gyroDeltaX = rotatedX  * tiltFactor;
	gyroDeltaY = rotatedY  * tiltFactor;
	gyroDeltaZ = rotatedZ  * turnFactor;


		//the x axis is accelerated as lookDeltaX increases.
		//Calculate the amount of turn accleleration we may want to apply
	//double xAccelerationAmount = (rotatedX * abs(lookDeltaX) * acceleration);
	
	//Track total look delta since last reset.
	//lookDeltaX += gyroDeltaX;
	//lookDeltaY += gyroDeltaY;
	
	
	//If specialGyroModeActive is set, then we only look when turning in the direction we've already moved from zero.
	//If specialGyroModeActive is not set, just look normally using the gyro.

	int mouseMovementX = gyroDeltaX;
	gyroDeltaX -= (double)mouseMovementX;
	
	int mouseMovementY = gyroDeltaY;
	gyroDeltaY -= (double)mouseMovementY;
	
	int mouseMovementZ = 0; //This is actually going to become X movement below.
	if (specialGyroModeActive ){
		mouseMovementZ = gyroDeltaZ;
		gyroDeltaZ -= (double)mouseMovementZ;
	}
	
	SDL_SendMouseMotion ( true, 0 - (mouseMovementX + mouseMovementZ), mouseMovementY );
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	Uint8 *key_map = SDL_GetKeyboardState ( NULL );
	
	key_map[primaryFireKey] = 0;
	key_map[secondaryFireKey] = 0;
	specialGyroModeActive = 0;
	return;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"Touches moved on look pad" );
  for ( UITouch *touch in [event touchesForView:self] ) {
		
    [self handleTouch:[touch locationInView:self]];
    break;
  }
}

- (void)dealloc {
	[super dealloc];
}


@end
