/*
 SDL - Simple DirectMedia Layer
 Copyright (C) 1997-2009 Sam Lantinga
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 
 Sam Lantinga
 slouken@libsdl.org
 */

#import "SDL_uikitview.h"

#include "SDL_stdinc.h"
#include "SDL_mouse.h"
#include "SDL_mouse_c.h"
#include "SDL_events.h"

#if SDL_IPHONE_KEYBOARD
#import "SDL_keyboard_c.h"
#import "keyinfotable.h"
#import "SDL_uikitappdelegate.h"
#import "SDL_uikitwindow.h"
#endif

@implementation SDL_uikitview
@synthesize hud;

- (void)dealloc {
#if SDL_IPHONE_KEYBOARD
	SDL_DelKeyboard(0);
	[textField release];
#endif
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame {

	self = [super initWithFrame: frame];
	
#if SDL_IPHONE_KEYBOARD
	[self initializeKeyboard];
#endif	

	return self;

}

/*
- (CGPoint) transformTouchLocation:(CGPoint)location {
  CGPoint newLocation;
  newLocation.x = location.y;
  newLocation.y = self.frame.size.width - location.x;
  return newLocation;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

  for ( UITouch *touch in touches ) {
    if ( touch.tapCount == 1 ) {
      // Simulate a mouse event 
      
      CGPoint location = [self transformTouchLocation:[touch locationInView:self]];
      NSLog(@"touchesBegan location: %@", NSStringFromCGPoint(location));
      SDL_SendMouseMotion(0, location.x, location.y);
      SDL_SendMouseButton(SDL_PRESSED, SDL_BUTTON_LEFT);
      SDL_GetRelativeMouseState(NULL, NULL);
    }
  }

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
  for ( UITouch *touch in touches ) {
    CGPoint location = [self transformTouchLocation:[touch locationInView:self]];
    NSLog(@"touchesMoved location %@", NSStringFromCGPoint(location));
    SDL_SendMouseMotion(0, location.x, location.y);
  }
  
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
  for ( UITouch *touch in touches ) {
    if ( touch.tapCount == 1 ) {
      // Simulate a mouse event
      CGPoint location = [self transformTouchLocation:[touch locationInView:self]];
      NSLog(@"touchesEnded location: %@", NSStringFromCGPoint(location));
      SDL_SendMouseButton(SDL_RELEASED, SDL_BUTTON_LEFT);
    }
  }
}
*/


/*
	---- Keyboard related functionality below this line ----
*/
#if SDL_IPHONE_KEYBOARD

/* Is the iPhone virtual keyboard visible onscreen? */
- (BOOL)keyboardVisible {
	return keyboardVisible;
}

/* Set ourselves up as a UITextFieldDelegate */
- (void)initializeKeyboard {
		
	textField = [[[UITextField alloc] initWithFrame: CGRectZero] autorelease];
	textField.delegate = self;
	/* placeholder so there is something to delete! */
	textField.text = @" ";	
	
	/* set UITextInputTrait properties, mostly to defaults */
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.enablesReturnKeyAutomatically = NO;
	textField.keyboardAppearance = UIKeyboardAppearanceDefault;
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.returnKeyType = UIReturnKeyDefault;
	textField.secureTextEntry = NO;	
	
	textField.hidden = YES;
	keyboardVisible = NO;
	/* add the UITextField (hidden) to our view */
	[self addSubview: textField];
	
	/* create our SDL_Keyboard */
	SDL_Keyboard keyboard;
	SDL_zero(keyboard);
	SDL_AddKeyboard(&keyboard, 0);
	SDLKey keymap[SDL_NUM_SCANCODES];
	SDL_GetDefaultKeymap(keymap);
	SDL_SetKeymap(0, 0, keymap, SDL_NUM_SCANCODES);
	
}

/* reveal onscreen virtual keyboard */
- (void)showKeyboard {
	keyboardVisible = YES;
	[textField becomeFirstResponder];
}

/* hide onscreen virtual keyboard */
- (void)hideKeyboard {
	keyboardVisible = NO;
	[textField resignFirstResponder];
}

/* UITextFieldDelegate method.  Invoked when user types something. */
- (BOOL)textField:(UITextField *)_textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if ([string length] == 0) {
		/* it wants to replace text with nothing, ie a delete */
		SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_DELETE);
		SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_DELETE);
	}
	else {
		/* go through all the characters in the string we've been sent
		   and convert them to key presses */
		int i;
		for (i=0; i<[string length]; i++) {
			
			unichar c = [string characterAtIndex: i];
			
			Uint16 mod = 0;
			SDL_scancode code;
			
			if (c < 127) {
				/* figure out the SDL_scancode and SDL_keymod for this unichar */
				code = unicharToUIKeyInfoTable[c].code;
				mod  = unicharToUIKeyInfoTable[c].mod;
			}
			else {
				/* we only deal with ASCII right now */
				code = SDL_SCANCODE_UNKNOWN;
				mod = 0;
			}
			
			if (mod & KMOD_SHIFT) {
				/* If character uses shift, press shift down */
				SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_LSHIFT);
			}
			/* send a keydown and keyup even for the character */
			SDL_SendKeyboardKey( 0, SDL_PRESSED, code);
			SDL_SendKeyboardKey( 0, SDL_RELEASED, code);
			if (mod & KMOD_SHIFT) {
				/* If character uses shift, press shift back up */
				SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_LSHIFT);
			}			
		}
	}
	return NO; /* don't allow the edit! (keep placeholder text there) */
}

