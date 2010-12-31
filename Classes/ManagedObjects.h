//
//  ManagedObjects.h
//  AlephOne
//
//  Created by Daniel Blezek on 8/24/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

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
- (void)addSavedGamesObject:(NSManagedObject *)value;
- (void)removeSavedGamesObject:(NSManagedObject *)value;
- (void)addSavedGames:(NSSet *)value;
- (void)removeSavedGames:(NSSet *)value;

- (void)addFilmsObject:(NSManagedObject *)value;
- (void)removeFilmsObject:(NSManagedObject *)value;
- (void)addFilms:(NSSet *)value;
- (void)removeFilms:(NSSet *)value;

@end

@interface SavedGame : NSManagedObject
{
}
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
