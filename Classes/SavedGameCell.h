//
//  SavedGameCell.h
//  AlephOne
//
//  Created by Daniel Blezek on 9/6/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagedObjects.h"

@interface SavedGameCell : UITableViewCell {
  UILabel *subject;
  UILabel *storageDate;
  UILabel *playTime;
  UILabel *storageIdentifier; // Make this the MD5 of the save game!
  UIImageView *overheadMap;
  UIImageView *screenShot;
}

- (void)setFields:(SavedGame*) game;

@property (nonatomic, retain) IBOutlet UILabel *subject;
@property (nonatomic, retain) IBOutlet UILabel *storageDate;
@property (nonatomic, retain) IBOutlet UILabel *playTime;
@property (nonatomic, retain) IBOutlet UILabel *storageIdentifier;
@property (nonatomic, retain) IBOutlet UIImageView *overheadMap;
@property (nonatomic, retain) IBOutlet UIImageView *screenShot;


@end
