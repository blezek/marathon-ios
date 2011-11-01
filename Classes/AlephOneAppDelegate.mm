//
//  AlephOneAppDelegate.m
//  AlephOne
//
//  Created by Daniel Blezek on 8/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AlephOneAppDelegate.h"
#import "GameViewController.h"
#import "ProgressViewController.h"
#import "AVFoundation/AVAudioSession.h"
#import "Appirater.h"
#import "Achievements.h"
#import "Tracking.h"

extern "C" {
#import "SDL_sysvideo.h"
#import "SDL_events_c.h"
#import "jumphack.h"
}
#import "SDL_uikitopenglview.h"
#import "ManagedObjects.h"
#import "AlephOneShell.h"
#import "AlephOneHelper.h"
#include "preferences.h"


@implementation AlephOneAppDelegate

@synthesize window, scenario, game, OpenGLESVersion, purchases;
@synthesize viewController;
@synthesize oglWidth, oglHeight, retinaDisplay;

extern int SDL_main(int argc, char *argv[]);

#pragma mark -
#pragma mark AlephOne startup

- (void)startAlephOne {
  finishedStartup = YES;
  
  AlephOneInitialize();
  MLog ( @"AlephOneInitialize finished" );

  // Kick in the purchases
  [self.purchases checkPurchases];
  
#ifdef USE_CADisplayLoop
  /*
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:2.0];
  // Fade out splash screen
  [self.game.splashView setAlpha:0.0];
  [UIView commitAnimations];
   */
  [self performSelector:@selector(initAndBegin) withObject:nil afterDelay:.0];
#endif
  
}

- (void)initAndBegin {
  // Initialize the game
  self.game.splashView.hidden = YES;
  self.game.splashView = nil;
  MLog ( @"Hiding SplashView and starting animation" );
  // [game performSelector:@selector(startAnimation) withObject:nil afterDelay:1.0];
  [game startAnimation];
}  

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	finishedStartup = NO;
  OpenGLESVersion = 1;
  self.purchases = [[Purchases alloc] init];
  [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  [Achievements login];

  // Default preferences
  // Set the application defaults  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"2.0", kGamma,
                               @"NO", kTapShoots,
                               @"NO", kSecondTapShoots,
                               @"0.5", kHSensitivity,
                               @"0.5", kVSensitivity,
                               @"1.0", kSfxVolume,
                               @"1.0", kMusicVolume,
                               @"0", kEntryLevelNumber,
                               @"NO", kCrosshairs,
                               @"NO", kAutocenter,
                               @"NO", kHaveTTEP,
                               @"YES", kUseTTEP,
                               @"YES", kUsageData,
                               @"NO", kHaveVidmasterMode,
                               @"YES", kUseVidmasterMode,
                               @"NO", kAlwaysPlayIntro,
                               @"NO", kHaveReticleMode,
                               [NSNumber numberWithBool:YES], kFirstGame,
                               nil];
  [defaults registerDefaults:appDefaults];
  [defaults synchronize];  
  
#if TARGET_IPHONE_SIMULATOR
  // Always test on the simulator
  // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstGame];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveVidmasterMode];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveReticleMode];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveTTEP];
#endif

  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveReticleMode];

  
