/*

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

*/

/*
 *  mouse_sdl.cpp - Mouse handling, SDL specific implementation
 *
 *  May 16, 2002 (Woody Zenfell):
 *      Configurable mouse sensitivity
 *      Semi-hacky scheme to let mouse buttons simulate keypresses
 */

#include "cseries.h"
#include <math.h>

#include "mouse.h"
#include "player.h"
#include "shell.h"
#include "preferences.h"
#include "screen.h"

#include "interface.h"

#ifdef __APPLE__
#include "mouse_cocoa.h"
#endif

#include "AlephOneHelper.h"

// Global variables
static bool mouse_active = false;
static uint8 button_mask = 0;		// Mask of enabled buttons
static _fixed snapshot_delta_yaw, snapshot_delta_pitch;
static _fixed snapshot_delta_scrollwheel;
static int snapshot_delta_x, snapshot_delta_y;

//DCW
static float lost_x, lost_y;
static bool smooth_mouselook;

/*
 *  Initialize in-game mouse handling
 */

void enter_mouse(short type)
{
	if (type != _keyboard_or_game_pad) {
#ifdef __APPLE__
      //DCW no mouse on ios
    //if (input_preferences->raw_mouse_input)
			//OSX_Mouse_Init();
#endif
    
    //DCW clear mouse deltas.
    float dx, dy;
    slurpMouseDelta(&dx, &dy);
    
		SDL_SetHint(SDL_HINT_MOUSE_RELATIVE_MODE_WARP, input_preferences->raw_mouse_input ? "0" : "1");
		SDL_SetRelativeMouseMode(SDL_TRUE);
		mouse_active = true;
		snapshot_delta_yaw = snapshot_delta_pitch = 0;
		snapshot_delta_scrollwheel = 0;
		snapshot_delta_x = snapshot_delta_y = 0;
    lost_x = lost_y = 0;
		button_mask = 0;	// Disable all buttons (so a shot won't be fired if we enter the game with a mouse button down from clicking a GUI widget)
		recenter_mouse();
	}
}


/*
 *  Shutdown in-game mouse handling
 */

void exit_mouse(short type)
{
	if (type != _keyboard_or_game_pad) {
		SDL_SetRelativeMouseMode(SDL_FALSE);
		mouse_active = false;
#ifdef __APPLE__
      // DCW no mouse on ios
		//OSX_Mouse_Shutdown();
#endif
	}
}


/*
 *  Calculate new center mouse position when screen size has changed
 */

void recenter_mouse(void)
{
	if (mouse_active) {
		MainScreenCenterMouse();
	}
}

static inline float MIX(float start, float end, float factor)
{
	return (start * (1.f - factor)) + (end * factor);
}

/*
 *  Take a snapshot of the current mouse state
 */

