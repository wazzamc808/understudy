//                                                                -*- objc -*-
//  Copyright 2010-2011 Kirk Kelsey.
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

#import "BaseUnderstudyAsset.h"
#import "UnderstudyAsset.h"
#import "UNDMenuController.h"
#import "UNDBaseCollection.h"

@interface UNDMutableCollection : UNDBaseCollection<UNDMutableMenuDelegate>
{
  NSMutableArray* contents_;
  NSMutableArray* assets_;
}

- (id)initWithTitle:(NSString*)title forContents:(NSMutableArray*)contents;

@end

@protocol UNDCollectionMutator
/// Implementing classes should keep a weak reference to the collection.
- (void)setCollection:(UNDMutableCollection*)collection;
@end
