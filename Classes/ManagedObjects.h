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
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSSet* savedGames;
@end

// coalesce these into one @interface Scenario (CoreDataGeneratedAccessors) section
@interface Scenario (CoreDataGeneratedAccessors)
- (void)addSavedGamesObject:(NSManagedObject *)value;
- (void)removeSavedGamesObject:(NSManagedObject *)value;
- (void)addSavedGames:(NSSet *)value;
- (void)removeSavedGames:(NSSet *)value;

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
@property (nonatomic, retain) NSManagedObject * scenario;
@end

// coalesce these into one @interface SavedGame (CoreDataGeneratedAccessors) section
@interface SavedGame (CoreDataGeneratedAccessors)
@end
