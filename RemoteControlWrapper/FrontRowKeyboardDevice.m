/*****************************************************************************
 * FrontRowKeyboardDevice.m
 * Understudy
 *
 * Created by Kirk Kelsey under a MIT-style license. 
 * Copyright (c) 2009 0x4b.net All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a 
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *****************************************************************************/


#import "FrontRowKeyboardDevice.h"

@implementation FrontRowKeyboardDevice

- (id) initWithDelegate:(id) _remoteControlDelegate 
{	
  self = [super initWithDelegate:_remoteControlDelegate];

  // arrow keys
  [self registerHotKeyCode:123
                 modifiers:0
     remoteEventIdentifier:kRemoteButtonLeft];

  [self registerHotKeyCode:124
                 modifiers:0
     remoteEventIdentifier:kRemoteButtonRight];

  [self registerHotKeyCode:125
                 modifiers:0
     remoteEventIdentifier:kRemoteButtonPlus];

  [self registerHotKeyCode:126
                 modifiers:0
     remoteEventIdentifier:kRemoteButtonMinus];

  // ESC
  [self registerHotKeyCode:53
                 modifiers:0
     remoteEventIdentifier:kRemoteButtonMenu];

  // space & enter
  [self registerHotKeyCode:49
                 modifiers:0
     remoteEventIdentifier:kRemoteButtonPlay];
  [self registerHotKeyCode:36
                 modifiers:0
     remoteEventIdentifier:kRemoteButtonPlay];

  return self;
}

+ (const char*) remoteControlDeviceName 
{
  return "FR-Keyboard";
}

@end
