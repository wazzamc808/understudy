//
//  Copyright 2009, 2011 Kirk Kelsey.
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

#import "UNDBaseAsset.h"

#import <BRControl.h>
#import <BRMediaPreviewControllerFactory.h>
#import <BRTextMenuItemLayer.h>

@implementation UNDBaseAsset

- (id)initWithTitle:(NSString*)title
{
  [super init];
  title_ = [title copy];
  return self;
}

- (void)dealloc
{
  [preview_ release];
  [title_ release];
  [super dealloc];
}

- (BRLayer<BRMenuItemLayer>*)menuItem
{
  if (!menuItem_) {
    BRTextMenuItemLayer* menuItem = [[BRTextMenuItemLayer menuItem] retain];
    [menuItem setTitle:title_];
    menuItem_ = menuItem;
  }
  return menuItem_;
}

- (BRControl*)preview
{
  if (!preview_) {
    preview_ = [BRMediaPreviewControllerFactory previewControlForAsset:self
                                                          withDelegate:self];
    [preview_ retain];
  }
  return preview_;
}

- (NSString*)title
{
  return title_;
}

#pragma mark BRMediaPreviewFactoryDelegate
- (id)mediaPreviewMissingMediaType{ return nil; }
- (BOOL)mediaPreviewShouldShowMetadata{ return YES; }
- (BOOL)mediaPreviewShouldShowMetadataImmediately{ return YES; }

@end
