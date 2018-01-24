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

#import "Tracking.h"
#import "Effects.h"
////#import "TestFlight.h"

extern "C" {
#import "SDL.h" //DCW include main for SDL
#include "SDL_hints.h" //DCW

//#import "SDL_sysvideo.h" //DCW not sure if this is needed in SDL2
#import "SDL_events_c.h"
#import "jumphack.h"
}
#import "SDL_uikitopenglview.h"
#import "ManagedObjects.h"
#import "AlephOneShell.h"
#import "AlephOneHelper.h"
#include "preferences.h"
#include "map.h" //Needed for detecting whether we are networked when going into background.


  //DCW
static void
SDL_IdleTimerDisabledChanged(void *userdata, const char *name, const char *oldValue, const char *hint)
{
  BOOL disable = (hint && *hint != '0');
  [UIApplication sharedApplication].idleTimerDisabled = disable;
}

@implementation AlephOneAppDelegate

@synthesize window, scenario, game, OpenGLESVersion;
@synthesize viewController;
@synthesize oglWidth, oglHeight, retinaDisplay, longScreenDimension, shortScreenDimension;

#pragma mark -
#pragma mark AlephOne startup

- (void)startAlephOne {
  finishedStartup = YES;

    //DCW bypass sdl main
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
  SDL_AddHintCallback(SDL_HINT_IDLE_TIMER_DISABLED, SDL_IdleTimerDisabledChanged, NULL);
  SDL_SetMainReady();
  SDL_iPhoneSetEventPump(SDL_TRUE);

  
  UIWindow *appMenuWindow = [[UIApplication sharedApplication] keyWindow]; //Grab a reference to the current key window
  
  AlephOneInitialize();
  MLog ( @"AlephOneInitialize finished" );

  SDL_iPhoneSetEventPump(SDL_TRUE);
  
  //DCW
  //If SDL initialized correctly, it will now be the key window. We don't really want that, but instead want it's view to be a subview of the game view.
  //This is a bit fragile. In the future, maybe vberify that the key window is actually an SDL window as we expect.
  UIWindow *a1Window = [[UIApplication sharedApplication] keyWindow];
  UIView *a1View = [a1Window rootViewController].view;
  [game setOpenGLView:a1View];
    
  [appMenuWindow makeKeyAndVisible]; //DCW SDL2 sets new windows to key, which we don't want. Restore previous key window.
  
  
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

//Borrowed from DLudwig
// Retrieve SDL's root UIViewController (iOS only!)
// This function is completely NOT guaranteed to work in the future.
// Use it at your own risk!
/*UIViewController * GetSDLViewController(SDL_Window * sdlWindow)
{
  SDL_SysWMinfo systemWindowInfo;
  SDL_VERSION(&systemWindowInfo.version);
  if ( ! SDL_GetWindowWMInfo(sdlWindow, &systemWindowInfo)) {
    // consider doing some kind of error handling here
    return nil;
  }
  UIWindow * appWindow = mainWindowWMInfo.info.uikit.window;
  UIViewController * rootViewController = appWindow.rootViewController;
  return rootViewController;
}*/

- (void)initAndBegin {
  // Initialize the game
  self.game.splashView.hidden = YES;
  self.game.splashView = nil;
  MLog ( @"Hiding SplashView and starting animation" );
  [Appirater appLaunched:YES];
  // [game performSelector:@selector(startAnimation) withObject:nil afterDelay:1.0];
  [game startAnimation];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
  introFinished = NO;
	finishedStartup = NO;
  OpenGLESVersion = 1;

	//DCW: provide a common way to get the current screen dimensions for landscape.
	longScreenDimension = max([[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width);
	shortScreenDimension = min([[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width);
	
  //DCW clear fake key map:
  for(int i=0; i<SDL_NUM_SCANCODES; ++i)
    fake_key_map[i]=0;
  
  // Default preferences
  // Set the application defaults  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"2.0", kGamma,
                               @"YES", kTapShoots,
                               @"NO", kSecondTapShoots,
                               @"0.85", kHSensitivity,
                               @"0.6", kVSensitivity,
                               @"1.0", kSfxVolume,
                               @"0.8", kMusicVolume,
                               @"0", kEntryLevelNumber,
                               @"YES", kCrosshairs,
                               @"NO", kOnScreenTrigger,
                               @"YES",  kHiLowTapsAltFire,
                               @"YES", kGyroAiming,
                               @"NO", kTiltTurning,
                               @"NO", kAutocenter,
                               @"NO", kHaveTTEP,
                               @"YES", kUseTTEP,
                               @"YES", kUsageData,
                               @"YES", kHaveVidmasterMode,
                               @"NO", kUseVidmasterMode,
                               @"NO", kAlwaysPlayIntro,
                               @"NO", kHaveReticleMode,
                               @"NO", kInvertY,
                               @"YES", kAutorecenter,
                               @"YES", kAlwaysRun,
                               @"YES", kSmoothMouselook,
                               [NSNumber numberWithBool:YES], kFirstGame,
                               nil];
  [defaults registerDefaults:appDefaults];
  [defaults synchronize];  
  
#if TARGET_IPHONE_SIMULATOR
  // Always test on the simulator
  // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstGame];
    /*
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveVidmasterMode];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveReticleMode];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveTTEP];
     */
#endif

  // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveReticleMode];

  
#if defined(A1DEBUG)
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAutocenter];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUseVidmasterMode];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveVidmasterMode];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveTTEP];
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
	
	[self.window setFrame:[[UIScreen mainScreen] bounds]]; ///DCW testing

	CGRect portraitBounds = [[UIScreen mainScreen] bounds]; // portrait bounds
	CGRect landscapeBounds = portraitBounds;
	landscapeBounds.size = CGSizeMake(portraitBounds.size.height, portraitBounds.size.width);


	
	
  [self.window makeKeyAndVisible];
	
  self.game = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:[NSBundle mainBundle]];
  [[NSBundle mainBundle] loadNibNamed:@"GameViewController" owner:self.game options:nil];
  [self.game viewDidLoad];

	self.window.rootViewController = self.game;

  self.viewController = self.game;
  [self.window addSubview:self.viewController.view];
  // [self.viewController.view addSubview:game.view];
  // [self.window addSubview:game.view];

  MLog ( @"Loaded view: %@", self.game.view );
  
