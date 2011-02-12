//
//  Copyright 2008-2011 Kirk Kelsey.
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

#import <BRControllerStack.h>
#import <BRMenuListItemProvider-Protocol.h>
#import <BRListControl.h>
#import <BRTextMenuItemLayer.h>

#import "UNDEditDialog.h"
#import "UnderstudyAsset.h"

@implementation UNDEditDialog

typedef enum
{
  kSelectOption = 0,
  kRemoveOption,
  kRenameOption,
  kMoveOption,
  kOptionCount // this must be immediately after the last valid option
} ManageOption;

- (id)initWithCollection:(UNDMutableCollection*)collection
                forIndex:(long)index
{
  [super init];
  collection_ = [collection retain];
  [self setTitle:[self title]];
  index_ = index;
  [[self list] setDatasource:self];
  return self;
}

- (void)dealloc
{
  [collection_ release];
  [title_ release];
  [super dealloc];
}

#pragma mark Controller

- (void)itemSelected:(long)index
{
  NSArray* assets;
  ManageOption option = (ManageOption)index;
  switch (option) {
  case kSelectOption:
    assets = [collection_ currentAssets];
    NSObject<UnderstudyAsset>* asset = [assets objectAtIndex:index_];
    [[self stack] swapController:[asset controller]];
    break;
  case kRemoveOption:
    [collection_ removeAssetAtIndex:index_];
    break;
  case kRenameOption:
    break;
  case kMoveOption:
    break;
  case kOptionCount:
    break;
  }
}

- (void)controlWillActivate
{
  [super controlWillActivate];
  [[self list] reload];
  if (![self rowSelectable:[self selectedItem]])
    [self setSelectedItem:0];
}

#pragma mark MenuListItemProvider

- (long)itemCount{ return kOptionCount; }
- (float)heightForRow:(long)row{ return 0; }
- (BOOL)rowSelectable:(long)row
{
  return (row >= 0 || row < kOptionCount);
}

- (id)titleForRow:(long)row
{
  ManageOption option = (ManageOption)row;
  switch (option) {
  case kSelectOption: return @"Select";
  case kRemoveOption: return @"Remove";
  case kRenameOption: return @"Rename";
  case kMoveOption:   return @"Move";
  case kOptionCount: break;
  }
  return @"";
}

- (id)itemForRow:(long)row
{
  BRTextMenuItemLayer* item = [BRTextMenuItemLayer menuItem];
  [item setTitle:[self titleForRow:row]];
  if (![self rowSelectable:row]) [item setDimmed:YES];
  return item;
}

#pragma mark Understudy Asset
- (BRLayer<BRMenuItemLayer>*)menuItem
{
  BRTextMenuItemLayer* manager = [BRTextMenuItemLayer menuItem];
  [manager setTitle:[self title]];
  return manager;
}

- (BRController*)controller{ return self; }

- (NSString*)title
{
  if (title_) return title_;
  title_ = [[NSString stringWithString:@"Manage Asset"] retain];
  if (!collection_) return title_;
  NSArray* assets = [[[collection_ currentAssets] retain] autorelease];
  if (index_ >= [assets count]) return title_;
  title_ = [[(id<UnderstudyAsset>)[assets objectAtIndex:index_] title] copy];
  return title_;
}

- (NSArray*)containedAssets
{
  return nil;
}

- (BRControl*)preview
{
  return nil;
}

@end
