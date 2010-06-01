/*
 SDL - Simple DirectMedia Layer
 Copyright (C) 1997-2009 Sam Lantinga
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 
 Sam Lantinga
 slouken@libsdl.org
*/

#import "SDL_uikitappdelegate.h"
#import "SDL_uikitopenglview.h"
#import <CommonCrypto/CommonDigest.h>

extern "C"
{
	#import "SDL_events_c.h"
	#import "jumphack.h"
};

//#import "FlurryAPI.h"
#ifndef DISABLE_OPENFEINT
	#import "OpenFeint.h"
#endif

#ifdef main
#undef main
#endif

extern "C" unsigned char gFlippedGL, gInitializedGL;
unsigned char gFlippedGL = 0;
extern UIView *gLandscapeView;
extern bool gRedraw;

extern "C" int SDL_main(int argc, char *argv[]);
static int forward_argc;
static char **forward_argv;

#define VALGRIND_PATH "/usr/local/bin/valgrind"

int main(int argc, char **argv) {
#ifdef VALGRIND
	if (argc < 2 || (argc >= 2 && strcmp(argv[1], "-valgrind") != 0)) 
	{
		// memory access checking
		execl(VALGRIND_PATH, VALGRIND_PATH, "--gen-suppressions=all", argv[0], "-valgrind", NULL);
		
		// memory profiling
		//execl(VALGRIND_PATH, VALGRIND_PATH, "--tool=massif", "--massif-out-file=/Users/kyle/wesnoth.massif", argv[0], "-valgrind", NULL);
    }
#endif
	
	int i;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	/* store arguments */
	forward_argc = argc;
	forward_argv = (char **)malloc(argc * sizeof(char *));
	for (i=0; i<argc; i++) {
		forward_argv[i] = (char *) malloc( (strlen(argv[i])+1) * sizeof(char));
		strcpy(forward_argv[i], argv[i]);
	}

	/* Give over control to run loop, SDLUIKitDelegate will handle most things from here */
	int retVal = UIApplicationMain(argc, argv, NULL, @"SDLUIKitDelegate");
	
	[pool release];
	return retVal;
}

@implementation SDLUIKitDelegate

@synthesize window;

/* convenience method */
+(SDLUIKitDelegate *)sharedAppDelegate {
	/* the delegate is set in UIApplicationMain(), which is garaunteed to be called before this method */
	return (SDLUIKitDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)init {
	self = [super init];
	window = nil;
	return self;
}

- (void)runSDLMain:(NSString *)aStr
{
	/* run the user's application, passing argc and argv */
	int exit_status = SDL_main(forward_argc, forward_argv);
	
	/* free the memory we used to hold copies of argc and argv */
	int i;
	for (i=0; i<forward_argc; i++) {
		free(forward_argv[i]);
	}
	free(forward_argv);	
	
	/* exit, passing the return status from the user's application */
	exit(exit_status);	
}
/*
void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}
*/
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	[NSThread sleepForTimeInterval:1];
	
	
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
	
	
	if (!UIDeviceOrientationIsLandscape(deviceOrientation))
		[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications]; 
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didRotate:)
												 name:UIDeviceOrientationDidChangeNotification object:nil];

	
	/* Set working directory to resource path */
	[[NSFileManager defaultManager] changeCurrentDirectoryPath: [[NSBundle mainBundle] resourcePath]];
	
	// run the user's application, passing argc and argv 
	/*
	int exit_status = SDL_main(forward_argc, forward_argv);
	
	// free the memory we used to hold copies of argc and argv
	int i;
	for (i=0; i<forward_argc; i++) {
		free(forward_argv[i]);
	}
	free(forward_argv);	
		
	// exit, passing the return status from the user's application
	exit(exit_status);
	*/	

/*	
	// KP: Flurry analytics disabled because of complaints with network calls costing air time
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#ifdef FREE_VERSION
	[FlurryAPI startSession:@"75UDWZTNGLKTKLNQ8YPG"];
#else
	[FlurryAPI startSession:@"ZNJRJHD1DYT8MJV4VME9"];
#endif
*/	
	
#ifndef __IPAD__	
	// AdMob campaign tracking
//	[self performSelectorInBackground:@selector(reportAppOpenToAdMob) withObject:nil];
#endif
	
	// KP: using a selector gets around the "failed to launch application in time" if the startup code takes too long
	// This is easy to see if running with Valgrind
	[self performSelector:@selector(runSDLMain:) withObject:@"" afterDelay: 0.2f];	
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	SDL_SendQuit();
	 /* hack to prevent automatic termination.  See SDL_uikitevents.m for details */
	longjmp(*(jump_env()), 1);
	
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application  
{	
	/*
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Low Memory" message:@"Detected low memory warning! Try restarting device to free more memory. Game will now exit..." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	SDL_SendQuit();
	 */
}  

