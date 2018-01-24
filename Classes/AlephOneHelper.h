//
//  AlephOneHelper.h
//  AlephOne
//
//  Created by Daniel Blezek on 5/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include "SDL.h"

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
extern char* getLocalPrefsDir(); //DCW
extern char* getLocalTmpDir(); //DCW
extern char* LANIP( char *prefix, char *suffix);
extern void  overrideSomeA1Prefs();//DCW 
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
extern void switchToSDLMenu(); //DCW
extern void getSomeTextFromIOS(char *label, const char *currentText); //DCW
extern bool headBelowMedia ();

extern int helperAlwaysPlayIntro();
extern int helperAutocenter();
extern void setKey(SDL_Keycode key, bool down);
extern void moveMouseRelative(float dx, float dy);
extern void moveMouseRelativeAcceleratedOverTime(float dx, float dy, float timeInterval);
extern void slurpMouseDelta(float *dx, float *dy);
extern void helperGetMouseDelta ( int *dx, int *dy );
extern void clearSmartTrigger();
extern bool smartTriggerEngaged();
extern void monsterIsCentered ();
extern void setSmartFirePrimary(bool fire);
extern void setSmartFireSecondary(bool fire);

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

// Picked something up
extern void helperPickedUp ( short itemType );

// Gamma from settings
extern float helperGamma();

//Acessor for mouse smoothing preference
extern bool smoothMouselookPreference();

// Pause alpho
extern GLfloat helperPauseAlpha();

  //DCW
extern Uint8 fake_key_map[SDL_NUM_SCANCODES];

// C linkage
#if defined(__cplusplus)
extern "C" {
#endif
  int helperRunningOniPad();
  int helperRetinaDisplay();
  int helperOpenGLWidth();
  int helperOpenGLHeight();
	
	int helperLongScreenDimension(); //DCW
	int helperShortScreenDimension(); //DCW
#if defined(__cplusplus)
}
#endif
