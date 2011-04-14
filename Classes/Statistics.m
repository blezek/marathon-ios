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

#define kWeaponCount 9

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




@implementation Statistics
@synthesize stats, index, prefixList;

-(id)init {
  if ( self = [super init] ) {
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

  }
  return self;
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
      [leaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
        if ( scores == nil ) {
          MLog ( @"Error retrieving scores for %@", category );
          return;
        }
        for ( GKScore *score in scores ) {
          // See if the score reported is bigger than our score
          if ( [self.stats objectForKey:score.category] != nil ) {
            NSNumber *n = [self.stats objectForKey:score.category];
            if ( n.longValue < score.value ) {
              [self.stats setObject:[NSNumber numberWithLong:score.value] forKey:score.category];
            }
          }
        }
      }];
    }
  }];
  
}

- (NSString*)difficultyToString:(int)difficulty {
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
