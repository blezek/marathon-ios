//
//  AlephOneHelper.m
//  AlephOne
//
//  Created by Daniel Blezek on 5/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlephOneHelper.h"

NSString *dataDir;

char* getDataDir() {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  dataDir = [paths objectAtIndex:0];
  // dataDir = [[NSBundle mainBundle] resourcePath];
  dataDir = [dataDir stringByAppendingString:@"/M1A1/"];
  return (char*)[dataDir UTF8String];
  
}