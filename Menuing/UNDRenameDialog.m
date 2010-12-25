//
//  Copyright 2009,2010 Kirk Kelsey.
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

#import "BRControllerStack.h"
#import "BRTextContainer-Protocol.h"

#import "MainMenuController.h"
#import "UNDRenameDialog.h"
#import "UNDPreferenceManager.h"


@implementation UNDRenameDialog

- (id)init
{
  [super init];
  [self setActionSelector:@selector(itemSelected) target:self];

  UNDPreferenceManager* prefs = [UNDPreferenceManager sharedInstance];
  for (NSDictionary* asset in [prefs assetDescriptions])
    [self addOptionText:[asset objectForKey:@"title"]];

  [self setTitle:@"Rename Asset"];
  [self setPrimaryInfoText:@"Select an asset to rename" withAttributes:nil];
  return self;
}

- (void)itemSelected
{
  BRTextEntryController* entry = [BRTextEntryController alloc];
  entry = [entry initWithTextEntryStyle:0];
  [entry setTextEntryCompleteDelegate:self];
  [entry setTitle:@"New Name"];
  [[self stack] pushController:entry];
}

- (void)textDidChange:(id)container{ }

- (void)textDidEndEditing:(id)container
{
  long index = [self selectedIndex];
  UNDPreferenceManager* pref = [UNDPreferenceManager sharedInstance];
  NSMutableDictionary* asset =
    [[[pref assetDescriptions] objectAtIndex:index] mutableCopy];
  [asset setObject:[container stringValue] forKey:@"title"];
  [pref replaceAssetDescriptionAtIndex:[self selectedIndex]
                       withDescription:[asset autorelease]];
  [[self stack] popToController:[MainMenuController sharedInstance]];
}

@end
