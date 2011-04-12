//
//  Statistics.m
//  AlephOne
//
//  Created by Daniel Blezek on 4/11/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "Statistics.h"
#import "Achievements.h"

@implementation Statistics
@synthesize stats, index;

-(id)init {
  if ( self = [super init] ) {
    [self loadStats];
    self.index = [NSArray arrayWithObjects:
                  @"Fist",
                  @"PlasmaPistol",
                  @"AssaultRifle",
                  @"MissileLauncher",
                  @"Flamethrower",
                  @"AlienShotgun",
                  @"Shotgun",
                  @"Ball",
                  @"SMG", nil];

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
  for ( NSString *key in self.index ) {
    if ( [self.stats objectForKey:key] == nil ) {
      [self.stats setObject:[NSNumber numberWithInt:0] forKey:key];
    }
    // Lifetime score
    [self.stats setObject:[NSNumber numberWithInt:0] forKey:@"Score"];
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
  

- (void)updateLifetimeKills:(int[])kills {
  for ( int idx = 0; idx < self.index.count; idx++ ) {
    NSString *key = [self.index objectAtIndex:idx];
    NSNumber* current = [self.stats objectForKey:key];
    [self.stats setObject:[NSNumber numberWithInt:(current.intValue + kills[idx])] forKey:key];
  }
  MLog(@"Updated lifetime stats: %@", self.stats);
  [self saveStats];
}

- (void)uploadStats {
  // Create a score for everything
  NSNumber *v = [self.stats objectForKey:@"Score"];
  [Achievements reportScore:Score_LifetimeScore value:v.intValue];
}
  
- (void)downloadStats {
}

  
  
@end
