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
#import "SavedGameCell.h"

@interface SaveGameViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
  IBOutlet UIView *uiView;
  IBOutlet SavedGameCell *savedGameCell;
@private
  NSFetchedResultsController *fetchedResultsController_;
  NSManagedObjectContext *managedObjectContext_;
}

- (IBAction)cancel:(id)sender;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// Create a new game in CoreData, and return
- (SavedGame*)createNewGameFile;

@property (nonatomic, retain) IBOutlet UIView *uiView;
@property (nonatomic, retain) IBOutlet SavedGameCell *savedGameCell;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
