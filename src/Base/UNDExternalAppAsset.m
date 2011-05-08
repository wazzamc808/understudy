//
//  Copyright 2009-2011 Kirk Kelsey.
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

#import "UNDExternalAppAsset.h"

#import <BRHeaders/BRImage.h>
#import <BRHeaders/BRTextMenuItemLayer.h>

#import "UNDExternalLaunchController.h"

@implementation UNDExternalAppAsset

- (id)initWithAppName:(NSString*)appName
{
  [super initWithTitle:appName];
  appName_ = [appName copy];
  NSWorkspace* workspace = [NSWorkspace sharedWorkspace];
  NSString* path = [workspace fullPathForApplication:appName_];
  NSBundle* bundle = [NSBundle bundleWithPath:path];
  NSDictionary* info = [bundle infoDictionary];
  NSString* iconFile = [info objectForKey:@"CFBundleIconFile"];
  NSString* iconPath = [bundle pathForResource:iconFile ofType:nil];

  image_ = [[BRImage imageWithPath:iconPath] retain];

  return self;
}

- (void)dealloc
{
  [appName_ release];
  [controller_ release];
  [image_ release];
  [super dealloc];
}

- (BRController*)controller
{
  if( !controller_ ) {
    controller_ = [[UNDExternalLaunchController alloc]
                    initWithTitle:appName_ forApp:appName_];
  }
  return controller_;
}

- (BRImage*)coverArt{ return image_; }

@end
