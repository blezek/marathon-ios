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
@dynamic savedGames;
@end

@implementation SavedGame
@dynamic difficulty;
@dynamic filename;
@dynamic lastSaveTime;
@dynamic level;
@dynamic numberOfSessions;
@dynamic scenario;
@dynamic timeInSeconds;
@end