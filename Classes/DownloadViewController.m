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

@implementation DownloadViewController
@synthesize progressView;

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
  
  // See if we have M1A1 installed, if not, fetch it and download
  NSString *installDirectory = [NSString stringWithFormat:@"%@/%@", [app applicationDocumentsDirectory], app.scenario.path];
  NSLog ( @"Install path is %@", installDirectory );
  
  BOOL isDirectory;
  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:installDirectory isDirectory:&isDirectory];
  NSLog ( @"Checking for file: %@", installDirectory );
  if ( fileExists ) {
    return NO;
  } else {
    return YES;
  }
    
}

- (void)downloadOrchooseGame {
  AlephOneAppDelegate *app = [AlephOneAppDelegate sharedAppDelegate];
  
  // See if we have M1A1 installed, if not, fetch it and download
  NSString *installDirectory = [NSString stringWithFormat:@"%@/%@", [app applicationDocumentsDirectory], app.scenario.path];
  NSLog ( @"Install path is %@", installDirectory );
  
  BOOL isDirectory;
  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:installDirectory isDirectory:&isDirectory];
  NSLog ( @"Checking for file: %@", installDirectory );
  if ( !fileExists ) {
    
    NSString* path = [NSString stringWithFormat:@"%@/%@.zip", [app applicationDocumentsDirectory], app.scenario.path];
    downloadPath = path;
    NSLog ( @"Download file!" );
    NSURL *url = [NSURL URLWithString:app.scenario.downloadURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDownloadDestinationPath:path];
    [request setDownloadProgressDelegate:self.progressView];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(downloadFinished:)];
    [request setDidFailSelector:@selector(downloadFailed:)];
    [request startAsynchronous];
  }
}

- (void)downloadFinished:(ASIHTTPRequest*) request {
  AlephOneAppDelegate *app = [AlephOneAppDelegate sharedAppDelegate];

  // Now unzip
  NSString* path = downloadPath;

  ZipArchive *zipper = [[[ZipArchive alloc] init] autorelease];
  [zipper UnzipOpenFile:path];
  [zipper UnzipFileTo:[[AlephOneAppDelegate sharedAppDelegate] applicationDocumentsDirectory] overWrite:NO];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath:path error:NULL];
  app.scenario.isDownloaded = [NSNumber numberWithBool:YES];
  NSError *error;
  [[AlephOneAppDelegate sharedAppDelegate].managedObjectContext save:&error];
  [[AlephOneAppDelegate sharedAppDelegate] startAlephOne];
  [path autorelease];
  
}

- (void)downloadFailed:(ASIHTTPRequest*) request {
  MLog ( @"Download failed!" );
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
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
