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

extern void* getLayerFromSDLWindow(SDL_Window *main_screen);
extern void cleanRenderer(SDL_Renderer *renderer);
extern void setDefaultA1View();
extern char* randomName31(); //Returns a random name up to 31 characters.
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
extern void display_net_game_stats_helper();
extern void switchToSDLMenu(); //DCW
extern void getSomeTextFromIOS(char *label, const char *currentText); //DCW
extern bool getLocalPlayer ();
extern float extraFieldOfView ();
extern bool headBelowMedia ();
extern bool playerInTerminal ();
extern void cacheInputPreferences();
extern bool shouldswapJoysticks();
extern void cacheRendererPreferences();
extern void cacheRendererQualityPreferences();
extern bool useClassicVisuals ();
extern bool useShaderRenderer ();
extern bool useShaderPostProcessing ();
extern bool fastStart ();
extern bool usingA1DEBUG ();
extern bool survivalMode ();
extern bool shouldHideHud ();
extern bool shouldAllowDoubleClick ();

extern int helperAlwaysPlayIntro();
extern int helperAutocenter();
extern void setKey(SDL_Keycode key, bool down);
extern void moveMouseRelativeAtInterval(float dx, float dy, double movedInterval); //Move mouse at a NSTimeInterval.
extern void moveMouseRelative(float dx, float dy);
extern void grabMovementDeltasForCurrentFrameAtInterval(double timeStamp); //Cache accumulated deltas for future slurp. Call this immediately at frame start.
extern void slurpMouseDelta(float *dx, float *dy); //Grab accumulated deltas.
extern void helperGetMouseDelta ( int *dx, int *dy );
extern void clearSmartTrigger();
extern bool smartTriggerEngaged();
extern void monsterIsCentered ();
extern void monsterIsOnLeft ();
extern void monsterIsOnRight ();
extern bool isMonsterCentered ();
extern bool isMonsterOnLeft ();
extern bool isMonsterOnRight ();
extern void setSmartFirePrimary(bool fire);

extern bool shouldAutoBot();
extern void doOkInASec();
extern void doOkOnNextDialog( bool ok );
extern bool okOnNextDialog();



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

extern void helperCacheScreenDimension();
extern int helperLongScreenDimension(); //DCW
extern int helperShortScreenDimension(); //DCW
extern float helperScreenScale();


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
