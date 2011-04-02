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

#import "UNDFileCollection.h"

#import "UNDFileAsset.h"

@implementation UNDFileCollection

-(id)initWithPath:(NSString*)path
{
  [super initWithTitle:path];
  path_ = [path copy];
  NSMutableArray* assets = [NSMutableArray array];
  NSFileManager* manager = [[NSFileManager alloc] init];
  NSDirectoryEnumerator* enumerator
    = [manager enumeratorAtPath:path_];
  for (NSString* file in enumerator) {
    [enumerator skipDescendents];
    if ([[file pathExtension] isEqualToString:@"app"]) {
      NSString* filePath = [path stringByAppendingPathComponent:file];
      [assets addObject:[[UNDFileAsset alloc] initWithPath:filePath]];
    }
  }
  assets_ = [assets retain];
  return self;
}

-(void)dealloc
{
  [path_ release];
  [super dealloc];
}

- (NSArray*)currentAssets
{
  return assets_;
}


@end