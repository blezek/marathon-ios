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

#import "UAAsycImageView.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

// Adapted from Mark J. AsyncImageView
// http://www.markj.net/iphone-asynchronous-table-image/

@implementation UAAsyncImageView

@synthesize onReady;
@synthesize target;

- (void)dealloc {
    [imageURL release];
    [data release];
    [super dealloc];
}

- (void)loadImageFromURL:(NSURL*)url {
    if([[url absoluteString] length] == 0) {
        return;
    }

    if ([imageURL isEqual:url] && self.image != nil) {
        return;
    } else {
        [url retain];
        [imageURL release];
        imageURL = url;
    }

    if (data!=nil) {
        [data release];
        data = nil;
    }
    self.image = nil;

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:imageURL];
	
	[request setDelegate:self];
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
	[request setDidFinishSelector:@selector(imageReady:)];
	[request startAsynchronous];

}


- (void)imageReady:(ASIHTTPRequest *)request {
    self.image = [UIImage imageWithData:request.responseData];
    [self setNeedsLayout];

    if(target != nil && onReady != nil) {
        NSMethodSignature * sig = nil;
        sig = [[target class] instanceMethodSignatureForSelector: onReady];

        NSInvocation * myInvocation = nil;
        myInvocation = [NSInvocation invocationWithMethodSignature: sig];
        [myInvocation setArgument: &self atIndex: 2];
        [myInvocation setTarget: target];
        [myInvocation setSelector: onReady];
        [myInvocation invoke];
    }
}

@end