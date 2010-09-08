//
//  SavedGameCell.m
//  AlephOne
//
//  Created by Daniel Blezek on 9/6/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "SavedGameCell.h"


@implementation SavedGameCell
@synthesize subject, storageDate, playTime, storageIdentifier;
@synthesize overheadMap, screenShot;

- (void)setFields:(SavedGame*) game {
  self.subject.text = [NSString stringWithFormat:@"Location: %@", game.level];
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  [formatter setDateStyle:NSDateFormatterShortStyle];
  self.storageDate.text = [NSString stringWithFormat:@"Storage Date: %@", [formatter stringFromDate:game.lastSaveTime]];
  self.storageIdentifier.text = [NSString stringWithFormat:@"Storage Identifier: 0x%x", [game hash]];
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
