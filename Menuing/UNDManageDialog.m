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

#import "UNDManageDialog.h"
#import "UNDPreferenceManager.h"
#import "UNDRenameDialog.h"

#import <BRControllerStack.h>
#import <BRListControl.h>
#import <BRTextMenuItemLayer.h>

@implementation UNDManageDialog

enum ManageOptionEnum
{
  AddOption = 0,
  RemoveOption,
  RenameOption,
  MoveOption,
  OptionCount // this must be immediately after the last valid option
};
typedef enum ManageOptionEnum ManageOption;

- (id)init
{
  [super init];
  [self setTitle:[self title]];
  addController_ = [[UNDAddAssetDialog alloc] init];
  [[self list] setDatasource:self];
  return self;
}

- (void)_presentMoveDialog
{
  [moveDialog_ release];
  moveDialog_ = [[BROptionDialog alloc] init];
  [moveDialog_ setTitle:@"Move Asset"];
  UNDPreferenceManager* prefs = [UNDPreferenceManager sharedInstance];
  for (NSDictionary* asset in [prefs assetDescriptions]) {
    NSString* title = [asset objectForKey:@"title"];
    if (!title) title = @"<untitled>";
    [moveDialog_ addOptionText:title];
  }
  [moveDialog_ setActionSelector:@selector(_moveFrom) target:self];
  [[self stack] pushController:moveDialog_];
}

- (void)_moveFrom
{
  [moveDialog_ setPrimaryInfoText:@"Select new position."
                   withAttributes:nil];
  [moveDialog_ setActionSelector:@selector(_moveTo) target:self];
  // misusing the |tag|, rather than using the user info
  [moveDialog_ setTag:[moveDialog_ selectedIndex]];
}

- (void)_moveTo
{
  long from = [moveDialog_ tag];
  long to = [moveDialog_ selectedIndex];
  [[UNDPreferenceManager sharedInstance] moveAssetFromIndex:from toIndex:to];
  [[self stack] popController];
}

- (void)_presentRemoveDialog
{
  [removeDialog_ release];
  removeDialog_ = [[BROptionDialog alloc] init];
  [removeDialog_ setTitle:@"Remove Asset"];

  UNDPreferenceManager* prefs = [UNDPreferenceManager sharedInstance];
  for (NSDictionary* asset in [prefs assetDescriptions]) {
    NSString* title = [asset objectForKey:@"title"];
    if (!title) title = @"<untitled>";
    [removeDialog_ addOptionText:title];
  }

  [removeDialog_ setActionSelector:@selector(_remove) target:self];
  [[self stack] pushController:removeDialog_];
}

// call back for the remove dialog
- (void)_remove
{
  long index = [removeDialog_ selectedIndex];
  [[UNDPreferenceManager sharedInstance] removeAssetAtIndex:index];
  [[self stack] popController];
}

- (void)_presentRenameDialog
{
  UNDRenameDialog* rename = [[UNDRenameDialog alloc] init];
  [[self stack] pushController:rename];
  [rename autorelease];
}

#pragma mark Controller

- (void)itemSelected:(long)index
{
  ManageOption option = (ManageOption)index;
  switch( option )
  {
    case AddOption:
      [[self stack] pushController:addController_];
      break;
    case RemoveOption:
      [self _presentRemoveDialog];
      break;
    case RenameOption:
      [self _presentRenameDialog];
      break;
    case MoveOption:
      [self _presentMoveDialog];
      break;
    case OptionCount:
      break;
  }
}

- (void)controlWillActivate
{
  [super controlWillActivate];
  [[self list] reload];
  if( ![self rowSelectable:[self selectedItem]] )
    [self setSelectedItem:0];
}

#pragma mark MenuListItemProvider

- (long)itemCount{ return OptionCount; }
- (float)heightForRow:(long)row{ return 0; }
- (BOOL)rowSelectable:(long)row
{
  int count
    = [[[UNDPreferenceManager sharedInstance] assetDescriptions] count];
  return (row == 0 || count > 0);
}

- (id)titleForRow:(long)row
{
  ManageOption option = (ManageOption)row;
  switch (option) {
    case AddOption: return @"Add";
    case RemoveOption: return @"Remove";
    case RenameOption: return @"Rename";
    case MoveOption: return @"Move";
    case OptionCount: break;
  }
  return @"";
}

- (id)itemForRow:(long)row
{
  BRTextMenuItemLayer* item = [BRTextMenuItemLayer menuItem];
  [item setTitle:[self titleForRow:row]];
  if( ![self rowSelectable:row] ) [item setDimmed:YES];
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
  return @"Manage Assets";
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
