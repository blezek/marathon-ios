//
//  GameViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDL_uikitopenglview.h"
#include "SDL_keyboard.h"

@interface GameViewController : UIViewController {
  IBOutlet SDL_uikitopenglview *viewGL;
  // IBOutlet UIView *view;
  IBOutlet UIView *hud;
  IBOutlet UIButton *pause;
  IBOutlet UIView *weaponView;
  IBOutlet UIView *lookView;
  SDLKey leftFireKey;
  SDLKey rightFireKey;
  UISwipeGestureRecognizer *leftWeaponSwipe;
  UISwipeGestureRecognizer *rightWeaponSwipe;
  UIPanGestureRecognizer *panGesture;
  CGPoint lastPanPoint;
}

+(GameViewController*)sharedInstance;

- (void)startGame;
- (IBAction) leftTrigger:(id)sender;
- (IBAction) rightTrigger:(id)sender;
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;
- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer;

- (CGPoint) transformTouchLocation:(CGPoint)location;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
  
@property (nonatomic, retain) SDL_uikitopenglview *viewGL;
@property (nonatomic, retain) IBOutlet UIView *hud;
@property (nonatomic, retain) IBOutlet UIView *weaponView;
@property (nonatomic, retain) IBOutlet UIView *lookView;
@property (nonatomic, retain) IBOutlet UIButton *pause;
@property (nonatomic, retain) UISwipeGestureRecognizer *leftWeaponSwipe;
@property (nonatomic, retain) UISwipeGestureRecognizer *rightWeaponSwipe;
@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;
@end
