/*
Copyright 2009-2010 Urban Airship Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binaryform must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided withthe distribution.

THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/******************************************************************************/
// WARNING: This file could change without warning in future versions submit
// patches to contact@urbanairship.com or send us a pull request on bitbucket.org
/******************************************************************************/

#import "Airship.h"
#import "ASIHTTPRequest.h"

#define kAirshipProductionServer @"https://go.urbanairship.com"

#define kLastDeviceTokenKey @"UADeviceTokenChanged"

static Airship *_sharedAirship;

@implementation Airship

@synthesize server;
@synthesize appId;
@synthesize appSecret;
@synthesize deviceTokenHasChanged;

-(void)dealloc {
    RELEASE_SAFELY(appId);
    RELEASE_SAFELY(appSecret);
    RELEASE_SAFELY(server);
    RELEASE_SAFELY(registerRequest);
    RELEASE_SAFELY(deviceToken);

    [super dealloc];
}

-(id)initWithId:(NSString *)appkey identifiedBy:(NSString *)secret {
    if (self = [super init]) {
        self.appId = appkey;
        self.appSecret = secret;
        deviceTokenHasChanged = NO;
        deviceToken = nil;
    }
    return self;
}

+(void)takeOff:(NSString *)appid identifiedBy:(NSString *)secret {
    if(!_sharedAirship) {
        NSString *path = [[NSBundle mainBundle]
                                    pathForResource:@"AirshipConfig" ofType:@"plist"];
        if (path != nil){
            NSMutableDictionary *config = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] autorelease];

            NSString *APP_KEY = [config objectForKey:@"APP_KEY"];
            NSString *APP_SECRET = [config objectForKey:@"APP_SECRET"];
            NSString *AIRSHIP_SERVER = [config objectForKey:@"AIRSHIP_SERVER"];

            _sharedAirship = [[Airship alloc] initWithId:APP_KEY
                                            identifiedBy:APP_SECRET];
            _sharedAirship.server = AIRSHIP_SERVER;
        } else {
            if([appid isEqual: @"YOUR_APP_KEY"] || [secret isEqual: @"YOUR_APP_SECRET"]) {
                NSString* okStr = @"OK";
                NSString* errorMessage =
                @"Application KEY and/or SECRET not set, please"
                " insert your application key from http://go.urbanairship.com into"
                " the Airship initialization located in your App Delegate's"
                " didFinishLaunching method";
                NSString *errorTitle = @"Ooopsie";
                UIAlertView *someError = [[UIAlertView alloc] initWithTitle:errorTitle
                                                                    message:errorMessage
                                                                   delegate:nil
                                                          cancelButtonTitle:okStr
                                                          otherButtonTitles:nil];

                [someError show];
                [someError release];
            }

            _sharedAirship = [[Airship alloc] initWithId:appid identifiedBy:secret];
            _sharedAirship.server = kAirshipProductionServer;
        }
        UALOG(@"App Key: %@", _sharedAirship.appId);
        UALOG(@"App Secret: %@", _sharedAirship.appSecret);
        UALOG(@"Server: %@", _sharedAirship.server);
    }
}

+ (void)land {
    [_sharedAirship release];
    _sharedAirship = nil;

    [NSClassFromString(@"AirMail") land];
    [NSClassFromString(@"StoreFront") land];
}

+(Airship *)shared {
    if (_sharedAirship == nil) {
        [NSException raise:@"InstanceNotExists"
                    format:@"Attempted to access instance before initializaion. Please call takeOff:identifiedBy: first."];
    }
    return _sharedAirship;
}

// Apple Remote Push Notifications
-(void)registerDeviceToken:(NSData *)token {
    [self registerDeviceToken:token withAlias:nil];
}

-(void)registerDeviceToken:(NSData *)token withAlias:(NSString *)alias {
    [self updateDeviceToken:token];

    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/", self.server, @"/api/device_tokens/", deviceToken];
    NSURL *url = [NSURL URLWithString:  urlString];
    ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    request.timeOutSeconds = 60;
    request.requestMethod = @"PUT";

    if(alias != nil) {
        [request addRequestHeader: @"Content-Type" value: @"application/json"];
        [request appendPostData:[[NSString stringWithFormat: @"{\"alias\": \"%@\"}", deviceAlias]
                                 dataUsingEncoding:NSUTF8StringEncoding]];
    }

    // Authenticate to the server
    request.username = self.appId;
    request.password = self.appSecret;

    [request setDelegate:self];
    [request setDidFailSelector: @selector(tokenRegistrationFail:)];
    [request setDidFinishSelector: @selector(deviceTokenRegistered:)];
    [request startAsynchronous];
}

- (void)deviceTokenRegistered:(ASIHTTPRequest *)request {
    if(request.responseStatusCode != 200 && request.responseStatusCode != 201) {
        UALOG(@"%d - Error registering device token", request.responseStatusCode);
    }
}

- (void)tokenRegistrationFail:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    UALOG(@"ERROR registering device token: %@", error);
}

- (void)displayStoreFront {
    id storeFront = NSClassFromString(@"StoreFront");
    NSAssert(storeFront != nil,@"Could not find StoreFront class to initialize");
    [storeFront displayStoreFront];
}

- (void)quitStoreFront {
    id storeFront = NSClassFromString(@"StoreFront");
    NSAssert(storeFront != nil,@"Could not find StoreFront class");
    [storeFront quitStoreFront];
}

- (NSString*)deviceToken {
    return deviceToken;
}

- (void)setDeviceToken:(NSString*)token {
    [deviceToken release];
    deviceToken = [[[[token description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                    stringByReplacingOccurrencesOfString:@">" withString:@""]
                   stringByReplacingOccurrencesOfString: @" " withString: @""];
    [deviceToken retain];
    UALOG(@"Device token: %@", deviceToken);

    // Check to see if the device token has changed
    NSString* oldValue = [[NSUserDefaults standardUserDefaults] objectForKey: kLastDeviceTokenKey];
    if(![oldValue isEqualToString: deviceToken]) {
        deviceTokenHasChanged = YES;
        [[NSUserDefaults standardUserDefaults] setObject: deviceToken forKey: kLastDeviceTokenKey];
    }
}

- (void)updateDeviceToken:(NSData*)token {
    self.deviceToken = [[[[token description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                         stringByReplacingOccurrencesOfString:@">" withString:@""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
}

@end