/* Terminates the editing session */
- (BOOL)textFieldShouldReturn:(UITextField*)_textField {
	[self hideKeyboard];
	return YES;
}

#endif

@end

/* iPhone keyboard addition functions */
#if SDL_IPHONE_KEYBOARD

int SDL_iPhoneKeyboardShow(SDL_Window * window) {
	
	SDL_WindowData *data;
	SDL_uikitview *view;
	
	if (NULL == window) {
		SDL_SetError("Window does not exist");
		return -1;
	}
	
	data = (SDL_WindowData *)window->driverdata;
	view = data->view;
	
	if (nil == view) {
		SDL_SetError("Window has no view");
		return -1;
	}
	else {
		[view showKeyboard];
		return 0;
	}
}

int SDL_iPhoneKeyboardHide(SDL_Window * window) {
	
	SDL_WindowData *data;
	SDL_uikitview *view;
	
	if (NULL == window) {
		SDL_SetError("Window does not exist");
		return -1;
	}	
	
	data = (SDL_WindowData *)window->driverdata;
	view = data->view;
	
	if (NULL == view) {
		SDL_SetError("Window has no view");
		return -1;
	}
	else {
		[view hideKeyboard];
		return 0;
	}
}

SDL_bool SDL_iPhoneKeyboardIsShown(SDL_Window * window) {
	
	SDL_WindowData *data;
	SDL_uikitview *view;
	
	if (NULL == window) {
		SDL_SetError("Window does not exist");
		return -1;
	}	
	
	data = (SDL_WindowData *)window->driverdata;
	view = data->view;
	
	if (NULL == view) {
		SDL_SetError("Window has no view");
		return 0;
	}
	else {
		return view.keyboardVisible;
	}
}

int SDL_iPhoneKeyboardToggle(SDL_Window * window) {
	
	SDL_WindowData *data;
	SDL_uikitview *view;
	
	if (NULL == window) {
		SDL_SetError("Window does not exist");
		return -1;
	}	
	
	data = (SDL_WindowData *)window->driverdata;
	view = data->view;
	
	if (NULL == view) {
		SDL_SetError("Window has no view");
		return -1;
	}
	else {
		if (SDL_iPhoneKeyboardIsShown(window)) {
			SDL_iPhoneKeyboardHide(window);
		}
		else {
			SDL_iPhoneKeyboardShow(window);
		}
		return 0;
	}
}

#else

/* stubs, used if compiled without keyboard support */

int SDL_iPhoneKeyboardShow(SDL_Window * window) {
	SDL_SetError("Not compiled with keyboard support");
	return -1;
}

int SDL_iPhoneKeyboardHide(SDL_Window * window) {
	SDL_SetError("Not compiled with keyboard support");
	return -1;
}

SDL_bool SDL_iPhoneKeyboardIsShown(SDL_Window * window) {
	return 0;
}

int SDL_iPhoneKeyboardToggle(SDL_Window * window) {
	SDL_SetError("Not compiled with keyboard support");
	return -1;
}


#endif /* SDL_IPHONE_KEYBOARD */



