/*
 Copyright 2009-2010 Urban Airship Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binaryform must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided withthe distribution.

 THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC ``AS IS'' AND ANY EXPRESS OR
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

#import "UAViewUtils.h"


#define UALOG NSLog

// constants
#define kAirshipProductionServer @"https://go.urbanairship.com"

// path
#define kPendingProductsFile [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, \
NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString: @"/ua/pendingProducts.history"]

#define kDownloadHistoryFile [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, \
NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString: @"/ua/download.history"]

#define kReceiptHistoryFile [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, \
NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString: @"/ua/receipt.history"]

#define kUADirectory [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, \
NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString: @"/ua/"]

#define kUAOldDirectory [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, \
NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString: @"/ua/"]

#define kUADownloadDirectory [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, \
NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString: @"/ua/downloads/"]

#define kUAOldDownloadDirectory [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, \
NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString: @"/"]

// color
#define RGBA(r,g,b,a) [UIColor colorWithRed: r/255.0f green: g/255.0f \
blue: b/255.0f alpha: a]

#define BG_RGBA(r,g,b,a) CGContextSetRGBFillColor(context, r/255.0f, \
g/255.0f, b/255.0f, a)

#define kUpdateFGColor RGBA(255, 131, 48, 1)
#define kUpdateBGColor RGBA(255, 228, 201, 1)

#define kInstalledFGColor RGBA(60, 150, 60, 1)
#define kInstalledBGColor RGBA(185, 220, 185, 1)

#define kDownloadingFGColor RGBA(45, 138, 193, 1)
#define kDownloadingBGColor RGBA(173, 213, 237, 1)

#define kPriceFGColor [UIColor darkTextColor]
#define kPriceBorderColor RGBA(185, 185, 185, 1)
#define kPriceBGColor RGBA(217, 217, 217, 1)

// tag
#define __UA_DEPRECATED __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_3_0,__IPHONE_3_0)

// code block
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

#define SINGLETON_INTERFACE(CLASSNAME)  \
+ (CLASSNAME*)shared;


#define SINGLETON_IMPLEMENTATION(CLASSNAME)         \
                                                    \
static CLASSNAME* g_shared##CLASSNAME = nil;        \
\
+ (CLASSNAME*)shared                                \
{                                                   \
if (g_shared##CLASSNAME != nil) {                   \
return g_shared##CLASSNAME;                         \
}                                                   \
\
@synchronized(self) {                               \
if (g_shared##CLASSNAME == nil) {                   \
    g_shared##CLASSNAME = [[self alloc] init];      \
}                                                   \
}                                                   \
\
return g_shared##CLASSNAME;                         \
}                                                   \
\
+ (id)allocWithZone:(NSZone*)zone                   \
{                                                   \
@synchronized(self) {                               \
if (g_shared##CLASSNAME == nil) {                   \
g_shared##CLASSNAME = [super allocWithZone:zone];    \
return g_shared##CLASSNAME;                         \
}                                                   \
}                                                   \
NSAssert(NO, @ "[" #CLASSNAME                       \
" alloc] explicitly called on singleton class.");   \
return nil;                                         \
}                                                   \
\
- (id)copyWithZone:(NSZone*)zone                    \
{                                                   \
return self;                                        \
}                                                   \
\
- (id)retain                                        \
{                                                   \
return self;                                        \
}                                                   \
\
- (unsigned)retainCount                             \
{                                                   \
return UINT_MAX;                                    \
}                                                   \
\
- (void)release                                     \
{                                                   \
}                                                   \
\
- (id)autorelease                                   \
{                                                   \
return self;                                        \
}

