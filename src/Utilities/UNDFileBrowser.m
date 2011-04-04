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

#import "UNDFileBrowser.h"

#import <BRControllerStack.h>

#import "UNDFileAsset.h"
#import "UNDFileCollection.h"

@implementation UNDFileBrowser

-(id)initWithPath:(NSString*)path
{
  fileCollection_
    = [[[UNDFileCollection alloc] initWithPath:path] retain];
  [super initWithDelegate:fileCollection_];
  return self;
}

-(void)dealloc
{
  [fileCollection_ release];
  [super dealloc];
}

-(void)itemSelected:(long)itemIndex
{
  if (![self rowSelectable:itemIndex]) return;

  UNDFileAsset* asset
    = [[fileCollection_ currentAssets] objectAtIndex:itemIndex];

  [fileBrowserDelegate_ fileSelected:[asset path]];

  [[self stack] popController];
}

-(void)setDelegate:(NSObject<UNDFileBrowserDelegate>*)delegate
{
  [fileBrowserDelegate_ autorelease];
  fileBrowserDelegate_ = [delegate retain];
}

@end
