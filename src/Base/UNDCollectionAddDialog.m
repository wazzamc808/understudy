//
//  Copyright 2011 Kirk Kelsey.
//
//  This file is part of Understudy.
//
//  Understudy is free software: you can redistribute it and/or modify it
//  under the terms of the GNU Lesser General Public License as published
//  by the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Understudy is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
//  General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public
//  License along with Understudy. If not, see
//  <http://www.gnu.org/licenses/>.

#import "UNDCollectionAddDialog.h"

#import "BRControllerStack.h"

#import "UNDCollectionProvider.h"

@implementation UNDCollectionAddDialog

- (void)setCollection:(UNDMutableCollection*)collection
{
  collection_ = collection;
}

- (void)controlWasActivated
{
  [super controlWasActivated];
  NSMutableDictionary* asset =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Collection",
                         @"title", UNDCollectionProviderId, @"provider",
                         nil];
  [collection_ addAssetWithDescription:asset atIndex:LONG_MAX];
  [[self stack] popController];
}

- (void)controlWasDeactivated
{
  [super controlWasDeactivated];
  collection_ = nil;
}

@end
