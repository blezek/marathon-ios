//
//  AlephOneHelper.h
//  AlephOne
//
//  Created by Daniel Blezek on 5/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifdef __IPAD__
// #define iWidth 1024
// #define iHeight 768
#else
// #define iWidth 480
// #define iHeight 320
#endif

// Do we use CADisplayLoop or SDL events?
// #define USE_SDL_EVENT_LOOP 1
#define USE_CADisplayLoop 1

extern char *getDataDir();
extern char* getLocalDataDir();
extern void helperBringUpHUD();

extern int helperNewGame();
extern void helperSaveGame();
extern void helperHideHUD();
extern void helperBeginTeleportOut();
extern void helperTeleportInLevel();
extern void helperEpilog();
extern void helperGameFinished();
extern void helperHandleLoadGame();
extern void helperDoPreferences();
extern void printGLError ( const char* message );
extern void pumpEvents();
extern void startProgress ( int t );
extern void progressCallback ( int d );
extern void stopProgress();
extern int getOpenGLESVersion();
extern void helperPlayerKilled();

extern int helperAlwaysPlayIntro();
extern int helperAutocenter();
extern void helperGetMouseDelta ( int *dx, int *dy );

// Switch weapons
extern void helperSwitchWeapons(int weapon);

// Excuses, excuses
extern void helperQuit();
extern void helperNetwork();

extern void helperEndReplay();
extern void helperSetPreferences(int notifySoundManager);

// Film helpers
extern void helperHandleSaveFilm();
extern void helperHandleLoadFilm();

// Help track hits!
extern void helperNewProjectile ( short projectile_index, short which_weapon, short which_trigger );

extern void helperProjectileHit ( short projectile_index, int damage );
extern void helperProjectileKill ( short projectile_index );

// Starting level
extern short helperGetEntryLevelNumber();

// Gamma from settings
extern float helperGamma();

// Pause alpho
extern GLfloat helperPauseAlpha();

// C linkage
#if defined(__cplusplus)
extern "C" {
#endif
  int helperRunningOniPad();
  int helperRetinaDisplay();
  int helperOpenGLWidth();
  int helperOpenGLHeight();
#if defined(__cplusplus)
}
#endif