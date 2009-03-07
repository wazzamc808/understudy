//
//  Copyright 2008-2009 Kirk Kelsey.
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

#import "BackRow/BRController.h"

#import "HuluAsset.h"
#import "UNDHuluSelector.h"

@interface HuluController : BaseController {
 @private
  HuluAsset* asset_;
  NSWindow* window_;     // original window created to load content
  NSWindow* fsWindow_;   // window created when the player goes full screen
  UNDHuluSelector* selector_;  // to indicate which button to select
  BRController* alert_;
}

- (id)initWithAsset:(HuluAsset*)asset;

@end
