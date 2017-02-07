//
//  Statistics.m
//  AlephOne
//
//  Created by Daniel Blezek on 4/11/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "Statistics.h"
#import "Achievements.h"
#import "GameKit/GameKit.h"
#import "ManagedObjects.h"

#define kWeaponCount 9
static BOOL statsDownloaded = NO;

// Repeated from map.h...
enum /* game difficulty levels */
{
  _wuss_level,
  _easy_level,
  _normal_level,
  _major_damage_level,
  _total_carnage_level,
  NUMBER_OF_GAME_DIFFICULTY_LEVELS
};

float DifficultyMultiplier[NUMBER_OF_GAME_DIFFICULTY_LEVELS] = { 1/10., 1/10., 1/5., 1/2., 1/1. };

@implementation Statistics
@synthesize stats, index, prefixList;

-(id)init {
  if ( (self = [super init]) != nil ) {
    self.prefixList = [NSArray arrayWithObjects:@"Kills", @"Damage", nil];
    self.index = [NSArray arrayWithObjects:
                  @"Fist",
                  @"Pistol",
                  @"PlasmaPistol",
                  @"AssaultRifle",
                  @"MissileLauncher",
                  @"Flamethrower",
                  @"AlienShotgun",
                  @"Shotgun",
                  @"Ball",
                  @"SMG",
                  @"Score",
                  @"Damage",
                  @"Kills",
                  nil];
    [self loadStats];
    if ( [Achievements isAuthenticated] && !statsDownloaded ) {
      statsDownloaded = YES;
      [self downloadStats];
    }


  }
  return self;
}

- (void)reportAchievementsLeavingLevel:(int)completedLevel {
  SavedGame *game = [GameViewController sharedInstance].currentSavedGame;

  // ToDo: report only non-cheating achievements
  
  float percentage = 100.0 * (completedLevel+1) / NumberOfLevels;
  [Achievements reportAchievement:Achievement_Marathon progress:percentage];
  
  if ( [game.bobsLeftAlive intValue] == 0 ) {
    [Achievements reportAchievement:[NSString stringWithFormat:@"BOBBane"] progress:percentage];
  }
  if ( [game.aliensLeftAlive intValue] == 0 ) {
    [Achievements reportAchievement:[NSString stringWithFormat:@"CleanSweep"] progress:percentage];
  }   
  if ( [game.kills intValue] == [game.killsByFist intValue] ) {
    [Achievements reportAchievement:[NSString stringWithFormat:@"Pugilist"] progress:percentage];   
  }
  if ( [game.kills intValue ] == [game.killsByPistol intValue ] ) {
    [Achievements reportAchievement:[NSString stringWithFormat:@"Gunslinger"] progress:percentage];   
  }
#if SCENARIO != 1
  if ( [game.kills intValue ] == [game.killsByShotgun intValue ] ) {
    [Achievements reportAchievement:[NSString stringWithFormat:@"DoubleBarrel"] progress:percentage];   
  }
#endif
  if ( [game.kills intValue ] == [game.killsByMissileLauncher intValue ] ) {
    [Achievements reportAchievement:[NSString stringWithFormat:@"MissileLauncher"] progress:percentage];   
  }
  
  // Vidmaster
  if ( [game.difficulty intValue] == _total_carnage_level ) {
    if ( [game.kills intValue] == [game.killsByFist intValue] ) {
      [Achievements reportAchievement:[NSString stringWithFormat:@"Vidmaster"] progress:percentage];
    }
  }
  
  // Completed the game
  if ( completedLevel == NumberOfLevels ) {
    [Achievements reportScore:@"CompletionTime" value:[game.timeInSeconds longValue]];
    [Achievements reportScore:kSScore value:[game.score intValue]];
    if ( [game.accuracy floatValue] >= 80.0 ) {
      [Achievements reportAchievement:@"SharpShooter" progress:100.0];
    }
    if ( [game.accuracy floatValue] >= 90.0 ) {
      [Achievements reportAchievement:@"Sniper" progress:100.0];
    }
    if ( [game.numberOfSessions intValue] >= 5 ) {
      [Achievements reportAchievement:@"UltaMarathon" progress:100.0];
    }
    if ( [game.numberOfDeaths intValue] == 0 ) {
      [Achievements reportAchievement:@"Untouchable" progress:100.0];
    }
    
  }
  
}


- (void)reportAchievementsForSaveGame {
  SavedGame *game = [GameViewController sharedInstance].currentSavedGame;
  double temp = DifficultyMultiplier[[game.difficulty intValue]]
  * [game.accuracy floatValue] / 100.0 * (
                        [game.damageGiven intValue]
                        - 10 * [game.damageTaken intValue]
                        + 100 * game.killsByFist.intValue
                        + 90 * game.killsByPistol.intValue
                        + 60 * game.killsByPlasmaPistol.intValue
                        + 30 * game.killsByAssaultRifle.intValue
                        + 30 * game.killsByMissileLauncher.intValue
                        + 90 * game.killsByFlamethrower.intValue
                        + 90 * game.killsByAlienShotgun.intValue
                        + 130 * game.killsByShotgun.intValue
                        + 90 * game.killsBySMG.intValue );
  
  int64_t score = (int64_t) temp;
  
  MLog(@"Found score: %d", score );
  int64_t previousScore = game.score.longValue;
  int64_t delta = score - previousScore;
  
  game.score = [NSNumber numberWithLong:score];
  
  // ToDo: Check on what can be reported if we've cheated!!!
  
  // Calculate our score!
  [Achievements reportScore:kSScore value:score];
  [self updateLifetimeScore:delta];
  [self uploadStats];
  

}