-(void)dealloc {
	[window release];
	[super dealloc];
}

- (void)applicationDidBecomeActive
{
#ifndef DISABLE_OPENFEINT	
	[OpenFeint applicationDidBecomeActive];
#endif
}

- (void)applicationWillResignActive
{
#ifndef DISABLE_OPENFEINT
	[OpenFeint applicationWillResignActive];
#endif
}
/*
- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation
{
	UIDeviceOrientation ori = [UIDevice currentDevice].orientation;
 [OpenFeint setDashboardOrientation:orientation]
}
*/

-(void)didRotate:(NSNotification *)theNotification {
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];

	
	UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;

	if (!UIInterfaceOrientationIsLandscape(interfaceOrientation) && gInitializedGL == false)
	{
		interfaceOrientation = UIInterfaceOrientationLandscapeRight;
	}
		
	// check if we flipped upside down
	if (deviceOrientation == UIDeviceOrientationLandscapeLeft && interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
		interfaceOrientation = UIInterfaceOrientationLandscapeRight;
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight && interfaceOrientation == UIInterfaceOrientationLandscapeRight)
	   interfaceOrientation = UIInterfaceOrientationLandscapeLeft;

	bool changed = false;
	if (gInitializedGL == false)
		changed = true;
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
	{
		if (gFlippedGL == false)
			changed = true;
		gFlippedGL = true;
	}
	else
	{
		if (gFlippedGL == true)
			changed = true;
		gFlippedGL = false;
	}

	if (changed == false)
		return;
	
	[[UIApplication sharedApplication] setStatusBarOrientation: interfaceOrientation];
#ifndef DISABLE_OPENFEINT
	[OpenFeint setDashboardOrientation: interfaceOrientation];
#endif
	
	if (!gInitializedGL)
		return;
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
#ifdef __IPAD__
	glViewport(0, 0, 768, 1024);
	if (gFlippedGL)
		glRotatef(90, 0, 0, 1);
	else
		glRotatef(-90, 0, 0, 1);
	glOrthof(0.0, (GLfloat) 1024, (GLfloat) 768, 0.0, 0, 100.0f);
#else
	glViewport(0, 0, 320, 480);
	if (gFlippedGL)
		glRotatef(90, 0, 0, 1);
	else
		glRotatef(-90, 0, 0, 1);
	glOrthof(0.0, (GLfloat) 480, (GLfloat) 320, 0.0, 0, 100.0f);
#endif
	gRedraw = true;
//	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	CGAffineTransform tr = CGAffineTransformIdentity; // get current transform (portrait)
	if (gFlippedGL)
		tr = CGAffineTransformRotate(tr, -(M_PI / 2.0)); // rotate 90 degrees to go landscape
	else
		tr = CGAffineTransformRotate(tr, (M_PI / 2.0)); // rotate 90 degrees to go landscape
	
	gLandscapeView.transform = tr; // set current transform (landscape)		

}


// AdMob campaign tracking

// This method requires adding #import <CommonCrypto/CommonDigest.h> to your source file.
- (NSString *)hashedISU {
	NSString *result = nil;
	NSString *isu = [UIDevice currentDevice].uniqueIdentifier;
	
	if(isu) {
		unsigned char digest[16];
		NSData *data = [isu dataUsingEncoding:NSASCIIStringEncoding];
		CC_MD5([data bytes], [data length], digest);
		
		result = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				  digest[0], digest[1],
				  digest[2], digest[3],
				  digest[4], digest[5],
				  digest[6], digest[7],
				  digest[8], digest[9],
				  digest[10], digest[11],
				  digest[12], digest[13],
				  digest[14], digest[15]];
		result = [result uppercaseString];
	}
	return result;
}

- (void)reportAppOpenToAdMob {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // we're in a new thread here, so we need our own autorelease pool
	// Have we already reported an app open?
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
																		NSUserDomainMask, YES) objectAtIndex:0];
	NSString *appOpenPath = [documentsDirectory stringByAppendingPathComponent:@"admob_app_open"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:appOpenPath]) {
		// Not yet reported -- report now
		NSString *appOpenEndpoint = [NSString stringWithFormat:@"http://a.admob.com/f0?isu=%@&md5=1&app_id=%@",
									 [self hashedISU], @"340691963"];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:appOpenEndpoint]];
		NSURLResponse *response;
		NSError *error;
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		if((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200) && ([responseData length] > 0)) {
			[fileManager createFileAtPath:appOpenPath contents:nil attributes:nil]; // successful report, mark it as such
		}
	}
	[pool release];
}

@end
