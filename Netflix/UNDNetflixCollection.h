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
#import "BaseUnderstudyAsset.h"
#import "FeedMenuController.h"

// Represents a collection of Netflix videos found by loading the web page
// for some content (typically a season of a television show).
@interface UNDNetflixCollection : BaseUnderstudyAsset <FeedDelegate> {
 @private 
  NSURL* url_;
  NSString* title_;
  FeedMenuController* controller_;
  BRTextMenuItemLayer* menuItem_;
  NSArray* assets_;
}

- (id)initWithTitle:(NSString*)title forUrl:(NSURL*)url;

@end
