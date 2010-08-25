//
//  NewGameViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 8/24/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewGameViewController : UIViewController {

}

- (IBAction)start:(id)control;
- (IBAction)cancel:(id)control;
- (IBAction)setDifficulty:(UISegmentedControl*)control;

@end
