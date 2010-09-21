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
extern void helperHandleLoadGame();
