//
//  SaveGameViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 8/28/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FileHandler.h"

@interface SaveGameViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
@private
  NSFetchedResultsController *fetchedResultsController_;
  NSManagedObjectContext *managedObjectContext_;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// Create a new game in CoreData, and return the filename
- (IBAction)createNewGameFile:(FileSpecifier&)file;


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
