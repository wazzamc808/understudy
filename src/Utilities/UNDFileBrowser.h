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

#import <Foundation/Foundation.h>

#import "UNDMenuController.h"

@class UNDFileCollection;

@protocol UNDFileBrowserDelegate
-(void)fileSelected:(NSString*)path;
@end


@interface UNDFileBrowser : UNDMenuController
{
  UNDFileCollection* fileCollection_;
  NSObject<UNDFileBrowserDelegate>* fileBrowserDelegate_;
}

-(id)initWithPath:(NSString*)path;
-(void)setDelegate:(NSObject<UNDFileBrowserDelegate>*)delegate;

@end
