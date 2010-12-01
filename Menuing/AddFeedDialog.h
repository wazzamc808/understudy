//                                                                -*- objc -*-
//  Copyright 2008-2010 Kirk Kelsey.
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

#import <BROptionDialog.h>

#import "HuluAddDialog.h"
#import "NetflixAddDialog.h"
#import "UNDYouTubeAddDialog.h"
#import "DailyShowAddDialog.h"

@interface AddFeedDialog : BROptionDialog {
@private
  HuluAddDialog* hulu_;
  NetflixAddDialog* netflix_;
  UNDYouTubeAddDialog* youtube_;
  DailyShowAddDialog* dailyshow_;
}

@end
