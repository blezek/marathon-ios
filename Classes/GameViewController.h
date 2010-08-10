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

typedef enum {
  MenuMode,
  GameMode,
  AutoMapMode
} HUDMode;

@interface GameViewController : UIViewController {
  IBOutlet SDL_uikitopenglview *viewGL;
  IBOutlet UIView *hud;
  IBOutlet UIButton *pause;
  IBOutlet UIView *weaponView;
  IBOutlet UIView *lookView;
  IBOutlet UIView *moveView;
  IBOutlet UIView *leftFireView;
  IBOutlet UIView *rightFireView;

  HUDMode mode;
  
  SDLKey leftFireKey;
  SDLKey rightFireKey;
  
  SDLKey forwardKey;
  SDLKey backwardKey;
  SDLKey leftKey;
  SDLKey rightKey;
  SDLKey runKey;
  
  UISwipeGestureRecognizer *leftWeaponSwipe;
  UISwipeGestureRecognizer *rightWeaponSwipe;
  UIPanGestureRecognizer *panGesture;
  UIPanGestureRecognizer *leftShootPanGesture;
  UIPanGestureRecognizer *rightShootPanGesture;
  
  UIPanGestureRecognizer *moveGesture;
  UITapGestureRecognizer *menuTapGesture;
  CGPoint lastPanPoint;
  CGPoint moveCenterPoint;
  CGFloat moveRadius;
  CGFloat deadSpaceRadius;
}

+(GameViewController*)sharedInstance;
+(GameViewController*)createNewSharedInstance;

- (void)startGame;
- (void)setOpenGLView:(SDL_uikitopenglview*)oglView;

- (IBAction) leftTrigger:(id)sender;
- (IBAction) rightTrigger:(id)sender;
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;
- (void)handleLookGesture:(UIPanGestureRecognizer *)recognizer;
- (void)handleMoveGesture:(UIPanGestureRecognizer *)recognizer;
- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer;

- (CGPoint) transformTouchLocation:(CGPoint)location;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
  
@property (nonatomic, retain) SDL_uikitopenglview *viewGL;
@property (nonatomic, retain) IBOutlet UIView *hud;
@property (nonatomic, retain) IBOutlet UIView *weaponView;
@property (nonatomic, retain) IBOutlet UIView *lookView;
@property (nonatomic, retain) IBOutlet UIView *moveView;
@property (nonatomic, retain) IBOutlet UIView *leftFireView;
@property (nonatomic, retain) IBOutlet UIView *rightFireView;
@property (nonatomic, retain) IBOutlet UIButton *pause;
@property (nonatomic, retain) UISwipeGestureRecognizer *leftWeaponSwipe;
@property (nonatomic, retain) UISwipeGestureRecognizer *rightWeaponSwipe;
@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;
@property (nonatomic, retain) UIPanGestureRecognizer *leftShootPanGesture;
@property (nonatomic, retain) UIPanGestureRecognizer *rightShootPanGesture;
@property (nonatomic, retain) UIPanGestureRecognizer *moveGesture;
@property (nonatomic, retain) UITapGestureRecognizer *menuTapGesture;
@end
