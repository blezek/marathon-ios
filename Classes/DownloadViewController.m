    //
//  DownloadViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 9/8/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "DownloadViewController.h"
#import "ManagedObjects.h"
#import "AlephOneAppDelegate.h"
#import "ZipArchive.h"
#import "Reachability.h"

@implementation DownloadViewController
@synthesize progressView;
@synthesize expandingView;
@synthesize downloadPath;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (bool)isDownloadOrChooseGameNeeded {
  AlephOneAppDelegate *app = [AlephOneAppDelegate sharedAppDelegate];
  
  NSEntityDescription *scenarioEntity = [NSEntityDescription entityForName:@"Scenario" inManagedObjectContext:app.managedObjectContext];
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [fetchRequest setEntity:scenarioEntity];
  NSError *error;
  NSArray *list = [app.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  if ( [list count] == 1 ) {
    app.scenario = [list objectAtIndex:0];
    return [self isScenarioDownloaded] == NO;
  }
  return YES;
}

- (bool)isScenarioDownloaded {
  AlephOneAppDelegate *app = [AlephOneAppDelegate sharedAppDelegate];

  // See if we have M1A1 installed, if not, fetch it and download
  NSString *installDirectory = [NSString stringWithFormat:@"%@/%@", [app applicationDocumentsDirectory], app.scenario.path];
  NSLog ( @"Install path is %@", installDirectory );
  
  BOOL isDirectory;
  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:installDirectory isDirectory:&isDirectory];
  NSLog ( @"Checking for file: %@", installDirectory );
  return fileExists;    
}

- (void)downloadOrchooseGame {
  AlephOneAppDelegate *app = [AlephOneAppDelegate sharedAppDelegate];
  
  // Check filesystem space
  NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[app applicationDocumentsDirectory] error:NULL];
  MLog ( @"Have %@ space avaliable", [attributes objectForKey:NSFileSystemFreeSize] );
  
  NSEntityDescription *scenarioEntity = [NSEntityDescription entityForName:@"Scenario" inManagedObjectContext:app.managedObjectContext];
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [fetchRequest setEntity:scenarioEntity];
  NSError *error;
  NSArray *list = [app.managedObjectContext executeFetchRequest:fetchRequest error:&error];

  if ( [list count] == 1 ) {
    app.scenario = [list objectAtIndex:0];
    if ( [self isScenarioDownloaded] ) {
      [self startGame];
      return;
    }
    // [self performSelector:@selector(downloadAndStart) withObject:nil afterDelay:0.0];
    [self downloadAndStart];
  }
  
}

-(void)downloadAndStart {
  AlephOneAppDelegate *app = [AlephOneAppDelegate sharedAppDelegate];
  
  
  // Check filesystem space
  NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[app applicationDocumentsDirectory] error:NULL];
  NSNumber *freeSpace = [attributes objectForKey:NSFileSystemFreeSize];
  long long Meg = 1024 * 1024;
  MLog ( @"Have %@ space avaliable %lld", freeSpace, [freeSpace longLongValue] );
  long long requiredSpace = [app.scenario.sizeInBytes longLongValue];
  long long availableSpace = [freeSpace longLongValue];
  if ( availableSpace < requiredSpace ) {
    NSString *msg = [NSString stringWithFormat:@"Installation requires %d megabytes (%d free).\nFree up some space and try again.", (int)(requiredSpace / Meg), (int)(availableSpace / Meg)];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not enough free space" message:msg delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
    [av show];
    [av autorelease];
    return;
  }
  
  // Reachability as well
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  
  NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
