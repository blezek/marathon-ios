#ifndef __MOUSE_H
#define __MOUSE_H

/*
MOUSE.H

	Copyright (C) 1991-2001 and beyond by Bungie Studios, Inc.
	and the "Aleph One" developers.
 
	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	This license is contained in the file "COPYING",
	which is included with this source code; it is available online at
	http://www.gnu.org/licenses/gpl.html

Tuesday, January 17, 1995 2:53:17 PM  (Jason')

    May 16, 2002 (Woody Zenfell):
        semi-hacky scheme in SDL to let mouse buttons simulate keypresses
*/

#include "cstypes.h"

void enter_mouse(short type);
void test_mouse(short type, uint32 *action_flags, _fixed *delta_yaw, _fixed *delta_pitch, _fixed *delta_velocity);
void exit_mouse(short type);
void mouse_idle(short type);
void recenter_mouse(void);

//DCW
float lostMousePrecisionX();
float lostMousePrecisionY();
double interpolateAngleTable( int16 *theTable, int16 yaw );
double interpolateAngleTableForPitch( int16 *theTable, int16 pitch );
double interpolateUsingLostX(double adjacent_value, double value);
double interpolateUsingLostY(double adjacent_value, double value);
double cosine_table_calculated(double i);
double sine_table_calculated(double i);
bool shouldSmoothMouselook();
int16 nextNearestYawIndex( int16 yaw );
int16 nextNearestPitchIndex( int16 pitch );

// ZZZ: stuff of various hackiness levels to pretend mouse buttons are keys
void mouse_buttons_become_keypresses(Uint8* ioKeyMap);
void mouse_scroll(bool up);
void mouse_moved(int delta_x, int delta_y);

#define NUM_SDL_MOUSE_BUTTONS 8   // since SDL_GetMouseState() returns 8 bits
#define AO_SCANCODE_BASE_MOUSE_BUTTON 400 // this is button 1's pseudo-keysym
#define AO_SCANCODE_MOUSESCROLL_UP 405    // stored as mouse button 6
#define AO_SCANCODE_MOUSESCROLL_DOWN 406  // stored as mouse button 7

#endif
