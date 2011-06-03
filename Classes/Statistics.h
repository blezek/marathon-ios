//
//  Statistics.h
//  AlephOne
//
//  Created by Daniel Blezek on 4/11/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlephOneAppDelegate.h"

extern float DifficultMultiplier[];

@interface Statistics : NSObject {
  NSMutableDictionary *stats;
  NSArray *index;
  NSArray *prefixList;
}

- (id)init;
- (void)loadStats;
- (void)saveStats;
- (void)updateLifetimeKills:(int[])kills withMultiplier:(float)multiplier;
- (void)updateLifetimeScore:(int64_t)delta;
- (void)updateLifetimeDamage:(int[])dammage withMultiplier:(float)multiplier;
- (void)updateLifetimeStats:(int[])dammage withMultiplier:(float)multiplier forPrefix:(NSString*)prefix;
- (void)uploadStats;
- (void)downloadStats;
- (NSString*)difficultyToString:(int)difficulty;

// Called when leaving a level
- (void)reportAchievementsLeavingLevel:(int)completedLevel;
// Called when saving a game
- (void)reportAchievementsForSaveGame;

@property (retain, nonatomic) NSMutableDictionary *stats;
@property (retain, nonatomic) NSArray *index;
@property (retain, nonatomic) NSArray *prefixList;

@end
