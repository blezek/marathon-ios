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

@interface AlephOneAppDelegate : NSObject <UIApplicationDelegate> {
    
  UIWindow *window;
  NewGameViewController *newGameViewController;
  Scenario *scenario;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) Scenario *scenario;

- (NSString *)applicationDocumentsDirectory;
+(AlephOneAppDelegate *)sharedAppDelegate;

@end


