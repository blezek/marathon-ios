//
//  NewGameViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 8/24/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewGameViewController : UIViewController {
  UIButton *easyButton;
  UIButton *normalButton;
  UIButton *hardButton;
  UIButton *nightmareButton;
  UISlider *startLevelSlider;
  UILabel *startLevelLabel;
  UIView *pledge;
}

@property (nonatomic, retain) IBOutlet UIButton *easyButton;
@property (nonatomic, retain) IBOutlet UIButton *normalButton;
@property (nonatomic, retain) IBOutlet UIButton *hardButton;
@property (nonatomic, retain) IBOutlet UIButton *nightmareButton;
@property (nonatomic, retain) IBOutlet UISlider *startLevelSlider;
@property (nonatomic, retain) IBOutlet UILabel *startLevelLabel;
@property (nonatomic, retain) IBOutlet UIView *pledge;
@property (nonatomic, retain) IBOutlet UIView *startLevelView;


- (IBAction)start:(id)control;
- (IBAction)cancel:(id)control;
- (IBAction)setDifficulty:(id)control;
- (IBAction)setEntryLevel:(id)control;

- (void)appear;
- (void)disappear;

@end
