//  Copyright 2011 Jason Brown.
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
#import <BRMenuListItemProvider-Protocol.h>
#import <BRCenteredMenuController.h>

@class UNDMutableCollection;

@interface DailyShowAddDialog : BRCenteredMenuController
<BRMenuListItemProvider>
{
  NSMutableArray* titles_;
  NSMutableArray* feeds_;
  /// Weak reference to the collection to be modified.
  UNDMutableCollection* collection_;
}

@end