#if 0
// Original code
- (id)initWithFrame:(CGRect)frame {
  
	self = [super initWithFrame: frame];
	
#if SDL_IPHONE_KEYBOARD
	[self initializeKeyboard];
#endif	
  
#if FIXME_MULTITOUCH
	int i;
	for (i=0; i<MAX_SIMULTANEOUS_TOUCHES; i++) {
    mice[i].id = i;
		mice[i].driverdata = NULL;
		SDL_AddMouse(&mice[i], "Mouse", 0, 0, 1);
	}
	self.multipleTouchEnabled = YES;
#endif
  
	return self;
  
}
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  for ( UITouch *touch in touches ) {
    if ( touch.tapCount == 1 ) {
      // Simulate a mouse event
      CGPoint location = [self transformTouchLocation:[touch locationInView:self]];
      NSLog(@"Mouse event at location: %@", NSStringFromCGPoint(location));
      SDL_SendMouseMotion(0, location.y, location.x);
      SDL_SendMouseButton(SDL_PRESSED, SDL_BUTTON_LEFT);
      SDL_GetRelativeMouseState(NULL, NULL);
    }
  }
*/
#if FIXME_MULTITOUCH
	/* associate touches with mice, so long as we have slots */
	int i;
	int found = 0;
	for(i=0; touch && i < MAX_SIMULTANEOUS_TOUCHES; i++) {
    
		/* check if this mouse is already tracking a touch */
		if (mice[i].driverdata != NULL) {
			continue;
		}
		/*	
     mouse not associated with anything right now,
     associate the touch with this mouse
     */
		found = 1;
		
		/* save old mouse so we can switch back */
		int oldMouse = SDL_SelectMouse(-1);
		
		/* select this slot's mouse */
		SDL_SelectMouse(i);
		CGPoint locationInView = [touch locationInView: self];
		
		/* set driver data to touch object, we'll use touch object later */
		mice[i].driverdata = [touch retain];
		
		/* send moved event */
    // DJB  Need to swap x and y because of the rotated OpenGL context
		// SDL_SendMouseMotion(i, 0, locationInView.x, locationInView.y, 0);
		SDL_SendMouseMotion(i, 0, locationInView.x, locationInView.y, 0);
		
		/* send mouse down event */
		SDL_SendMouseButton(i, SDL_PRESSED, SDL_BUTTON_LEFT);
		
		/* re-calibrate relative mouse motion */
		SDL_GetRelativeMouseState(i, NULL, NULL);
		
		/* grab next touch */
		touch = (UITouch*)[enumerator nextObject]; 
		
		/* switch back to our old mouse */
		SDL_SelectMouse(oldMouse);
		
	}
#endif
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
  for ( UITouch *touch in touches ) {
    if ( touch.tapCount == 1 ) {
      // Simulate a mouse event
      NSLog(@"Mouse event at location: %@", NSStringFromCGPoint([touch locationInView:self]));
      SDL_SendMouseButton(SDL_RELEASED, SDL_BUTTON_LEFT);
    }
  }
  
	
#if FIXME_MULTITOUCH
	while(touch = (UITouch *)[enumerator nextObject]) {
		/* search for the mouse slot associated with this touch */
		int i, found = NO;
		for (i=0; i<MAX_SIMULTANEOUS_TOUCHES && !found; i++) {
			if (mice[i].driverdata == touch) {
				/* found the mouse associate with the touch */
				[(UITouch*)(mice[i].driverdata) release];
				mice[i].driverdata = NULL;
				/* send mouse up */
				SDL_SendMouseButton(i, SDL_RELEASED, SDL_BUTTON_LEFT);
				/* discontinue search for this touch */
				found = YES;
			}
		}
	}
#endif
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
  for ( UITouch *touch in touches ) {
    CGPoint location = [self transformTouchLocation:[touch locationInView:self]];
    NSLog(@"Sending mouse motion to point %@", NSStringFromCGPoint(location));
		SDL_SendMouseMotion(0, location.y, location.x);
	}
  
	NSEnumerator *enumerator = [touches objectEnumerator];
	UITouch *touch=nil;
	
#if FIXME_MULTITOUCH
	while(touch = (UITouch *)[enumerator nextObject]) {
		/* try to find the mouse associated with this touch */
		int i, found = NO;
		for (i=0; i<MAX_SIMULTANEOUS_TOUCHES && !found; i++) {
			if (mice[i].driverdata == touch) {
				/* found proper mouse */
				CGPoint locationInView = [touch locationInView: self];
				/* send moved event */
				// DJB  Need to swap touch locations!
        // SDL_SendMouseMotion(i, 0, locationInView.x, locationInView.y, 0);
				SDL_SendMouseMotion(i, 0, locationInView.y, locationInView.x, 0);
				/* discontinue search */
				found = YES;
			}
		}
	}
#endif
}

#endif
