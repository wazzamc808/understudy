//
//  Copyright 2008-2011 Kirk Kelsey.
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

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <RemoteControlWrapper/RemoteControl.h>

#import "Utilities/UNDSelector.h"
#import "Utilities/UNDPluginControl.h"

@interface UNDNetflixPlayer : NSObject {
  WebView*               mainView_;
  UNDPluginControl*      pluginControl_;
  UNDPluginControl*      fsControl_;
  NSWindow*              window_;   // original window
  NSWindow*              fsWindow_; // created when player goes full screen
  BOOL                   shouldReturnToFR_;
  CGEventSourceRef       eventSource_;
}

@property(nonatomic) BOOL shouldReturnToFR;


- (void)loadURL:(NSURL*)url;

- (void) sendRemoteButtonEvent:(RemoteControlEventIdentifier) event 
                   pressedDown:(BOOL) pressedDown 
                 remoteControl:(RemoteControl*) remoteControl;

@end
