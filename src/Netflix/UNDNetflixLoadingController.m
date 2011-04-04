//
//  Copyright 2010 Kirk Kelsey.
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

#import "UNDNetflixLoadingController.h"

#import "BRControllerStack.h"

@implementation UNDNetflixLoadingController

- (id)init
{
  return [super initWithTitle:@"Loading" text:@"Loading"];
}

- (void)assetUpdated:(UNDNetflixAsset*)asset
{
  // If the user got tired of waiting for the asset to finish loading and
  // popped this controller then don't attempt to push the asset's controller.
  if ([self active])
    [[self stack] swapController:[asset controller]];
}

@end
