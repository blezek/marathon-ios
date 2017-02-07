//
//  FilmCell.h
//  AlephOne
//
//  Created by Daniel Blezek on 9/6/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagedObjects.h"

@interface FilmCell : UITableViewCell {
  UILabel *storageDate;
  UILabel *storageIdentifier;
  UILabel *name;
}

- (void)setFields:(Film*)film;

@property (nonatomic, retain) IBOutlet UILabel *storageDate;
@property (nonatomic, retain) IBOutlet UILabel *storageIdentifier;
@property (nonatomic, retain) IBOutlet UILabel *name;
@end
