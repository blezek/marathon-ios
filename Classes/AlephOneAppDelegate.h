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
#import <AVFoundation/AVFoundation.h>
#import "NewGameViewController.h"
#import "ManagedObjects.h"
#import "Prefs.h"
#import "Secrets.h"

@class GameViewController;
@interface AlephOneAppDelegate : NSObject <UIApplicationDelegate> {
    
  UIWindow *window;
  NewGameViewController *newGameViewController;
  Scenario *scenario;
  GameViewController *game;
  bool finishedStartup;
  bool introFinished;
  int OpenGLESVersion;
  int retinaDisplay;
  int oglWidth;
  int oglHeight;
  
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) GameViewController *game;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) Scenario *scenario;
@property (nonatomic) int OpenGLESVersion;
@property (nonatomic) int oglHeight;
@property (nonatomic) int oglWidth;
@property (nonatomic) int retinaDisplay;

  //DCW
@property (nonatomic) int longScreenDimension;
@property (nonatomic) int shortScreenDimension;
@property (nonatomic, retain) AVPlayer *avPlayer;

@property (nonatomic, retain) IBOutlet UIViewController *viewController;


//Intro methods
- (void)itemDidFinishPlaying:(NSNotification *)notification;
- (IBAction)finishIntro:(id)sender;

- (NSString *)applicationDocumentsDirectory;
- (NSString*)getDataDirectory;
+(AlephOneAppDelegate *)sharedAppDelegate;
- (void)startAlephOne;
- (void)initAndBegin;
- (void)startSound;
- (void)oglWidth:(GLint)width oglHeight:(GLint)height;
- (BOOL)runningOniPad;
- (void)endBackgroundTask:(NSNumber *)taskID;
- (bool)gameIsNetworked;
@end


