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

#import "DailyShowFullEpisodesFeed.h"
#import <TFHpple.h>
#import <BRControllerStack.h>
#import <BRListControl.h>
#import <BRTextMenuItemLayer.h>

@implementation DailyShowFullEpisodesFeed

- (id)initWithTitle:(NSString*)title forUrl:(NSURL*)url
{
  [super init];
  title_ = [title copy];
  url_ = [url retain];
//  NSLog ( @"DailyShowFullEpisodesFeed initialized with title: %@, url: %@", 
//         title_, [url_ absoluteString] );
  return self;
}

- (void)dealloc
{
  [title_ release];
  [url_ release];
  [super dealloc];
}

- (NSArray*)currentAssets
{
//  NSLog( @"DailyShowFullEpisodesFeed: currentAssets url: %@", [url_ absoluteString] );
  NSMutableArray* assets = [NSMutableArray array];
  NSError* err;
  //NSString* dataStr = [NSString stringWithContentsOfURL:url_ encoding:0 error:nil];
  //NSLog( @"dataStr: %@", dataStr );
  
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
    
//    NSLog( @"DailyShowFullEpisodesFeed:currentAssets Content(%d): %@", i, [season content] );
//    NSLog( @"DailyShowFullEpisodesFeed:currentAssets id(%d): %@", i, idContent );
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
    
//    NSLog( @"DailyShowFullEpisodesFeed:currentAssets titles: %d, descriptions: %d, urls:%d, thumbs:%d", 
//          [titles count], [descriptions count], [urls count], [thumbs count] );
    
//    if( !([titles count] ==
//          [descriptions count] ==
//          [urls count] ==
//          [thumbs count]) )
//    {
//      NSLog( @"Error: episode element counts do not line up." );
//      return nil;
//    }
    
    for( int j = 0; j < [titles count]; j++ )
    {
      TFHppleElement *titleElement = [titles objectAtIndex:j];
      NSString *title = [titleElement content];
      
      TFHppleElement *descElement = [descriptions objectAtIndex:j];
      NSString *desc = [descElement content];
      
      TFHppleElement *urlElement = [urls objectAtIndex:j];
      NSString *url = [urlElement objectForKey:@"href"];
      
//      NSLog( @"Episode URL: %@", url );
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
      
//      NSLog( @DailyShowFullEpisodesFeed:currentAssets "%d %@", j, title );
//      NSLog( @DailyShowFullEpisodesFeed:currentAssets "%d %@", j, desc );
//      NSLog( @DailyShowFullEpisodesFeed:currentAssets "%d %@", j, flashURL );
//      NSLog( @DailyShowFullEpisodesFeed:currentAssets "%d %@", j, thumb );
      
      DailyShowAsset *asset = [[DailyShowAsset alloc] initWithTitle:title 
                                                        description:desc
                                                             forUrl:flashURL
                                                           forImage:thumb];
      [assets addObject:asset];
      //[asset setDelegate:self];
    }
    
    [episodeParser release];
    [seasonData release];
  }
  
  [seasonParser release];
  [seasonData release];
  
  assets_ = assets;
  NSLog( @"DailyShowFullEpisodesFeed:currentAssets: %d", [assets count] );
  
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
    controller_ = [[FeedMenuController alloc] initWithDelegate:self];
  return controller_;
}

- (void)assetUpdated:(DailyShowAsset*)asset
{
  [[controller_ list] reload];
}

@end
