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

#import "Base/UNDExternalAppAddDialog.h"

#import <BRHeaders/BRControllerStack.h>

#import "Base/UNDAssetFactory.h"
#import "Base/UNDExternalAppAssetProvider.h"
#import "Base/UNDMutableCollection.h"

@implementation UNDExternalAppAddDialog

- (void)setCollection:(UNDMutableCollection*)collection
{
  collection_ = collection;
}

-(void)fileSelected:(NSString*)path
{
  NSString* title
    = [[path substringToIndex:[path length] - 4] lastPathComponent];
  NSDictionary* asset =
    [NSDictionary dictionaryWithObjectsAndKeys:title, UNDExternalAppAssetKey,
                  UNDExternalAppAssetProviderId, UNDAssetProviderNameKey,
                  title, UNDAssetProviderTitleKey, nil];

  [collection_ addAssetWithDescription:asset
                               atIndex:LONG_MAX];
}

// TODO: try swapping before activate is complete
-(void)controlWasActivated
{
  [super controlWasActivated];
  UNDFileBrowser* browser
    = [[UNDFileBrowser alloc] initWithPath:@"/Applications"];
  [browser setDelegate:self];
  [[self stack] swapController:browser];
}

@end
