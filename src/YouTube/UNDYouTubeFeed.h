//
//  Copyright 2009-2011 Kirk Kelsey.
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

#import <Cocoa/Cocoa.h>

#import "Base/UNDBaseCollection.h"

@interface UNDYouTubeFeed : UNDBaseCollection
{
  NSArray* array_;
  NSURL*   url_;
}

- (id)initWithTitle:(NSString*)title forUrl:(NSURL*)url;

// attempts to convert a URL into one we can parse
+ (NSString*)canonicalFormOfURL:(NSString*)url;
@end
