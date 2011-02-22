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

#import "UNDUnknownAsset.h"

#import "BRAlertController.h"
#import "BRTextMenuItemLayer.h"

@implementation UNDUnknownAsset

- (id)initWithObject:(NSObject*)object
{
  [super init];
  object_ = [object retain];
  return self;
}

- (void)dealloc
{
  [object_ release];
  [super dealloc];
}

- (BRLayer<BRMenuItemLayer>*)menuItem
{
  BRTextMenuItemLayer*item = [BRTextMenuItemLayer menuItem];
  [item setTitle:[self title]];
  [item setDimmed:YES];
  return item;
}

- (BRController*)controller
{
  BRAlertController* controller =
    [BRAlertController alertOfType:0 // Informational alert.
                            titled:@"Unknown Media Type"
                       primaryText:@"Understudy Doesn't know how to handle:"
                     secondaryText:[object_ description]];
  return controller;
}

- (NSString*)title
{
  if ([object_ isKindOfClass:[NSDictionary class]] &&
      [(NSDictionary*)object_ objectForKey:@"title"])
    return [(NSDictionary*)object_ objectForKey:@"title"];
  else
    return @"unknown title";
}


@end
