//
//  Copyright 2009 Kirk Kelsey.
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

#import <BackRow/BRSingleton.h>

@protocol UNDPreferenceSubscriber
- (void)preferencesDidChange;
@end

@interface UNDPreferenceManager : BRSingleton
{
 @private
  // feed urls in NSString format
  NSMutableArray* feeds_;
  // feed titles in NSString format
  NSMutableArray* titles_;

  BOOL huluFSAlerted_;
}

@property(nonatomic) BOOL huluFSAlerted;


- (long) feedCount;
- (NSString*) titleAtIndex:(long)index;
- (NSURL*) URLAtIndex:(long)index;

- (void)addFeed:(NSString*)feedURL withTitle:(NSString*)title;
- (void)moveFeedFromIndex:(long)from toIndex:(long)to;
- (void)removeFeedAtIndex:(long)index;
- (void)renameFeedAtIndex:(long)index withTitle:(NSString*)title;
- (void)save;

@end