////  [Tracking startup];
////  [Tracking trackPageview:@"/startup"];
////  [Tracking tagEvent:@"startup"];


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
  
  float startDelay = 0.0;
  
  
#if SCENARIO == 2
  startDelay = 0.1;
#endif 
    //DCW moving to finish intro
  //[[AlephOneAppDelegate sharedAppDelegate] performSelector:@selector(startAlephOne) withObject:nil afterDelay:startDelay];

#ifdef BUNGIE_AEROSPACE
  [UIView animateWithDuration:duration  delay:delay options:0 animations:fadeBungieToLoading completion:^(BOOL dummy) {
    self.game.bungieAerospaceImageView = nil;
    [UIView animateWithDuration:duration delay:delay options:0 animations:fadeLoadingToWaiting completion:^(BOOL cc) {
      [UIView animateWithDuration:duration delay:delay options:0 animations:fadeWaitingToLogo completion:nil];
    }];
  }];
#else
  self.game.bungieAerospaceImageView.hidden = YES;

  NSString *filepath = [[NSBundle mainBundle] pathForResource:@"A1_fade_in.mp4" ofType:nil inDirectory:nil];
  NSURL *fileURL = [NSURL fileURLWithPath:filepath];
  self.avPlayer = [AVPlayer playerWithURL:fileURL];
  self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
  
  AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
  videoLayer.frame = self.game.waitingImageView.bounds;
  videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  [self.game.waitingImageView.layer addSublayer:videoLayer];
  self.game.waitingImageView.alpha = 1.0;
  [self.avPlayer play];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avPlayer currentItem]];

  
  //[UIView animateWithDuration:duration delay:delay options:0 animations:fadeLoadingToWaiting completion:^(BOOL cc) {
  //  [UIView animateWithDuration:duration delay:delay options:0 animations:fadeWaitingToLogo completion:nil];
  //}];
#endif
  
  // TestFlight
 //// [TestFlight takeOff:TeamToken];
  
  return YES;
  
}

- (void)itemDidFinishPlaying:(NSNotification *)notification {
  AVPlayerItem *player = [notification object];
  [self finishIntro:self];
}