#if defined(A1DEBUG)
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAutocenter];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUseVidmasterMode];
#endif
    
  NSString *currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
  NSLog ( @"Current Directory: %@", currentDirectory );
	/* Set working directory to resource path */
  [[NSFileManager defaultManager] changeCurrentDirectoryPath: [[NSBundle mainBundle] resourcePath]];
  currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
  NSLog ( @"Current Directory: %@", currentDirectory );
  // [GameViewController sharedInstance];
  
	// [[NSFileManager defaultManager] changeCurrentDirectoryPath: [[NSBundle mainBundle] resourcePath]];
  
  NSEntityDescription *scenarioEntity = [NSEntityDescription entityForName:@"Scenario" inManagedObjectContext:self.managedObjectContext];
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [fetchRequest setEntity:scenarioEntity];
  NSError *error;
  NSArray *list = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  if ( [list count] == 0 ) {
    // Insert us!
    self.scenario = [NSEntityDescription insertNewObjectForEntityForName:[scenarioEntity name] inManagedObjectContext:self.managedObjectContext];
    self.scenario.isDownloaded = NO;
    
    self.scenario.version = [NSNumber numberWithInteger:1];

#if TARGET_IPHONE_SIMULATOR
    NSString *localhost = @"localhost";
#else 
    NSString *localhost = @"10.0.0.10";    
    NSString *RemoteURL = Content_Delivery_URL;
    NSString *RemoteHost = Content_Delivery_Host;
#endif
    
#if SCENARIO == 1
    // Marathon
    self.scenario.name = @"Marathon";
    self.scenario.path = @"M1A1";
    self.scenario.sizeInBytes = [NSNumber numberWithInteger:(150 * 1024 * 1024)];  // 150 meg
    
#elif SCENARIO == 2
    // Marathon Durandal
    self.scenario.name = @"Durandal";
    self.scenario.path = @"M2A1";
    self.scenario.sizeInBytes = [NSNumber numberWithInteger:(150 * 1024 * 1024)];  // 150 meg
#elif SCENARIO == 3
    // Marathon Infinity
    self.scenario.name = @"Infinity";
    self.scenario.path = @"M3A1";
    self.scenario.sizeInBytes = [NSNumber numberWithInteger:(150 * 1024 * 1024)];  // 150 meg
#else
#error "Unknown scenario!
#endif
    
    
#if TARGET_IPHONE_SIMULATOR
    self.scenario.downloadURL = [NSString stringWithFormat:@"http://%@/~blezek/%@.zip", localhost, self.scenario.path];
    self.scenario.downloadHost = localhost;
#else
    // AWS
    self.scenario.downloadURL = [NSString stringWithFormat:@"%@/%@.zip", RemoteURL, self.scenario.path];
    self.scenario.downloadHost = RemoteHost;

#if defined(A1DEBUG)
    self.scenario.downloadURL = [NSString stringWithFormat:@"http://%@/~blezek/%@.zip", localhost, self.scenario.path];
    self.scenario.downloadHost = localhost;
#endif

#endif
    
    [self.scenario.managedObjectContext save:nil];
  } else {
    self.scenario = [list objectAtIndex:0];
  }

  NSError *setCategoryError = nil;
  
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error: &setCategoryError];
  if (setCategoryError) { 
    /* handle the error condition */ 
    MLog ( @"Error setting audio category" );
  }

  [self.window makeKeyAndVisible];
  [self.window addSubview:self.viewController.view];  

  self.game = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:[NSBundle mainBundle]];
  [[NSBundle mainBundle] loadNibNamed:@"GameViewController" owner:self.game options:nil];
  [self.game viewDidLoad];
  [self.viewController.view addSubview:game.view];
  
  MLog ( @"Loaded view: %@", self.game.view );
  
  [Appirater appLaunched:YES];
  [Tracking startup];
  [Tracking trackPageview:@"/startup"];
  [Tracking tagEvent:@"startup"];

  // Tracking and timer
  [NSTimer scheduledTimerWithTimeInterval:60 target:[AlephOneAppDelegate sharedAppDelegate] selector:@selector(uploadAchievements) userInfo:nil repeats:YES];
  
  // Do opening animations
  self.game.bungieAerospaceImageView.alpha = 1.0;
  self.game.episodeImageView.alpha = 0.0;
  self.game.episodeLoadingImageView.alpha = 0.0;
  self.game.waitingImageView.alpha = 0.0;
  
  void (^fadeBungieToLoading) (void) = ^{
    self.game.episodeLoadingImageView.alpha = 1.0;
    self.game.bungieAerospaceImageView.alpha = 0.0;    
  };
  void (^fadeLoadingToWaiting) (void) = ^{
    self.game.episodeLoadingImageView.alpha = 0.0;
    self.game.waitingImageView.alpha = 1.0;
  };
  void (^fadeWaitingToLogo) (void) = ^{
    self.game.waitingImageView.alpha = 0.0;
    self.game.episodeImageView.alpha = 1.0;
  };
    
  float duration = 1.2;
  float delay = 1.2;
  [UIView animateWithDuration:duration  delay:delay options:0 animations:fadeBungieToLoading completion:^(BOOL dummy) {
    self.game.bungieAerospaceImageView = nil;
    [UIView animateWithDuration:duration delay:delay options:0 animations:fadeLoadingToWaiting completion:^(BOOL cc) {
      [[AlephOneAppDelegate sharedAppDelegate] performSelector:@selector(startAlephOne) withObject:nil afterDelay:0.0];
      [UIView animateWithDuration:duration delay:delay options:0 animations:fadeWaitingToLogo completion:nil];
    }];
  }];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
  //NSLog(@"%@", NSStringFromSelector(_cmd));
  
  /*
  // Send every window on every screen a MINIMIZED event.
  SDL_VideoDevice *_this = SDL_GetVideoDevice();
  if (!_this) {
    return;
  }
  
  int i;
  for (i = 0; i < _this->num_displays; i++) {
    const SDL_VideoDisplay *display = &_this->displays[i];
    SDL_Window *sdlwindow;
    for (sdlwindow = display->windows; sdlwindow != nil; sdlwindow = sdlwindow->next) {
      SDL_SendWindowEvent(sdlwindow, SDL_WINDOWEVENT_MINIMIZED, 0, 0);
    }
  }
   */
  // Pause sound
  // MLog ( @"Pause mixer" );
  // SoundManager::instance()->SetStatus ( false );
  [Tracking trackPageview:@"/applicationWillResignActive"];
  [Tracking tagEvent:@"applicationWillResignActive"];
  [game pauseForBackground:self];
  [game stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  [Tracking trackPageview:@"/applicationDidEnterBackground"];
  [Tracking tagEvent:@"applicationDidEnterBackground"];

    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
  // MLog ( @"Pausing sound" );
  // Pause sound
  // SoundManager::instance()->SetStatus(false);
  // [game stopAnimation];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
  [Tracking trackPageview:@"/applicationWillEnterForeground"];
  [Tracking tagEvent:@"applicationWillEnterForeground"];

  [Appirater appEnteredForeground:YES];
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
  // MLog ( @"Starting sound" );
  // SoundManager::instance()->SetStatus(true);  
  // [game startAnimation];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  [Tracking trackPageview:@"/applicationDidBecomeActive"];
  [Tracking tagEvent:@"applicationDidBecomeActive"];
  if ( finishedStartup ) {
    [game startAnimation];
  }
}