-(void)loadStats {
  NSString *cachePath = [NSString stringWithFormat:@"%@/LifetimeAchievements.plist", 
               [[AlephOneAppDelegate sharedAppDelegate] applicationDocumentsDirectory] ];
  self.stats = [NSMutableDictionary dictionaryWithCapacity:10];
  if ( [[NSFileManager defaultManager] fileExistsAtPath:cachePath] ) {
    NSDictionary *temp = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    [self.stats addEntriesFromDictionary:temp];
  }
  for ( NSString *prefix in prefixList ) {
    for ( NSString *k in self.index ) {
      NSString *key = [NSString stringWithFormat:@"%@.%@", prefix, k];
      MLog(@"Computed key: %@", key );
      if ( [self.stats objectForKey:key] == nil ) {
        [self.stats setObject:[NSNumber numberWithFloat:0.0] forKey:key];
      }
    }
  }
}

-(void)saveStats {
  NSString *cachePath = [NSString stringWithFormat:@"%@/LifetimeAchievements.plist", 
                         [[AlephOneAppDelegate sharedAppDelegate] applicationDocumentsDirectory] ];
  [NSKeyedArchiver archiveRootObject:self.stats toFile:cachePath];
}
  
- (void)updateLifetimeScore:(int64_t)delta {
  NSNumber* current = [self.stats objectForKey:@"Score"];
  [self.stats setObject:[NSNumber numberWithInt:(current.intValue + delta)] forKey:@"Score"];
  MLog(@"Updated lifetime stats: %@", self.stats);
  [self saveStats];
}
  

- (void)updateLifetimeKills:(int[])kills  withMultiplier:(float)multiplier{
  [self updateLifetimeStats:kills withMultiplier:multiplier forPrefix:@"Kills"];
}

- (void)updateLifetimeDamage:(int[])damage withMultiplier:(float)multiplier {
  [self updateLifetimeStats:damage withMultiplier:multiplier forPrefix:@"Damage"];
}

- (void)updateLifetimeStats:(int[])counts withMultiplier:(float)multiplier forPrefix:(NSString*)prefix {
  float delta = 0.0;
  for ( int idx = 0; idx < kWeaponCount; idx++ ) {
    NSString *key = [NSString stringWithFormat:@"%@.%@", prefix, [self.index objectAtIndex:idx] ];
    NSNumber* current = [self.stats objectForKey:key];
    [self.stats setObject:[NSNumber numberWithFloat:(current.floatValue + multiplier * counts[idx])] forKey:key];
    delta += multiplier * counts[idx];
  }
  NSNumber* current = [self.stats objectForKey:prefix];
  [self.stats setObject:[NSNumber numberWithFloat:(current.floatValue + delta)] forKey:prefix];
  MLog(@"Updated lifetime stats: %@", self.stats);
  [self saveStats];
}


- (void)uploadStats {
  // Create a score for everything
  NSNumber *v = [self.stats objectForKey:@"Score"];
  [Achievements reportScore:kSLifetimeScore value:v.longValue];
  v = [self.stats objectForKey:@"Damage"];
  [Achievements reportScore:kSLifetimeDamage value:v.longValue];
  
  for ( NSString *prefix in prefixList ) {
    for ( int idx = 0; idx < kWeaponCount; idx++ ) {
      NSString *key = [NSString stringWithFormat:@"%@.%@", prefix, [self.index objectAtIndex:idx] ];
      NSNumber* current = [self.stats objectForKey:key];
      [Achievements reportScore:key value:current.longValue];
    }
  }
}
  
- (void)downloadStats {
  if ( ![Achievements isAuthenticated] ) { return; }
  [GKLeaderboard loadCategoriesWithCompletionHandler:^(NSArray *categories, NSArray *titles, NSError *error) {
    for ( NSString *category in categories ) {
      GKLeaderboard *leaderboard = [[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObjects:[GKLocalPlayer localPlayer].playerID, nil]];
      [leaderboard autorelease];  
      [leaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
        if ( scores == nil ) {
          MLog ( @"Error retrieving scores for %@", category );
          return;
        }
        for ( GKScore *score in scores ) {
          if ( score == nil ) { return; }
          // See if the score reported is bigger than our score
          NSString* key = [score.category substringFromIndex:[AchievementPrefix length]];
          if ( key == nil ) { return; }
          MLog(@"Retrieved score %@ for key %@", score.value, key);
          if ( [self.stats objectForKey:key] != nil ) {
            NSNumber *n = [self.stats objectForKey:key];
            if ( n.longValue < score.value ) {
              [self.stats setObject:[NSNumber numberWithLong:score.value] forKey:key];
            }
          }
        }
      }];
    }
  }];
}

+ (NSString*)difficultyToString:(int)difficulty {
  switch ( difficulty ) {
    case _normal_level: return @"Normal";
    case _major_damage_level: return @"Hard";
    case _total_carnage_level: return @"Nightmare";
      
    case _easy_level:
    case _wuss_level: return @"Easy";
  }
  return @"Easy";
}
      
  
@end
