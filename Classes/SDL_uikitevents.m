/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997-2009 Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

    Sam Lantinga
    slouken@libsdl.org
*/
#include "SDL_config.h"

#include "SDL_sysevents.h"
#include "SDL_events_c.h"

#include "SDL_uikitvideo.h"
#include "SDL_uikitevents.h"

#import <Foundation/Foundation.h>
#include "jumphack.h"
// DJB Include helper for USE_SDL_EVENT_LOOP definition
#include "AlephOneHelper.h"
void
UIKit_PumpEvents(_THIS)
{
	/* 
		When the user presses the 'home' button on the iPod
		the application exits -- immediatly.
	 
		Unlike in Mac OS X, it appears there is no way to cancel the termination.
	 
		This doesn't give the SDL user's application time to respond to an SDL_Quit event.
		So what we do is that in the UIApplicationDelegate class (SDLUIApplicationDelegate),
		when the delegate receives the ApplicationWillTerminate message, we execute
		a longjmp statement to get back here, preventing an immediate exit.
	 */	
#ifdef USE_SDL_EVENT_LOOP
  // DJB No longer needed, CADisplayLink loop should handle all events!
	if (setjmp(*jump_env()) == 0) {
    /*
    // DJB Try a different run loop from the app
    NSRunLoop *theRL = [NSRunLoop currentRunLoop];
    BOOL MoreEvents = NO;
    NSString *currentMode = [theRL currentMode];
    currentMode = NSRunLoopCommonModes;
    NSDate* future = [NSDate distantPast];
    */
		/* if we're setting the jump, rather than jumping back */
		SInt32 result;
		do {
      // MoreEvents = [theRL runMode:currentMode beforeDate:future];
			result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE);
		} while(result == kCFRunLoopRunHandledSource);
	}
#endif
}

/* vi: set ts=4 sw=4 expandtab: */
