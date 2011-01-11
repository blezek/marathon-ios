//
//  SaveGameViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 8/28/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "FilmViewController.h"
#import "AlephOneAppDelegate.h"
#import "FilmCell.h"
#import "GameViewController.h"
#include "preferences.h"
#import "map.h"
#import "Effects.h"

@implementation FilmViewController
@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;
@synthesize filmCell;
@synthesize enclosingView;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    // Custom initialization
    MLog ( @"inside initWithNib" );
    self.managedObjectContext = [AlephOneAppDelegate sharedAppDelegate].managedObjectContext;
  }
  return self;
}
           
- (void)viewDidLoad {
  [super viewDidLoad];
  self.managedObjectContext = [AlephOneAppDelegate sharedAppDelegate].managedObjectContext;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 200.0;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return NO;
}

#pragma mark -
#pragma mark Animations

- (void)appear {
  self.enclosingView.hidden = NO;
  CAAnimation* group = [Effects appearAnimation];
  for ( UIView *v in self.enclosingView.subviews ) {
    [v.layer addAnimation:group forKey:nil];
  }
  [self.enclosingView.layer addAnimation:group forKey:nil];
}
  
- (void)disappear {
  CAAnimation* group = [Effects disappearAnimation];

  for ( UIView *v in self.enclosingView.subviews ) {
    [v.layer addAnimation:group forKey:nil];
  }
  [self.enclosingView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.69];
}


#pragma mark -
#pragma mark File Methods

- (IBAction)cancel:(id)sender {
  [[GameViewController sharedInstance] chooseFilmCanceled];
}

- (NSIndexPath*)selectedIndex {
  NSArray *paths = [self.tableView indexPathsForVisibleRows];
  if ( [paths count] > 0 ) {
    return [paths objectAtIndex:0];
  } else {
    return nil;
  }
}

- (IBAction)deleteFilm:(id)sender {
  if ( [self selectedIndex] == nil ) { return; }
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete film?"
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:@"No"
                                        otherButtonTitles:@"Delete", nil];
  [alert show];
  [alert release];
  
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if ( 1 == buttonIndex ) {
    [self reallyDelete];
  }
}

- (IBAction)reallyDelete {  
  MLog ( @"Delete" );
  NSIndexPath* indexPath = [self selectedIndex];
  if ( indexPath != nil ) {
    Film *film = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [[NSFileManager defaultManager] removeItemAtPath:film.filename error:nil];
    [self.managedObjectContext deleteObject:film];
    [self.managedObjectContext save:nil];
    [self.tableView reloadData];
  }
}

- (IBAction)duplicate:(id)sender {
  MLog ( @"Duplicate" );
  NSIndexPath* indexPath = [self selectedIndex];
  if ( indexPath != nil ) {
    Film *film = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    Film *newFilm = [self createFilm];
    // Copy file and map
    [[NSFileManager defaultManager] copyItemAtPath:film.filename toPath:newFilm.filename error:nil];
  }
  [self.tableView reloadData];
}

- (IBAction)load:(id)sender {
  MLog ( @"Load" );
  NSIndexPath* indexPath = [self selectedIndex];
  if ( indexPath != nil ) {
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
  }
}