- (void)startSound {
}



/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
  [Tracking trackPageview:@"/applicationWillTerminate"];
  [Tracking tagEvent:@"applicationWillTerminate"];
  [Tracking shutdown];

    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
  SDL_SendQuit();
  /* hack to prevent automatic termination.  See SDL_uikitevents.m for details */
	// DJB We really don't need the long jump...
  // longjmp(*(jump_env()), 1);
  
}

const char* argv[] = { "AlephOneHD" };
// Start up SDL
- (void)postFinishLaunch {
  
	/* run the user's application, passing argc and argv */
	int exit_status = SDL_main(1, (char**)argv);
	
	/* exit, passing the return status from the user's application */
	exit(exit_status);
}


#pragma mark -
#pragma mark Transactions

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
  for (SKPaymentTransaction *transaction in transactions)
  {
    BOOL notifiedOfFailure = NO;
    switch (transaction.transactionState)
    {
      case SKPaymentTransactionStatePurchased:
      case SKPaymentTransactionStateRestored:
        MLog ( @"Processing transaction %@", transaction.payment.productIdentifier );
        if ( [transaction.payment.productIdentifier isEqual:VidmasterModeProductID] ) {
          MLog ( @"Enable Vidmaster mode!" );
          [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveVidmasterMode];
          [[NSUserDefaults standardUserDefaults] synchronize];
          [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
        if ( [transaction.payment.productIdentifier isEqual:HDModeProductID] ) {
          MLog ( @"Enable HD mode!" );
          [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveTTEP];
          [[NSUserDefaults standardUserDefaults] synchronize];
          [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
        if ( [transaction.payment.productIdentifier isEqual:ReticulesProductID] ) {
          MLog ( @"Enable Reticule mode!" );
          [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveReticleMode];
          [[NSUserDefaults standardUserDefaults] synchronize];
          [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
        MLog ( @"Transaction completed" );
        break;
      case SKPaymentTransactionStateFailed:
        // Log something [self failedTransaction:transaction];
        // Pop up a dialog
        if ( !notifiedOfFailure ) {
          notifiedOfFailure = YES;
          UIAlertView *av = [[UIAlertView alloc] initWithTitle:transaction.error.localizedDescription
                                                       message:transaction.error.localizedFailureReason
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:nil];
          [av show];
          [av release];
        }
        MLog ( @"Transaction failed" );
        break;
      default:
        break;
    }
  }
  [[GameViewController sharedInstance].purchaseViewController updateView];
}

#pragma mark -
#pragma mark Achievements

- (void)uploadAchievements {
  MLog(@"Tracking & Achievements");
  [Achievements uploadAchievements];
  [Tracking dispatch];
}

#pragma mark -
#pragma mark OpenGL

-(void)oglWidth:(GLint)width oglHeight:(GLint)height {
  oglWidth = width;
  oglHeight = height;
  MLog(@"Set OpenGL to %d x %d", oglWidth, oglHeight);
}

-(BOOL)runningOniPad {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return YES;
  }
  return NO;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    managedObjectModel_ = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];   
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
  if (persistentStoreCoordinator_ != nil) {
    return persistentStoreCoordinator_;
  }
  
  NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"AlephOne.sqlite"]];
  
  NSError *error = nil;
  NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                            nil];
  
  persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString*)getDataDirectory {
  return [[NSBundle mainBundle] resourcePath];
}

#pragma mark -
#pragma mark Singleton helper
/* convenience method */
+(AlephOneAppDelegate *)sharedAppDelegate {
	/* the delegate is set in UIApplicationMain(), which is garaunteed to be called before this method */
	return (AlephOneAppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [window release];
    [super dealloc];
}


@end

