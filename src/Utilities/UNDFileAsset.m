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

#import "Utilities/UNDFileAsset.h"

#import <BRHeaders/BRImage.h>

@implementation UNDFileAsset

-(id)initWithPath:(NSString*)path
{
  path_ = [path copy];
  NSString* title = [path lastPathComponent];

  // If the path is a bundle, attempt to get its icon.
  NSBundle* bundle = [NSBundle bundleWithPath:path];
  if (bundle) {
    NSDictionary* info = [bundle infoDictionary];
    NSString* iconFile = [info objectForKey:@"CFBundleIconFile"];
    NSString* iconPath = [bundle pathForResource:iconFile ofType:nil];
    image_ = [[BRImage imageWithPath:iconPath] retain];
    title = [title stringByDeletingPathExtension];
  }

  return [super initWithTitle:title];
}

-(void)dealloc
{
  [path_ release];
  [image_ release];
  [super dealloc];
}

-(NSString*)path
{
  return path_;
}

- (BRImage*)coverArt{ return image_; }

@end