- (Film*)createFilm {
  
  // Create the directory
  NSLog ( @"scenario name %@", [AlephOneAppDelegate sharedAppDelegate].scenario.name );
  NSString *filmDirectory = [NSString stringWithFormat:@"%@/Films/%@/", 
                                 [[AlephOneAppDelegate sharedAppDelegate] applicationDocumentsDirectory],
                                 [AlephOneAppDelegate sharedAppDelegate].scenario.name];
  NSLog ( @"Creating saved film directory %@", filmDirectory );
  [[NSFileManager defaultManager] createDirectoryAtPath:filmDirectory
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
  
  // Create a new instance in CoreData with filename
  Film *film;
  film = [NSEntityDescription insertNewObjectForEntityForName:@"Film" inManagedObjectContext:self.managedObjectContext];
  
  NSString *filename = [NSString stringWithFormat:@"%@/%@", filmDirectory, [NSDate date]];
  NSLog ( @"Filename: %@", filename );
  film.filename = filename;
  film.lastSaveTime = [NSDate date];
  film.scenario = [AlephOneAppDelegate sharedAppDelegate].scenario;
  [[AlephOneAppDelegate sharedAppDelegate].scenario addFilmsObject:film];
  [self.managedObjectContext save:nil];
  return film;
}
    
#pragma mark -
#pragma mark Table view data source

- (int)numberOfSavedFilms {
  return [self.fetchedResultsController fetchedObjects].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  MLog ( @"Results have %d sections", [[self.fetchedResultsController sections] count] );
  return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
  MLog ( @"Section %d has %d objects", section, [sectionInfo numberOfObjects] );
  return [sectionInfo numberOfObjects];
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    FilmCell *cell = (FilmCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      [[NSBundle mainBundle] loadNibNamed:@"FilmCell" owner:self options:nil];
      cell = filmCell;
      self.filmCell = nil;
    }
    
  // Configure the cell...
  Film *film = [self.fetchedResultsController objectAtIndexPath:indexPath];
  [cell setFields:film];
  return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    // Delete the managed object for the given index path
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  // The table view should not be re-orderable.
  return NO;
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/
#pragma mark -
#pragma mark Fetched results controller
- (NSManagedObjectContext*)managedObjectContext {
  if ( managedObjectContext_ != nil ) {
    return managedObjectContext_;
  }
  managedObjectContext_ = [AlephOneAppDelegate sharedAppDelegate].managedObjectContext;
  return managedObjectContext_;
}

- (NSFetchedResultsController *)fetchedResultsController {
  
  if (fetchedResultsController_ != nil) {
    return fetchedResultsController_;
  }
  
  /*
   Set up the fetched results controller.
   */
  // Create the fetch request for the entity.
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  // Edit the entity name as appropriate.
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Film" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  
  // Set the batch size to a suitable number.
  [fetchRequest setFetchBatchSize:20];
  
  // Edit the sort key as appropriate.
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastSaveTime" ascending:NO];
  NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
  
  [fetchRequest setSortDescriptors:sortDescriptors];
  
  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] 
                                                           initWithFetchRequest:fetchRequest 
                                                           managedObjectContext:self.managedObjectContext
                                                           sectionNameKeyPath:nil
                                                           cacheName:@"Root"];
  aFetchedResultsController.delegate = self;
  self.fetchedResultsController = aFetchedResultsController;
  
  [aFetchedResultsController release];
  [fetchRequest release];
  [sortDescriptor release];
  [sortDescriptors release];
  
  NSError *error = nil;
  if (![fetchedResultsController_ performFetch:&error]) {
    /*
     Replace this implementation with code to handle the error appropriately.
     
     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
     */
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
  MLog(@"Printing saved games");
  for ( Film* game in [self.fetchedResultsController fetchedObjects] ) {
    MLog(@"\tApp: %@", game.filename );
  }
  
  
  return fetchedResultsController_;
}    


#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
  
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
  
  UITableView *tableView = self.tableView;
  
  switch(type) {
      
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeUpdate:
      [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
      
    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  Film *film = [self.fetchedResultsController objectAtIndexPath:indexPath];
  [(FilmCell*)cell setFields:film];
}


#pragma mark -
#pragma mark Add a new object

- (void)insertNewObject {
  
  // Create a new instance of the entity managed by the fetched results controller.
  NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
  NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
  NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
  
  // If appropriate, configure the new managed object.
  [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
  
  // Save the context.
  NSError *error = nil;
  if (![context save:&error]) {
    /*
     Replace this implementation with code to handle the error appropriately.
     
     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
     */
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Find the selected saved game.
  Film *film = [self.fetchedResultsController objectAtIndexPath:indexPath];
  [[GameViewController sharedInstance] performSelector:@selector(filmChosen:) withObject:film afterDelay:0.0];
  // [[GameViewController sharedInstance] gameChosen:game];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {    
  [fetchedResultsController_ release];
  [managedObjectContext_ release];
  [super dealloc];
}


@end

