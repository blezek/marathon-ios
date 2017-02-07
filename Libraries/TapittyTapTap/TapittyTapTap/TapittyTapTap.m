//
//  TapittyTapTap.m
//  TapittyTapTap
//
//  Created by Dustin Wenz on 10/14/16.
//  Copyright © 2016 Dustin Wenz. All rights reserved.
//

#import "TapittyTapTap.h"
@implementation TapittyTapTap

+ (void)tap:(int)thetap{
	
	UIImpactFeedbackGenerator *feedback = nil;

	if (thetap == 0 )
		feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
	else if (thetap == 1 )
		feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
	else
	 feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
	NSLog (@"TAPPITY");
	[feedback impactOccurred];
	[feedback prepare];
}

@end
