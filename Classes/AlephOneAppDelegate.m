//
//  AlephOneAppDelegate.m
//  AlephOne
//
//  Created by Daniel Blezek on 8/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AlephOneAppDelegate.h"

#import "SDL_sysvideo.h"
#import "SDL_uikitopenglview.h"
#import "SDL_events_c.h"
#import "jumphack.h"
#import "ASIHTTPRequest.h"
#import "ZipArchive.h"
#import "GameViewController.h"
#import "ManagedObjects.h"

@implementation AlephOneAppDelegate

@synthesize window;

extern int SDL_main(int argc, char *argv[]);

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
  NSString *currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
  NSLog ( @"Current Directory: %@", currentDirectory );
	/* Set working directory to resource path */
  [[NSFileManager defaultManager] changeCurrentDirectoryPath: [[NSBundle mainBundle] resourcePath]];
  currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
  NSLog ( @"Current Directory: %@", currentDirectory );
  // [GameViewController sharedInstance];
  
	// [[NSFileManager defaultManager] changeCurrentDirectoryPath: [[NSBundle mainBundle] resourcePath]];
  
  NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
  [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
  NSEntityDescription *scenarioEntity = [NSEntityDescription entityForName:@"Scenario" inManagedObjectContext:self.managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setEntity:scenarioEntity];
  NSError *error;
  NSArray *list = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  Scenario *scenario;
  if ( [list count] == 0 ) {
    // Insert us!
    scenario = [NSEntityDescription insertNewObjectForEntityForName:[scenarioEntity name] inManagedObjectContext:context];
    scenario.downloadURL = @"http://localhost/~blezek/M1A1.zip";
    scenario.isDownloaded = NO;
    scenario.name = @"Marathon";
    scenario.path = @"M1A1";
  } else {
    scenario = [list objectAtIndex:0];
  }
  
  
  // See if we have M1A1 installed, if not, fetch it and download
  NSString *installDirectory = [NSString stringWithFormat:@"%@/%@", [self applicationDocumentsDirectory], scenario.path];
  NSLog ( @"Install path is %@", installDirectory );
  
  BOOL isDirectory;
  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:installDirectory isDirectory:&isDirectory];
  NSLog ( @"Checking for file: %@", installDirectory );
  if ( !fileExists ) {
    NSString* path = [NSString stringWithFormat:@"%@/%@.zip", [self applicationDocumentsDirectory], scenario.path];
    
    NSLog ( @"Download file!" );
    NSURL *url = [NSURL URLWithString:scenario.downloadURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDownloadDestinationPath:path];    
    [request startSynchronous];
    
    // Now unzip
    ZipArchive *zipper = [[[ZipArchive alloc] init] autorelease];
    [zipper UnzipOpenFile:path];
    [zipper UnzipFileTo:[self applicationDocumentsDirectory] overWrite:NO];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:NULL];
    scenario.isDownloaded = [NSNumber numberWithBool:YES];
  }
  [context save:&error];
  
  newGameViewController = [[NewGameViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
  GameViewController *game = [GameViewController createNewSharedInstance];

  // [window addSubview:newGameViewController.view];
  [window addSubview:game.view];
  [window makeKeyAndVisible];

	[self performSelector:@selector(postFinishLaunch) withObject:nil afterDelay:0.0];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
  //NSLog(@"%@", NSStringFromSelector(_cmd));
  
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
  
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
  //NSLog(@"%@", NSStringFromSelector(_cmd));
  
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
	longjmp(*(jump_env()), 1);
  
}

char* argv0 = "AlephOneHD";
// Start up SDL
- (void)postFinishLaunch {
  
	/* run the user's application, passing argc and argv */
	int exit_status = SDL_main(1, &argv0);
	
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
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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

