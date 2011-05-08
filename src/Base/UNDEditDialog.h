//
//  Copyright 2008,2010-2011 Kirk Kelsey.
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
//  along with Understudy.  If not, see <http://www.gnu.org/licenses/>.

#import <Cocoa/Cocoa.h>

#import <BRHeaders/BROptionDialog.h>
#import <BRHeaders/BRMenuListItemProvider-Protocol.h>
#import <BRHeaders/BRCenteredMenuController.h>

#import "Base/UNDMutableCollection.h"

@interface UNDEditDialog : BRCenteredMenuController
<BRMenuListItemProvider, UNDAsset>
{
  UNDMutableCollection* collection_;
  long index_;                  //< Selected index in the collection.
  NSString* title_;
  BROptionDialog* moveDialog_;
}

/// Returns a new UNDEditDialog for the asset at a given index in a collection.
- (id)initWithCollection:(UNDMutableCollection*)collection
                forIndex:(long)index;

@end