void mouse_idle(short type)
{
	if (mouse_active) {
    
  //DCW Not present on ios
/*#ifdef __APPLE__
		// In raw mode, get unaccelerated deltas from HID system
		if (input_preferences->raw_mouse_input)
			OSX_Mouse_GetMouseMovement(&snapshot_delta_x, &snapshot_delta_y);
#endif*/
		
    
		// Calculate axis deltas
		float dx = snapshot_delta_x;
		float dy = -snapshot_delta_y;
		snapshot_delta_x = 0;
		snapshot_delta_y = 0;
    
    slurpMouseDelta(&dx, &dy);
    if(dx>0 || dy>0)
    {
      snapshot_delta_x = 0;
      snapshot_delta_y = 0;
    }
    
		// Mouse inversion
		if (TEST_FLAG(input_preferences->modifiers, _inputmod_invert_mouse))
			dy = -dy;
		
		// scale input by sensitivity
		const float sensitivityScale = 1.f / (66.f * FIXED_ONE);
		float sx = sensitivityScale * input_preferences->sens_horizontal;
		float sy = sensitivityScale * input_preferences->sens_vertical;
		switch (input_preferences->mouse_accel_type)
		{
			case _mouse_accel_classic:
				sx *= MIX(1.f, fabs(dx * sx) * 4.f, input_preferences->mouse_accel_scale);
				sy *= MIX(1.f, fabs(dy * sy) * 4.f, input_preferences->mouse_accel_scale);
				break;
			case _mouse_accel_none:
			default:
				break;
		}
		dx *= sx;
		dy *= sy;
    
      //Add post-sensitivity lost precision, in case we can use it this time around.
    dx += lost_x;
    dy += lost_y;
    
		// 1 dx unit = 1 * 2^ABSOLUTE_YAW_BITS * (360 deg / 2^ANGULAR_BITS)
		//           = 90 deg
		//
		// 1 dy unit = 1 * 2^ABSOLUTE_PITCH_BITS * (360 deg / 2^ANGULAR_BITS)
		//           = 22.5 deg
		
		// Largest dx for which both -dx and +dx can be represented in 1 action flags bitset
		float dxLimit = 0.5f - 1.f / (1<<ABSOLUTE_YAW_BITS);  // 0.4921875 dx units (~44.30 deg)
		
		// Largest dy for which both -dy and +dy can be represented in 1 action flags bitset
		float dyLimit = 0.5f - 1.f / (1<<ABSOLUTE_PITCH_BITS);  // 0.46875 dy units (~10.55 deg)
		
		dxLimit = MIN(dxLimit, input_preferences->mouse_max_speed);
		dyLimit = MIN(dyLimit, input_preferences->mouse_max_speed);
		
		dx = PIN(dx, -dxLimit, dxLimit);
		dy = PIN(dy, -dyLimit, dyLimit);
		
		snapshot_delta_yaw   = static_cast<_fixed>(dx * FIXED_ONE);
		snapshot_delta_pitch = static_cast<_fixed>(dy * FIXED_ONE);
    
    //DCW what the fuck is the point of keeping the lower 9 or whatever bits in there? They just get thrown out later anyway...
    //Lets bitshift off the unused bits, so we can add in that lost precision the next time around.
    snapshot_delta_yaw >>= (FIXED_FRACTIONAL_BITS-ABSOLUTE_YAW_BITS);
    snapshot_delta_yaw <<= (FIXED_FRACTIONAL_BITS-ABSOLUTE_YAW_BITS);
    snapshot_delta_pitch >>= (FIXED_FRACTIONAL_BITS-ABSOLUTE_PITCH_BITS);
    snapshot_delta_pitch <<= (FIXED_FRACTIONAL_BITS-ABSOLUTE_PITCH_BITS);

    //DCW Lets track how much precision we lost, so we can stuff it back into the input next time this function is called.
    lost_x = (dx * (float)FIXED_ONE) - (float)snapshot_delta_yaw;
    lost_y = (dy * (float)FIXED_ONE) - (float)snapshot_delta_pitch;
    lost_x /= (float)FIXED_ONE;
    lost_y /= (float)FIXED_ONE;
    
    short game_state = get_game_state();
    smooth_mouselook = smoothMouselookPreference() ;//&& (game_state==_game_in_progress || game_state ==_switch_demo) && (game_state==_single_player || game_state==_network_player);

 	}
}

//DCW
//Returns the currently not-represented mouse precision as a fraction of a yaw and pitch unit.
//This might be useful to render the view with more precise yaw or pitch.
float lostMousePrecisionX() { return (lost_x*(float)FIXED_ONE)/512.0; }
float lostMousePrecisionY() { return (lost_y*(float)FIXED_ONE)/2048.0; }


double interpolateAngleTable( int16 *theTable, int16 yaw ){
  //DCW mouselook smoothing test
  double table_value = double(theTable[yaw]);
  double adjacent_table_value = theTable[nextNearestYawIndex(yaw)];
  
  return interpolateUsingLostX(adjacent_table_value, table_value);
}

double interpolateUsingLostX(double adjacent_value, double value) {
  double xPercentage = fabs(lostMousePrecisionX());
  return(xPercentage*adjacent_value + (1.0-xPercentage)*value);
}

double interpolateUsingLostY(double adjacent_value, double value) {
  double yPercentage = fabs(lostMousePrecisionY());
  return(yPercentage*adjacent_value + (1.0-yPercentage)*value);
}

