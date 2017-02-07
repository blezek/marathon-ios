//
//  SavedGameCell.h
//  AlephOne
//
//  Created by Daniel Blezek on 9/6/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagedObjects.h"

@class SaveGameViewController;
@interface SavedGameCell : UITableViewCell {
  UILabel *subject;
  UILabel *storageDate;
  UILabel *playTime;
  UILabel *storageIdentifier; // Make this the MD5 of the save game!
  UILabel *damageGiven;
  UILabel *damageTaken;
  UILabel *shotsFired;
  UILabel *accuracy;
  UIImageView *overheadMap;
  UIImageView *screenShot;
}

- (void)setFields:(SavedGame*) game withController:(SaveGameViewController*)controller;

@property (nonatomic, retain) IBOutlet UILabel *subject;
@property (nonatomic, retain) IBOutlet UILabel *storageDate;
@property (nonatomic, retain) IBOutlet UILabel *playTime;
@property (nonatomic, retain) IBOutlet UILabel *storageIdentifier;
@property (nonatomic, retain) IBOutlet UILabel *damageGiven;
@property (nonatomic, retain) IBOutlet UILabel *damageTaken;
@property (nonatomic, retain) IBOutlet UILabel *shotsFired;
@property (nonatomic, retain) IBOutlet UILabel *accuracy;
@property (nonatomic, retain) IBOutlet UIImageView *overheadMap;
@property (nonatomic, retain) IBOutlet UIImageView *screenShot;


@end
