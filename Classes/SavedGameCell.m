//
//  SavedGameCell.m
//  AlephOne
//
//  Created by Daniel Blezek on 9/6/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "SavedGameCell.h"
#import "SaveGameViewController.h"
#define secondsPerHour 3600

@implementation SavedGameCell
@synthesize subject, storageDate, playTime, storageIdentifier;
@synthesize overheadMap, screenShot;
@synthesize damageGiven, damageTaken, shotsFired, accuracy;


- (void)setFields:(SavedGame*)game withController:(SaveGameViewController*)controller {
  self.subject.text = [NSString stringWithFormat:@"Location: %@", game.level];
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  [formatter setDateStyle:NSDateFormatterShortStyle];
  self.storageDate.text = [NSString stringWithFormat:@"Storage Date: %@", [formatter stringFromDate:game.lastSaveTime]];
  self.storageIdentifier.text = [NSString stringWithFormat:@"Storage Identifier: 0x%x", [game hash]];
  int hours, minutes, seconds;
  int totalPlayTime = [[game timeInSeconds] intValue];
  hours = (int) ( totalPlayTime / (double)(secondsPerHour) );
  totalPlayTime -= hours * secondsPerHour;
  minutes = (int) ( totalPlayTime / 60.0 );
  totalPlayTime -= minutes * 60;
  seconds = totalPlayTime;
  self.playTime.text = [NSString stringWithFormat:@"Elapsed Time: %02d:%02d:%02d", hours, minutes, seconds];
  
  self.damageGiven.text = [NSString stringWithFormat:@"Damage Given: %@", [game damageGiven]];
  self.damageTaken.text = [NSString stringWithFormat:@"Damage Taken: %@", [game damageTaken]];
  self.shotsFired.text = [NSString stringWithFormat:@"Shots Fired: %@", [game shotsFired]];
  self.accuracy.text = [NSString stringWithFormat:@"Accuracy: %d%%", (int)[[game accuracy] floatValue]];
  
  // load the Overhead map
  if ( game.mapFilename != nil ) {
    self.overheadMap.image = [UIImage imageWithContentsOfFile:[controller fullPath:game.mapFilename]];
  }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
      
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
