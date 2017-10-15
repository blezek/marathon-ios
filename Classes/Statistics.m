//
//  Statistics.m
//  AlephOne
//
//  Created by Daniel Blezek on 4/11/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "Statistics.h"
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
}
  
- (void)downloadStats {
 
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
