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
@synthesize storageDate, storageIdentifier, name;

- (void)setFields:(Film*) film {
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  [formatter setDateStyle:NSDateFormatterShortStyle];
  self.name.text = film.name;
  self.storageDate.text = [NSString stringWithFormat:@"Storage Date: %@", [formatter stringFromDate:film.lastSaveTime]];
  self.storageIdentifier.text = [NSString stringWithFormat:@"Storage Identifier: 0x%x", [film hash]];
}

- (void)dealloc {
    [super dealloc];
}


@end
