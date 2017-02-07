//
//  RoundedView.m
//  AlephOne
//
//  Created by Daniel Blezek on 3/5/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "RoundedView.h"
#import <QuartzCore/QuartzCore.h>


@implementation RoundedView


- (id)initWithFrame:(CGRect)frame {
  
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code.
    self.layer.cornerRadius = 20.0;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
    self.layer.borderWidth = 2;
    
  }
  return self;
}

- (id)initWithCoder:(NSCoder*)encoder {
  
  self = [super initWithCoder:encoder];
  if (self) {
    // Initialization code.
    self.layer.cornerRadius = 20.0;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
    self.layer.borderWidth = 2;
    
  }
  return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
