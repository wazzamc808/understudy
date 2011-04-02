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

#import "DailyShowAsset.h"
#import "DailyShowFullEpisodesFeed.h"
#import "TFHpple.h"

#import <BRControllerStack.h>
#import <BRListControl.h>
#import <BRMediaMenuController.h>
#import <BRTextMenuItemLayer.h>

@implementation DailyShowFullEpisodesFeed

- (id)initWithTitle:(NSString*)title forUrl:(NSURL*)url
{
  [super initWithTitle:title];
  url_ = [url retain];
  return self;
}

- (void)dealloc
{
  [url_ release];
  [controller_ release];
  [super dealloc];
}

- (NSArray*)currentAssets
{
  NSMutableArray* assets = [NSMutableArray array];
  NSError* err;

  NSData *seasonData = [[NSData alloc] initWithContentsOfURL:url_
                                                     options:0
                                                       error:&err];
  
  if( !seasonData )
  {
    NSLog( @"DailyShowFullEpisodesFeed:currentAssets Error: ", [err localizedDescription] );
  }
  
  // Create parser
  TFHpple *seasonParser = [[TFHpple alloc] initWithHTMLData:seasonData];
  
  NSArray *seasons = [seasonParser search:@"//div[@class=\"seasons\"]//a"];
  for( int i = 0; i < [seasons count]; i++ )
  //for( i = 0; i < 1; i++ )
  {
    
    // Access the first cell
    TFHppleElement *season = [seasons objectAtIndex:i];
    
    // Get the text within the cell tag
    NSString *idContent = [season objectForKey:@"id"];

    NSURL *seasonUrl = [NSURL URLWithString:idContent];
    NSData *seasonData = [[NSData alloc] initWithContentsOfURL:seasonUrl
                                                       options:0
                                                         error:&err];
    if( !seasonData )
    {
      NSLog( @"DailyShowFullEpisodesFeed:currentAssets seasonData error: %@", [err localizedDescription] );
    }
    
    TFHpple *episodeParser = [[TFHpple alloc] initWithHTMLData:seasonData];
    
    NSArray *titles = [episodeParser search:@"//div[@class=\"moreEpisodesTitle\"]/span/a"];
    NSArray *descriptions = [episodeParser search:@"//div[@class=\"moreEpisodesDescription\"]/span"];
    NSArray *urls = [episodeParser search:@"//div[@class=\"moreEpisodesImage\"]/a"];
    NSArray *thumbs = [episodeParser search:@"//div[@class=\"moreEpisodesImage\"]/a/img"];

    for( int j = 0; j < [titles count]; j++ )
    {
      TFHppleElement *titleElement = [titles objectAtIndex:j];
      NSString *title = [titleElement content];
      
      TFHppleElement *descElement = [descriptions objectAtIndex:j];
      NSString *desc = [descElement content];
      
      TFHppleElement *urlElement = [urls objectAtIndex:j];
      NSString *url = [urlElement objectForKey:@"href"];

      NSURL *episodeURL = [NSURL URLWithString:url];
      NSData *episodeData = [[NSData alloc] initWithContentsOfURL:episodeURL
                                                          options:0
                                                            error:&err];
      if( !episodeData )
      {
        NSLog( @"DailyShowFullEpisodesFeed:currentAssets Unable to load episode data: %@", [err localizedDescription] );
      }
      
      TFHpple *flashParser = [[TFHpple alloc] initWithHTMLData:episodeData];
      TFHppleElement *flashURLElement = [flashParser at:@"//object[@id=\"full_ep_video_player\"]"];
      NSString *flashURL = [flashURLElement objectForKey:@"resource"];
      [flashParser release];
      [episodeData release];
      
      TFHppleElement *thumbElement = [thumbs objectAtIndex:j];
      NSString *thumb = [thumbElement objectForKey:@"src"];

      DailyShowAsset *asset = [[DailyShowAsset alloc] initWithTitle:title 
                                                        description:desc
                                                             forUrl:flashURL
                                                           forImage:thumb];
      [assets addObject:asset];
    }

    [episodeParser release];
    [seasonData release];
  }

  [seasonParser release];
  [seasonData release];

  return assets;
}

- (NSString*)title{ return title_; }

- (BRLayer<BRMenuItemLayer>*)menuItem
{
  BRTextMenuItemLayer*item = [BRTextMenuItemLayer folderMenuItem];
  [item setTitle:[self title]];
  return item;
}

- (BRController*)controller
{
  if (!controller_)
    controller_ = [[UNDMenuController alloc] initWithDelegate:self];
  return controller_;
}

- (void)assetUpdated:(DailyShowAsset*)asset
{
  [[controller_ list] reload];
}

@end
