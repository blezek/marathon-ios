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
  IBOutlet UIView *view;
  IBOutlet UIView *hud;
  IBOutlet UIButton *pause;
  SDLKey leftFireKey;
  SDLKey rightFireKey;
}

- (void)startGame;
- (IBAction) leftTrigger:(id)sender;
- (IBAction) rightTrigger:(id)sender;

- (CGPoint) transformTouchLocation:(CGPoint)location;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
  
@property (nonatomic, retain) SDL_uikitopenglview *viewGL;
@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) UIView *hud;
@property (nonatomic, retain) UIButton *pause;
@end

extern GameViewController *globalGameView;