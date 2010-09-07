//
//  SaveGameViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 8/28/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ManagedObjects.h"

@interface SaveGameViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
  IBOutlet UIView *uiView;
@private
  NSFetchedResultsController *fetchedResultsController_;
  NSManagedObjectContext *managedObjectContext_;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// Create a new game in CoreData, and return
- (SavedGame*)createNewGameFile;

@property (nonatomic, retain) UIView *uiView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
