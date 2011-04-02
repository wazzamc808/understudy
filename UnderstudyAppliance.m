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
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
//  for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with Understudy.  If not, see <http://www.gnu.org/licenses/>.

#import "UnderstudyAppliance.h"

#import "BRControllerStack.h"
#import "BRSentinel.h"

#import "UNDMenuController.h"
#import "UNDMutableCollection.h"
#import "UNDPreferenceManager.h"

@implementation BRSentinel (UNDExposeStack)
- (BRControllerStack*)stack
{
  return _controllerStack;
}
@end

@implementation UnderstudyAppliance

- (BRController*)applianceController
{
  static UNDMutableCollection* collection = nil;
  if (!collection) {
    NSMutableArray* descriptions
      = [[UNDPreferenceManager sharedInstance] assetDescriptions];

    collection
      = [[[UNDMutableCollection alloc]
           initWithTitle:@"Understudy" forContents:descriptions] autorelease];
  }

  return [collection controller];
}

+ (NSString *)className
{
  return [NSString stringWithString:@"RUIDVDAppliance"];
}

- (NSString*)version
{
  return @"1.0"; // kFrontRowCurrentApplianceProtocolVersion
}

@end
