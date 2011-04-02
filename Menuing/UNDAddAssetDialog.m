//
//  Copyright 2008-2010 Kirk Kelsey.
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

#import "UNDAddAssetDialog.h"
#import "UNDAssetFactory.h"

#import <BRControllerStack.h>

#import <AppKit/NSPasteboard.h>

@implementation UNDAddAssetDialog

- (id)init
{
  [super init];
  [self setTitle:@"Add Asset"];
  NSArray* providers = [[UNDAssetFactory sharedInstance] providers];
  dialogs_ = [[NSMutableArray alloc] init];
  for (NSObject<UNDAssetProvider>* provider in providers) {
    id dialog = [provider assetAdditionDialog];
    if (dialog) {
      [dialogs_ addObject:dialog];
      [self addOptionText:[provider providerName]];
    }
  }
  [self setActionSelector:@selector(itemSelected) target:self];
  return self;
}

- (void)dealloc
{
  [dialogs_ release];
  [super dealloc];
}

- (void)setCollection:(UNDMutableCollection*)collection
{
  collection_ = collection;
}

- (void)controlWasDeactivated
{
  [super controlWasDeactivated];
  collection_ = nil;
}

// call-back for an item having been selected
- (void)itemSelected
{
  id<UNDCollectionMutator> dialog
    = [dialogs_ objectAtIndex:[self selectedIndex]];
  [dialog setCollection:collection_];
  [[self stack] pushController:dialog];
}

@end
