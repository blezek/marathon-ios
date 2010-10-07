//
//  AlephOneAppDelegate.h
//  AlephOne
//
//  Created by Daniel Blezek on 8/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "NewGameViewController.h"
#import "ManagedObjects.h"

@class GameViewController;
@class DownloadViewController;
@interface AlephOneAppDelegate : NSObject <UIApplicationDelegate> {
    
  UIWindow *window;
  NewGameViewController *newGameViewController;
  Scenario *scenario;
  GameViewController *game;
  DownloadViewController *downloadViewController;
  bool finishedStartup;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) GameViewController *game;
@property (nonatomic, retain) DownloadViewController *downloadViewController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) Scenario *scenario;

- (NSString *)applicationDocumentsDirectory;
+(AlephOneAppDelegate *)sharedAppDelegate;
- (void)startAlephOne;
@end


