//
//  AlertView.m
//  AlephOne
//
//  Created by Daniel Blezek on 7/25/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "AlertView.h"


@implementation AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  completionBlock ( buttonIndex );
  [self release];
}

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSArray *)otherButtonTitles
         completion:(void(^)(NSInteger buttonIndex ))completion {
  completionBlock = completion;
  self = [super initWithTitle:title 
                     message:message
                     delegate:self
            cancelButtonTitle:cancelButtonTitle
            otherButtonTitles:nil];
  for ( NSString* s in otherButtonTitles ) {
    [self addButtonWithTitle:s];
  }
  [self retain];
  return self;
}

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
      okButtonTitle:(NSString *)okButtonTitle
         completion:(void(^)(NSInteger buttonIndex ))completion {
  return [self initWithTitle:title
                     message:message
           cancelButtonTitle:cancelButtonTitle
           otherButtonTitles:[NSArray arrayWithObject:okButtonTitle]
                  completion:completion];
}


@end
