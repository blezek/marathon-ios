//
//  ManagedObjects.h
//  AlephOne
//
//  Created by Daniel Blezek on 8/24/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class Scenario, Film, SavedGame;

@interface Scenario : NSManagedObject
{}
@property (nonatomic, retain) NSString * downloadURL;
@property (nonatomic, retain) NSNumber * isDownloaded;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSNumber * sizeInBytes;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * downloadHost;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSSet* savedGames;
@property (nonatomic, retain) NSSet* films;
@end

// coalesce these into one @interface Scenario (CoreDataGeneratedAccessors) section
@interface Scenario (CoreDataGeneratedAccessors)

- (void)addSavedGamesObject:(SavedGame *)value;
- (void)removeSavedGamesObject:(SavedGame *)value;
- (void)addSavedGames:(NSSet *)value;
- (void)removeSavedGames:(NSSet *)value;

- (void)addFilmsObject:(Film *)value;
- (void)removeFilmsObject:(Film *)value;
- (void)addFilms:(NSSet *)value;
- (void)removeFilms:(NSSet *)value;
@end

@interface SavedGame : NSManagedObject
{}
@property (nonatomic, retain) NSString * difficulty;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * mapFilename;
@property (nonatomic, retain) NSDate * lastSaveTime;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSNumber * numberOfSessions;
@property (nonatomic, retain) NSNumber * timeInSeconds;
@property (nonatomic, retain) NSNumber * damageTaken;
@property (nonatomic, retain) NSNumber * damageGiven;
@property (nonatomic, retain) NSNumber * shotsFired;
@property (nonatomic, retain) NSNumber * accuracy;
@property (nonatomic, retain) NSNumber * kills;
@property (nonatomic, retain) NSManagedObject * scenario;

@property (nonatomic, retain) NSNumber *haveCheated;
@property (nonatomic, retain) NSNumber *killsByFist;
@property (nonatomic, retain) NSNumber *killsByPistol;
@property (nonatomic, retain) NSNumber *numberOfDeaths;
@property (nonatomic, retain) NSNumber *aliensLeftAlive;
@property (nonatomic, retain) NSNumber *bobsLeftAlive;


@end

// coalesce these into one @interface SavedGame (CoreDataGeneratedAccessors) section
@interface SavedGame (CoreDataGeneratedAccessors)
@end

@interface Film : NSManagedObject
{
}
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSDate * lastSaveTime;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSManagedObject * scenario;

@end

// coalesce these into one @interface SavedGame (CoreDataGeneratedAccessors) section
@interface Film (CoreDataGeneratedAccessors)
@end
