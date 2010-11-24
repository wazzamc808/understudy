//
//  Copyright 2009 Kirk Kelsey.
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

#import "UNDHuluDesktopAsset.h"
#import "UNDExternalLaunchController.h"
#import "BRTextMenuItemLayer.h"

@implementation UNDHuluDesktopAsset

static NSString* title = @"Hulu Desktop Player";

- (void)dealloc
{
  [menuitem_ release];
  [controller_ release];
  [super dealloc];
}

- (BRLayer<BRMenuItemLayer>*)menuItem
{
  if( !menuitem_ )
  {
    menuitem_ = [BRTextMenuItemLayer menuItem];
    [menuitem_ setTitle:title];
    [menuitem_ retain];
  }
  return menuitem_;
}

- (BRController*)controller
{
  if( !controller_ ) {
    controller_ = [[UNDExternalLaunchController alloc]
                    initWithTitle:title
                      andBundleID:@"com.hulu.HuluDesktop"];
  }
  return controller_;
}

@end
