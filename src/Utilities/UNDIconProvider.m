//
//  Copyright 2011 Kirk Kelsey.
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
//  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
//  for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with Understudy. If not, see <http://www.gnu.org/licenses/>.

#import "UNDIconProvider.h"

#import <Foundation/NSObject.h>

static NSString* path=@"/System/Library/CoreServices/Front Row.app/"
  "Contents/PlugIns/Understudy.frappliance/";

NSString* UNDIconID(void) {
  return [[path copy] autorelease];
}

BRImage* UNDIcon(void) {
  static BRImage* icon = nil;
  if (icon) return icon;

  NSBundle* bundle = [NSBundle bundleWithPath:path];
  NSDictionary* info = [bundle infoDictionary];
  NSString* iconFile = [info objectForKey:@"CFBundleIconFile"];
  NSString* iconPath = [bundle pathForResource:iconFile ofType:nil];

  icon = [[BRImage imageWithPath:iconPath] retain];
  return icon;
}
