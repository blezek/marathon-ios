//
//  AlephOneAppDelegate.m
//  AlephOne
//
//  Created by Daniel Blezek on 8/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AlephOneAppDelegate.h"
#import "GameViewController.h"
#import "DownloadViewController.h"
#import "ProgressViewController.h"
#import "AVFoundation/AVAudioSession.h"

extern "C" {
#import "SDL_sysvideo.h"
#import "SDL_events_c.h"
#import "jumphack.h"
}
#import "SDL_uikitopenglview.h"
#import "ManagedObjects.h"
#import "AlephOneShell.h"
#import "AlephOneHelper.h"

@implementation AlephOneAppDelegate

@synthesize window, scenario, game, downloadViewController, OpenGLESVersion;

extern int SDL_main(int argc, char *argv[]);

#pragma mark -
#pragma mark AlephOne startup

- (void)startAlephOne {
  // Remove the Download manager
  finishedStartup = YES;
  // [window addSubview:self.game.view];
  [self.downloadViewController.view removeFromSuperview];
  
  AlephOneInitialize();
  MLog ( @"AlephOneInitialize finished" );

	// Try out the CADisplayLink
#ifdef USE_SDL_EVENT_LOOP
  // [self performSelector:@selector(postFinishLaunch) withObject:nil afterDelay:0.0];
#endif

#ifdef USE_CADisplayLoop
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:2.0];
  // Fade out splash screen
  [self.game.splashView setAlpha:0.0];
  [UIView commitAnimations];
  [self performSelector:@selector(initAndBegin) withObject:nil afterDelay:2.0];
#endif
  
}

- (void)initAndBegin {
  // Initialize the game
  self.game.splashView.hidden = YES;
  MLog ( @"Hiding SplashView and starting animation" );
  // [game performSelector:@selector(startAnimation) withObject:nil afterDelay:1.0];
  [game startAnimation];
}  

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	finishedStartup = NO;
  OpenGLESVersion = 1;
  
  // Default preferences
  // Set the application defaults  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"NO", kCheatsEnabled,
                               @"NO", kTapShoots,
                               @"NO", kSecondTapShoots,
                               @"1.0", kHSensitivity,
                               @"1.0", kVSensitivity,
                               @"1.0", kSfxVolume,
                               @"1.0", kMusicVolume,
                               @"0", kEntryLevelNumber,
                               nil];
  [defaults registerDefaults:appDefaults];
  [defaults synchronize];  
  
  
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
    self.scenario.name = @"Marathon";
    self.scenario.path = @"M1A1";
    self.scenario.version = [NSNumber numberWithInteger:1];
    self.scenario.sizeInBytes = [NSNumber numberWithInteger:(150 * 1024 * 1024)];  // 150 meg
#if TARGET_IPHONE_SIMULATOR
    self.scenario.downloadURL = @"http://localhost/~blezek/M1A1.zip";
#else
    self.scenario.downloadURL = @"http://dl.dropbox.com/u/1363248/M1A1.zip";
    
    self.scenario.downloadURL = @"http://10.0.0.10/~blezek/M1A1.zip";
    self.scenario.downloadHost = @"10.0.0.10";
#endif
    self.scenario.downloadURL = @"http://dl.dropbox.com/u/1363248/M1A1.zip";
    self.scenario.downloadHost = @"dl.dropbox.com";

    // AWS
    self.scenario.downloadURL = @"https://s3.amazonaws.com/alephone/M1A1/M1A1.zip";
    self.scenario.downloadHost = @"s3.amazonaws.com";

    // CloudFront
    self.scenario.downloadURL = @"http://dhuphyigw82rv.cloudfront.net/M1A1/M1A1.zip";
    self.scenario.downloadHost = @"dhuphyigw82rv.cloudfront.net";

    self.scenario.downloadURL = @"http://10.0.0.10/~blezek/M1A1.zip";
    self.scenario.downloadHost = @"10.0.0.10";

    [self.scenario.managedObjectContext save:nil];
    self.scenario = nil;
  } 

  NSError *setCategoryError = nil;
  
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error: &setCategoryError];
  if (setCategoryError) { 
    /* handle the error condition */ 
    MLog ( @"Error setting audio category" );
  }
  
  // [window addSubview:newGameViewController.view];
  [window makeKeyAndVisible];

  // newGameViewController = [[NewGameViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
  self.game = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:[NSBundle mainBundle]];
  [[NSBundle mainBundle] loadNibNamed:@"GameViewController" owner:self.game options:nil];
  [self.game viewDidLoad];
  [window addSubview:self.game.view];
  
  MLog ( @"Loaded view: %@", self.game.view );
  
  // Create the download view controller
  self.downloadViewController = [[DownloadViewController alloc] initWithNibName:nil bundle:nil];
  if ( [self.downloadViewController isDownloadOrChooseGameNeeded] ) {
    [window addSubview:self.downloadViewController.view];
  }
  [self.downloadViewController downloadOrchooseGame];
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
  [game stopAnimation];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
  [game stopAnimation];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
  [game startAnimation];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
  //NSLog(@"%@", NSStringFromSelector(_cmd));
  /*
  // Send every window on every screen a RESTORED event.
  SDL_VideoDevice *_this = SDL_GetVideoDevice();
  if (!_this) {
    return;
  }
  
  int i;
  for (i = 0; i < _this->num_displays; i++) {
    const SDL_VideoDisplay *display = &_this->displays[i];
    SDL_Window *sdlwindow;
    for (sdlwindow = display->windows; sdlwindow != nil; sdlwindow = sdlwindow->next) {
      SDL_SendWindowEvent(sdlwindow, SDL_WINDOWEVENT_RESTORED, 0, 0);
    }
  }
   */
  if ( finishedStartup ) {
  [game startAnimation];
  }
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
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

