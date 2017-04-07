//
//  AlephOneAppDelegate.h
//  AlephOne
//
//  Created by Daniel Blezek on 8/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <StoreKit/StoreKit.h>
#import "NewGameViewController.h"
#import "ManagedObjects.h"
#import "Prefs.h"
#import "Secrets.h"
#import "Purchases.h"

@class GameViewController;
@interface AlephOneAppDelegate : NSObject <UIApplicationDelegate, SKPaymentTransactionObserver> {
    
  UIWindow *window;
  NewGameViewController *newGameViewController;
  Scenario *scenario;
  GameViewController *game;
  bool finishedStartup;
  int OpenGLESVersion;
  int retinaDisplay;
  int oglWidth;
  int oglHeight;
  
  Purchases *purchases;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) GameViewController *game;
@property (nonatomic, retain) Purchases *purchases;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) Scenario *scenario;
@property (nonatomic) int OpenGLESVersion;
@property (nonatomic) int oglHeight;
@property (nonatomic) int oglWidth;
@property (nonatomic) int retinaDisplay;
@property (nonatomic) int longScreenDimension; //DCW
@property (nonatomic) int shortScreenDimension; //DCW

@property (nonatomic, retain) IBOutlet UIViewController *viewController;


// Transactions
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;

- (NSString *)applicationDocumentsDirectory;
- (NSString*)getDataDirectory;
+(AlephOneAppDelegate *)sharedAppDelegate;
- (void)startAlephOne;
- (void)initAndBegin;
- (void)startSound;
- (void)uploadAchievements;
- (void)oglWidth:(GLint)width oglHeight:(GLint)height;
- (BOOL)runningOniPad;
@end


