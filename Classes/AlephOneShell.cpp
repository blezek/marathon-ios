/*
 *  AlephOneShell.cpp
 *  AlephOne
 *
 *  Created by Daniel Blezek on 9/1/10.
 *  Copyright 2010 SDG Productions. All rights reserved.
 *
 */

#include "AlephOneShell.h"


#include "cseries.h"

#include "map.h"
#include "monsters.h"
#include "player.h"
#include "render.h"
#include "shell.h"
#include "interface.h"
#include "SoundManager.h"
#include "fades.h"
#include "screen.h"
#include "Music.h"
#include "images.h"
#include "vbl.h"
#include "preferences.h"
#include "tags.h" /* for scenario file type.. */
#include "network_sound.h"
#include "mouse.h"
#include "screen_drawing.h"
#include "computer_interface.h"
#include "game_wad.h" /* yuck... */
#include "game_window.h" /* for draw_interface() */
#include "extensions.h"
#include "items.h"
#include "interface_menus.h"
#include "weapons.h"
#ifdef HAVE_LUA
#include "lua_script.h"
#endif

#include "Crosshairs.h"
#include "OGL_Render.h"
#include "FileHandler.h"
#include "Plugins.h"

#include "mytm.h"       // mytm_initialize(), for platform-specific shell_*.h

#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <sstream>
#include <boost/lexical_cast.hpp>

#include "resource_manager.h"
#include "sdl_dialogs.h"
#include "sdl_fonts.h"
#include "sdl_widgets.h"

#include "TextStrings.h"

#ifdef HAVE_CONFIG_H
#include "confpaths.h"
#endif

#include <ctime>
#include <exception>
#include <algorithm>
#include <vector>

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#ifdef HAVE_OPENGL
#include "OGL_Headers.h"
#endif

#ifdef HAVE_SDL_NET_H
#include <SDL_net.h>
#endif

#ifdef HAVE_PNG
#include "IMG_savepng.h"
#endif

#ifdef HAVE_SDL_IMAGE
#include "SDL_image.h"
#if defined(__WIN32__)
#include "alephone32.xpm"
#elif !(defined(__APPLE__) && defined(__MACH__)) && !defined(__MACOS__)
#include "alephone.xpm"
#endif
#endif

#ifdef __WIN32__
#include <windows.h>
#endif

#include "alephversion.h"

#include "Logging.h"
#include "network.h"
#include "Console.h"

extern void process_event(const SDL_Event &event);
extern void execute_timer_tasks(uint32 time);


void initialize_application(void);
void AlephOneInitialize() {
  initialize_application();
}

static uint32 lastTimeThroughLoop = 0;

// Unlike the original, we just want to run one pass through.  Leave the scheduling to
// CADisplayLink
const uint32 TICKS_BETWEEN_EVENT_POLL = 167; // 6 Hz
void AlephOneMainLoop()
{
  uint32 last_event_poll = 0;
  short game_state;
  
  game_state = get_game_state();
  uint32 cur_time = SDL_GetTicks();
  bool yield_time = false;
  bool poll_event = false;
    
  switch (game_state) {
    case _game_in_progress:
    case _change_level:
      if (Console::instance()->input_active() || cur_time - last_event_poll >=
          TICKS_BETWEEN_EVENT_POLL) {
        poll_event = true;
        last_event_poll = cur_time;
      }
      else {
        SDL_PumpEvents ();                                      // This ensures a responsive keyboard control
      }
      break;
        
    case _display_intro_screens:
    case _display_main_menu:
    case _display_chapter_heading:
    case _display_prologue:
    case _display_epilogue:
    case _begin_display_of_epilogue:
    case _display_credits:
    case _display_intro_screens_for_demo:
    case _display_quit_screens:
    case _displaying_network_game_dialogs:
      yield_time = interface_fade_finished();
      poll_event = true;
      break;
      
    case _close_game:
    case _switch_demo:
    case _revert_game:
      yield_time = poll_event = true;
      break;
  }
  
  if (poll_event) {
    global_idle_proc();
    
    while (true) {
      SDL_Event event;
      bool found_event = SDL_PollEvent(&event);
      
      if (yield_time) {
        // The game is not in a "hot" state, yield time to other
        // processes by calling SDL_Delay() but only try for a maximum
        // of 30ms
        int num_tries = 0;
        while (!found_event && num_tries < 3) {
          SDL_Delay(10);
          found_event = SDL_PollEvent(&event);
          num_tries++;
        }
        yield_time = false;
      } else if (!found_event)
        break;
      
      if (found_event)
        process_event(event); 
    }
    
  }
  
  execute_timer_tasks(SDL_GetTicks());
    idle_game_state(SDL_GetTicks());
  
  if (game_state == _game_in_progress &&
      !graphics_preferences->hog_the_cpu &&
      (TICKS_PER_SECOND - (SDL_GetTicks() - cur_time)) > 10) {
    SDL_Delay(1);
  }

  
  if ( cur_time - lastTimeThroughLoop > 1000 ) {
    // printf( "This time took %d ticks\n", SDL_GetTicks() - cur_time );
    lastTimeThroughLoop = cur_time;
  }
}

