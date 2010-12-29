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

extern bool helperNewGame();
extern void helperSaveGame();
extern void helperHideHUD();
extern void helperBeginTeleportOut();
extern void helperEpilog();
extern void helperHandleLoadGame();
extern void helperDoPreferences();
extern void printGLError ( const char* message );
extern void pumpEvents();
extern void startProgress ( int t );
extern void progressCallback ( int d );
extern void stopProgress();
extern int getOpenGLESVersion();
extern void helperPlayerKilled();
extern void helperQuit();
extern void helperEndReplay();
extern void helperSetPreferences(bool notifySoundManager);

// Film helpers
extern void helperHandleSaveFilm();
extern void helperHandleLoadFilm();

// Help track hits!
extern void helperNewProjectile ( short projectile_index, short which_weapon, short which_trigger );
extern void helperProjectileHit ( short projectile_index );

// Starting level
extern short helperGetEntryLevelNumber();

// Gamma from settings
extern float helperGamma();