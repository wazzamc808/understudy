//
//  Copyright 2008 Kirk Kelsey.
//
//  This file is part of Understudy.
//
//  Understudy is free software: you can redistribute it and/or modify it under
//  the terms of the GNU Lesser General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  Understudy is distributed in the hope that it will be useful, but WITHOUT 
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
//  for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with Understudy.  If not, see <http://www.gnu.org/licenses/>.

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import <BackRow/BRController.h>

@interface WebView (KeyboardShortcuts)
- (void)sendKeyCode:(int)keyCode withCharCode:(int)charCode;
@end

@interface BaseController : BRController {
}


// orders out the FR interface to reveal an understudy player
- (void)reveal;

// brings the FR interface back
- (void)returnToFR;

- (WebView*)pluginChildOfView:(WebView*)view;
- (void)makeViewFullscreen:(WebView*)view;
// subclasses should override (default does nothing):
- (void)playPause;

@end