/*
  if(remoteHostStatus == NotReachable) {
    NSString *msg = @"Unable to reach download server, please check your connection.";
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No connectivity" message:msg delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
    [av show];
    [av autorelease];
    return;
  } else if (remoteHostStatus == ReachableViaWWAN) {
    if ( dataNetwork == NO ) {
      NSString *msg = [NSString stringWithFormat:@"Download %d megabytes over your data network?", (int)(requiredSpace / Meg / 3.0 )];
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Confirm download" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [av show];
      [av autorelease];
      dataNetwork = YES;
      return;
    }
  }
  */
  // See if we have M1A1 installed, if not, fetch it and download
  NSString *installDirectory = [NSString stringWithFormat:@"%@/%@", [app applicationDocumentsDirectory], app.scenario.path];
  NSLog ( @"Install path is %@", installDirectory );
  
  BOOL isDirectory;
  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:installDirectory isDirectory:&isDirectory];
  NSLog ( @"Checking for file: %@", installDirectory );
  if ( !fileExists ) {
    
    NSString* path = [NSString stringWithFormat:@"%@/%@.zip", [app applicationDocumentsDirectory], app.scenario.path];
    NSString* tempPath = [NSString stringWithFormat:@"%@/%@.zip.part", [app applicationDocumentsDirectory], app.scenario.path];
    self.downloadPath = path;
    NSLog ( @"Download file from %@", app.scenario.downloadURL );
    NSURL *url = [NSURL URLWithString:app.scenario.downloadURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDownloadDestinationPath:path];
    [request setDownloadProgressDelegate:self.progressView];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(downloadFinished:)];
    [request setDidFailSelector:@selector(downloadFailed:)];
    
    // Allow for resuming
    [request setTemporaryFileDownloadPath:tempPath];
    [request setAllowResumeForFileDownloads:YES];
    request.showAccurateProgress = YES;
    [request startAsynchronous];
  }
}

- (void)downloadFinished:(ASIHTTPRequest*) request {
  self.progressView.progress = 1.0;
  self.expandingView.hidden = NO;
  // Give us a chance to unhide...
  [self performSelector:@selector(unzipAndStart) withObject:nil afterDelay:0.25];
}

- (void)unzipAndStart {
  // Now unzip
  NSString* path = downloadPath;

  ZipArchive *zipper = [[[ZipArchive alloc] init] autorelease];
  [zipper UnzipOpenFile:path];
  [zipper UnzipFileTo:[[AlephOneAppDelegate sharedAppDelegate] applicationDocumentsDirectory] overWrite:NO];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath:path error:NULL];
  [self startGame];
}

-(void)startGame {
  AlephOneAppDelegate *app = [AlephOneAppDelegate sharedAppDelegate];
  app.scenario.isDownloaded = [NSNumber numberWithBool:YES];
  [app.scenario.managedObjectContext save:nil];
  [self.view removeFromSuperview];

  // [self performSelector:@selector(postFinishLaunch) withObject:nil afterDelay:0.0];

  [[AlephOneAppDelegate sharedAppDelegate] performSelector:@selector(startAlephOne) withObject:nil afterDelay:0.0];
}

- (void)downloadFailed:(ASIHTTPRequest*) request {
  MLog ( @"Download failed!" );
  NSString *msg = [NSString stringWithFormat:@"Download failed", request.responseStatusMessage];
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Download failed" message:msg delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
  [av show];
  [av autorelease];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  [self downloadAndStart];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  [self.progressView setTintColor:[UIColor greenColor]];
  self.expandingView.hidden = YES;
  dataNetwork = NO;
  
  // Use the status bar frame to determine the center point of the window's content area.
  CGRect bounds = CGRectMake(0, 0, 1024, 768);
  CGPoint center = CGPointMake(bounds.size.height / 2.0, bounds.size.width / 2.0);
  // Set the center point of the view to the center point of the window's content area.
  // Rotate the view 90 degrees around its new center point.
  CGAffineTransform transform = self.view.transform;
  transform = CGAffineTransformRotate(transform, (M_PI / 2.0));
  self.view.center = center;
  self.view.transform = transform;
  self.view.bounds = CGRectMake ( 0, 0, 1024, 768 );
  
  
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
  return ( interfaceOrientation == UIInterfaceOrientationLandscapeRight );
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
