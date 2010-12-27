//
//  FilmCell.m
//  AlephOne
//
//  Created by Daniel Blezek on 9/6/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "FilmCell.h"

#define secondsPerHour 3600

@implementation FilmCell
@synthesize storageDate, storageIdentifier;

- (void)setFields:(Film*) game {
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  [formatter setDateStyle:NSDateFormatterShortStyle];
  self.storageDate.text = [NSString stringWithFormat:@"Storage Date: %@", [formatter stringFromDate:game.lastSaveTime]];
  self.storageIdentifier.text = [NSString stringWithFormat:@"Storage Identifier: 0x%x", [game hash]];
}

- (void)dealloc {
    [super dealloc];
}


@end
