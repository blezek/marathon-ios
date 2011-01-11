//
//  FilmViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 8/28/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ManagedObjects.h"
#import "FilmCell.h"

@interface FilmViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate> {
  IBOutlet FilmCell *filmCell;
  IBOutlet UIView *enclosingView;
@private
  NSFetchedResultsController *fetchedResultsController_;
  NSManagedObjectContext *managedObjectContext_;
}

- (IBAction)cancel:(id)sender;
- (IBAction)deleteFilm:(id)sender;
- (IBAction)reallyDelete;
- (IBAction)load:(id)sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)appear;
- (void)disappear;

- (int)numberOfSavedFilms;
- (NSIndexPath*)selectedIndex;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// Create a new film in CoreData, and return
- (Film*)createFilm;

@property (nonatomic, retain) IBOutlet FilmCell *filmCell;
@property (nonatomic, retain) IBOutlet UIView *enclosingView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
