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
#include "FileHandler.h"

char *getDataDir();
char* getLocalDataDir();
void helperBringUpHUD();
bool helperNewGame();
void helperSaveGame();
void helperLoadGame();

// Choose a saved game
int helperChooseSaveGame ( FileSpecifier &saved_game );
