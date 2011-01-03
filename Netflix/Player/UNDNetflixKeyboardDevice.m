/*****************************************************************************
 * UNDNetflixRowKeyboardDevice.m
 * Understudy
 *
 * Created by Kirk Kelsey under a MIT-style license.
 * Copyright (c) 2010 0x4b.net All rights reserved.
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

#import "GlobalKeyboardDevice.h"

@interface UNDNetflixKeyboardDevice : GlobalKeyboardDevice
@end

@implementation UNDNetflixKeyboardDevice

- (id) initWithDelegate:(id) _remoteControlDelegate
{
  self = [super initWithDelegate:_remoteControlDelegate];

  // ESC - Netflix uses it to exit fullscreen, but we want to use it to exit
  // (maps to the Menu button).
  [self registerHotKeyCode:53
                 modifiers:0
     remoteEventIdentifier:kRemoteButtonMenu];

  // Enter maps to the play/pause. We don't want to map space, since it is
  // already handled by Netflix to do play/pause. Mapping it here will prevent
  // the silverlight player from getting the key.
  // [self registerHotKeyCode:36
  //                modifiers:0
  //    remoteEventIdentifier:kRemoteButtonAlPlay];

  return self;
}

+ (const char*) remoteControlDeviceName
{
  return "UNDNetflix-Keyboard";
}

@end