- (IBAction)finishIntro:(id)sender {
  //Only finish intro once!
  if ( !introFinished ) {
    introFinished=YES;
    
    self.game.mainMenuBackground.alpha = 0;
    
    float logoZoomScale = .8; //Fraction to start intro logo zoom from
    CGRect endlogo = self.game.mainMenuLogo.bounds;
    CGRect startlogo = self.game.mainMenuLogo.bounds;
    startlogo.origin.y += (startlogo.size.width - startlogo.size.width*logoZoomScale)/2;
    startlogo.size.width *=logoZoomScale;
    startlogo.size.height *=logoZoomScale;
    self.game.mainMenuLogo.bounds=startlogo;
    
    self.game.mainMenuLogo.alpha = 1.0;
    self.game.mainMenuSubLogo.alpha = 1.0;
    self.game.mainMenuButtons.alpha = 0;
    
    void (^growLogo) (void) = ^{
      self.game.mainMenuLogo.bounds=endlogo;
    };
    void (^fadeInBackground) (void) = ^{
      self.game.mainMenuBackground.alpha = 1.0;
    };
    
    [UIView animateWithDuration:5 delay:0 options:0 animations:growLogo completion:nil];
    
    [UIView animateWithDuration:1 delay:1 options:0 animations:fadeInBackground completion:nil];
    [Effects performSelector:@selector(appearRevealingView:) withObject:self.game.mainMenuButtons afterDelay:2];
    
    [self.game menuShowReplacementMenu];
    self.game.logoView.hidden = YES;
    [[AlephOneAppDelegate sharedAppDelegate] performSelector:@selector(startAlephOne) withObject:nil];
  }
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
////  [Tracking trackPageview:@"/applicationWillResignActive"];
////  [Tracking tagEvent:@"applicationWillResignActive"];
  
  [game pauseForBackground:self];
  if(![self gameIsNetworked]) {
    [game stopAnimation];
  }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
////  [Tracking trackPageview:@"/applicationDidEnterBackground"];
////  [Tracking tagEvent:@"applicationDidEnterBackground"];

    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
  // MLog ( @"Pausing sound" );
  // Pause sound
  // SoundManager::instance()->SetStatus(false);
  // [game stopAnimation];
  
  NSLog(@"Did enter background. Someday, we should probably put a reasonable time limit on this.");
  UIBackgroundTaskIdentifier bgTask;
  bgTask = [[UIApplication  sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    NSLog(@"End of tolerate time. Application should be suspended now if we do not ask more 'tolerance'");
    // [self askToRunMoreBackgroundTask]; This code seems to be unnecessary. I'll verify it.
  }];

  if (bgTask == UIBackgroundTaskInvalid) {
    NSLog(@"This application does not support background mode");
  } else {
    //NSLog(@"Application will continue to run in background as task %lu", bgTask );
    
    [self performSelector:@selector(endBackgroundTask:) withObject:[NSNumber numberWithUnsignedLong: bgTask] afterDelay:240];
  }
  
}

- (void)endBackgroundTask:(NSNumber *)taskID {
  NSLog(@"Ending background task %lu", [taskID unsignedLongValue] );
  [[UIApplication  sharedApplication] endBackgroundTask:[taskID unsignedLongValue]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
////  [Tracking trackPageview:@"/applicationWillEnterForeground"];
////  [Tracking tagEvent:@"applicationWillEnterForeground"];

  [Appirater appEnteredForeground:YES];
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
  // MLog ( @"Starting sound" );
  // SoundManager::instance()->SetStatus(true);  
  // [game startAnimation];
}

- (bool)gameIsNetworked {
  return game_is_networked;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
////  [Tracking trackPageview:@"/applicationDidBecomeActive"];
////  [Tracking tagEvent:@"applicationDidBecomeActive"];
  
  if ( finishedStartup ) {
    [game startAnimation];
  } else if (!introFinished && self.avPlayer) {
    [self.avPlayer play]; //We need to play because the avplayer pauses in the background.
  }
}

- (void)startSound {
}



/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
////  [Tracking trackPageview:@"/applicationWillTerminate"];
////  [Tracking tagEvent:@"applicationWillTerminate"];
////  [Tracking shutdown];

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
  int exit_status =0; //DCW

  //int exit_status = SDL_main(1, (char**)argv);  //DCW may no longer be needed

	/* exit, passing the return status from the user's application */
	exit(exit_status);
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