double cosine_table_calculated(double i) {
  double two_pi= 8.0*atan(1.0);
  double theta= two_pi*(double)i/(double)NUMBER_OF_ANGLES;
  
  return ((double)TRIG_MAGNITUDE*cos(theta)+0.5);
}
double sine_table_calculated(double i) {
  double two_pi= 8.0*atan(1.0);
  double theta= two_pi*(double)i/(double)NUMBER_OF_ANGLES;
  
  return ((double)TRIG_MAGNITUDE*sin(theta)+0.5);
}
bool shouldSmoothMouselook(){
  return smooth_mouselook;
}
int16 nextNearestYawIndex( int16 yaw ){
  if (lostMousePrecisionX() > 0){
    if( (yaw + 1) == NUMBER_OF_ANGLES ) {
      return 0;
    } else {
      return yaw + 1;
    }
  } else {
    if( (yaw - 1) < 0 ) {
      return NUMBER_OF_ANGLES-1;
    } else {
      return yaw - 1;
    }
  }
}

int16 nextNearestPitchIndex( int16 pitch ){
  //Unlike yaw, pitch does not wrap, so we clamp at the ends of the array.
  if (lostMousePrecisionY() > 0){
    if( (pitch + 1) == NUMBER_OF_ANGLES ) {
      return pitch;
    } else {
      return pitch + 1;
    }
  } else {
    if( (pitch - 1) < 0 ) {
      return pitch;
    } else {
      return pitch - 1;
    }
  }
}

double interpolateAngleTableForPitch( int16 *theTable, int16 pitch ){
  //DCW mouselook smoothing test
  double table_value = double(theTable[pitch]);
  double adjacent_table_value = theTable[nextNearestPitchIndex(pitch)];
  
  return interpolateUsingLostY(adjacent_table_value, table_value);
}

/*
 *  Return mouse state
 */

void test_mouse(short type, uint32 *flags, _fixed *delta_yaw, _fixed *delta_pitch, _fixed *delta_velocity)
{
	if (mouse_active) {
		*delta_yaw = snapshot_delta_yaw;
		*delta_pitch = snapshot_delta_pitch;
		*delta_velocity = 0;  // Mouse-driven player velocity is unimplemented

		snapshot_delta_yaw = snapshot_delta_pitch = 0;
	} else {
		*delta_yaw = 0;
		*delta_pitch = 0;
		*delta_velocity = 0;
	}
}


void
mouse_buttons_become_keypresses(Uint8* ioKeyMap)
{
		uint8 buttons = SDL_GetMouseState(NULL, NULL);
		uint8 orig_buttons = buttons;
		buttons &= button_mask;				// Mask out disabled buttons

        for(int i = 0; i < NUM_SDL_MOUSE_BUTTONS; i++) {
            ioKeyMap[AO_SCANCODE_BASE_MOUSE_BUTTON + i] =
                (buttons & SDL_BUTTON(i+1)) ? SDL_PRESSED : SDL_RELEASED;
        }
		ioKeyMap[AO_SCANCODE_MOUSESCROLL_UP] = (snapshot_delta_scrollwheel > 0) ? SDL_PRESSED : SDL_RELEASED;
		ioKeyMap[AO_SCANCODE_MOUSESCROLL_DOWN] = (snapshot_delta_scrollwheel < 0) ? SDL_PRESSED : SDL_RELEASED;
		snapshot_delta_scrollwheel = 0;

        button_mask |= ~orig_buttons;		// A button must be released at least once to become enabled
}

/*
 *  Hide/show mouse pointer
 */

void hide_cursor(void)
{
	SDL_ShowCursor(0);
}

void show_cursor(void)
{
	SDL_ShowCursor(1);
}


void mouse_scroll(bool up)
{
	if (up)
		snapshot_delta_scrollwheel += 1;
	else
		snapshot_delta_scrollwheel -= 1;
}

void mouse_moved(int delta_x, int delta_y)
{
	snapshot_delta_x += delta_x;
	snapshot_delta_y += delta_y;
}
