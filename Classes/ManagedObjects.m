//
//  ManagedObjects.m
//  AlephOne
//
//  Created by Daniel Blezek on 8/24/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "ManagedObjects.h"

@implementation Scenario
@dynamic downloadURL;
@dynamic isDownloaded;
@dynamic name;
@dynamic path;
@dynamic downloadHost;
@dynamic savedGames;
@dynamic films;
@dynamic version;
@dynamic sizeInBytes;
@end

@implementation SavedGame
@dynamic difficulty;
@dynamic filename;
@dynamic mapFilename;
@dynamic lastSaveTime;
@dynamic level;
@dynamic numberOfSessions;
@dynamic scenario;
@dynamic timeInSeconds;
@dynamic damageGiven;
@dynamic damageTaken;
@dynamic shotsFired;
@dynamic accuracy;
@dynamic kills;

// 4-4-2011
@dynamic haveCheated;
@dynamic killsByFist;
@dynamic killsByPistol;
@dynamic killsByPlasmaPistol;
@dynamic killsByAssaultRifle;
@dynamic killsByMissileLauncher;
@dynamic killsByFlamethrower;
@dynamic killsByAlienShotgun;
@dynamic killsByShotgun;
@dynamic killsBySMG;
@dynamic numberOfDeaths;
@dynamic aliensLeftAlive;
@dynamic bobsLeftAlive;
@end

@implementation Film
@dynamic filename;
@dynamic lastSaveTime;
@dynamic scenario;
@dynamic name;
@end