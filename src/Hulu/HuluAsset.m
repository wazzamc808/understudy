//
//  Copyright 2008-2011 Kirk Kelsey.
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

#import "HuluAsset.h"
#import "HuluFeed.h"
#import "HuluFeedDiscoverer.h"
#import "HuluController.h"

#import <BRImage.h>
#import <RUIPreferences.h>

#import <CoreFoundation/CFXMLNode.h>

#include <regex.h>

@interface HuluAsset (Parsing)
- (void)parseDescriptionElementFromDom:(NSXMLElement*) dom;
- (void)parseTitleElementFromDom:(NSXMLElement*) dom;
- (void)setDateAddedFromString:(NSString*) text;
- (void)setDurationFromString:(NSString*) text;
- (void)setTitleAndEpisodeInfoFromString:(NSString*) text;
@end

@implementation HuluAsset

- (id)initWithXMLElement:(NSXMLElement*) dom
{
  imageManager_ = [BRImageManager sharedInstance];
  [super init];
  [self parseTitleElementFromDom:dom];
  [self parseDescriptionElementFromDom:dom];
  NSString* url;

  // URL's with # will break NSURL
  url=[[[dom elementsForName:@"link"] objectAtIndex:0] stringValue];
  url = [url stringByReplacingOccurrencesOfString:@"#in-playlist#"
                                       withString:@"?in-playlist="];
  url_ = [[NSURL URLWithString:url] retain];
  NSArray* tnArray = [dom elementsForName:@"media:thumbnail"];
  NSXMLElement* tnElement = [tnArray objectAtIndex:0];
  NSXMLNode* tnAttribute = [tnElement attributeForName:@"url"];
  NSURL* thumburl = [NSURL URLWithString:[tnAttribute stringValue]];
  thumbnailID_ = [[imageManager_ writeImageFromURL:thumburl] retain];

  NSXMLElement* credit = [[dom elementsForName:@"media:credit"] objectAtIndex:0];
  credit_ = [[credit stringValue] retain];

  NSXMLElement* pubDate = [[dom elementsForName:@"pubDate"] objectAtIndex:0];
  airdate_ = [NSDate dateWithNaturalLanguageString:[pubDate stringValue]];
  [airdate_ retain];

  // if the url isn't for /watch/ something, start an asynchronous load of the
  // url and try to find a feed for the (assumed) show on that page
  if( ![[url_ path] hasPrefix:@"/watch/"] )
    feedDiscoverer_ = [[HuluFeedDiscoverer alloc] initWithUrl:url_];

  return self;
}

- (void)dealloc
{
  [added_ release];
  [airdate_ release];
  [credit_ release];
  [description_ release];
  [feed_ release];
  [title_ release];
  [url_ release];
  [episodeInfo_ release];
  [feedDiscoverer_ release];
  [super dealloc];
}

- (void)parseTitleElementFromDom:(NSXMLElement*) dom
{
  NSXMLElement* titleline = [[dom elementsForName:@"title"] objectAtIndex:0];
  NSString* titlestring = [[titleline childAtIndex:0] description];
  titlestring = (NSString*) CFXMLCreateStringByUnescapingEntities(NULL,(CFStringRef)titlestring,NULL);
  NSArray* components = [titlestring componentsSeparatedByString:@": "];
  if( [components count] == 1)
  {
    title_ = [titlestring copy];
    series_ = [titlestring copy];
    episode_ = 0;
    season_ = 0;
  } else {
    title_ = [components lastObject];
    NSRange seriesRange = {0, [components count] -1};
    NSArray* seriesComponents = [components subarrayWithRange:seriesRange];
    series_ = [[seriesComponents componentsJoinedByString:@": "] copy];
    [self setTitleAndEpisodeInfoFromString:title_];
  }
  [titlestring release];
}

- (void)parseDescriptionElementFromDom:(NSXMLElement*)dom
{
  NSXMLElement* description = [[dom elementsForName:@"description"]
                               objectAtIndex:0];
  description_ = [description stringValue];
  [self setDateAddedFromString: description_];
  [self setDurationFromString: description_];
  int start = [description_ rangeOfString:@"<p>"].location;
  int end = [description_ rangeOfString:@"</p>"].location;
  if( start != NSNotFound && end != NSNotFound ){
    NSRange descRange = NSMakeRange(start+3, end-start-3);
    description_ = [description_ substringWithRange:descRange];
  }
  description_ = (NSString*) CFXMLCreateStringByUnescapingEntities(NULL,(CFStringRef)description_,NULL);
}

- (void)setDateAddedFromString:(NSString*)text
{
  regex_t SnumEnum;
  regcomp(&SnumEnum,"Added:[[:space:]]+([^<]+)",REG_EXTENDED);
  int nmatch = 2;
  regmatch_t pmatch[nmatch];
  const char* cText = [text cStringUsingEncoding:[NSString defaultCStringEncoding]];
  int res = regexec(&SnumEnum, cText, nmatch, pmatch, 0);
  if( res!=0 || pmatch[nmatch - 1].rm_so == -1 ) return;
  NSRange dateRange = {pmatch[1].rm_so, pmatch[1].rm_eo-pmatch[1].rm_so};
  NSString* dateString = [text substringWithRange:dateRange];
  added_ = [NSDate dateWithNaturalLanguageString:dateString];
  [added_ retain];
  regfree(&SnumEnum);
}

- (void)setDurationFromString:(NSString*)text
{
  int hour,min,sec;
  regex_t SnumEnum;
  regcomp(&SnumEnum,"Duration: (([[:digit:]]*):)?([[:digit:]]+):([[:digit:]]+)",REG_EXTENDED);
  int nmatch = 5;
  regmatch_t pmatch[nmatch];
  const char* cText = [text cStringUsingEncoding:[NSString defaultCStringEncoding]];
  int res = regexec(&SnumEnum, cText, nmatch, pmatch, 0);
  if( res != 0 || pmatch[nmatch - 1].rm_so == -1 ) return;
  if( pmatch[2].rm_so != -1 ){
    NSRange hourRange = {pmatch[1].rm_so, pmatch[1].rm_eo-pmatch[1].rm_so};
    hour = [[text substringWithRange:hourRange] intValue];
  } else hour = 0;
  NSRange minRange = {pmatch[3].rm_so, pmatch[3].rm_eo-pmatch[3].rm_so};
  min = [[text substringWithRange:minRange] intValue];
  NSRange secRange = {pmatch[4].rm_so, pmatch[4].rm_eo-pmatch[4].rm_so};
  sec = [[text substringWithRange:secRange] intValue];
  duration_ = ((hour * 60) + min) * 60 + sec;
  regfree(&SnumEnum);
}

-(void) setTitleAndEpisodeInfoFromString:(NSString*) text
{
  regex_t SnumEnum;
  regcomp(&SnumEnum,
          "\\(s([[:digit:]]+)+[[:space:]]*\\|[[:space:]]*e([[:digit:]]+)\\)",
          REG_EXTENDED);
  int nmatch = 3;
  regmatch_t pmatch[nmatch];
  const char* cText = [text cStringUsingEncoding:[NSString defaultCStringEncoding]];
  int res = regexec(&SnumEnum, cText, nmatch, pmatch, 0);
  if( res != 0 || pmatch[nmatch - 1].rm_so == -1 ) return;
  NSRange comboRange = {pmatch[0].rm_so, pmatch[0].rm_eo-pmatch[0].rm_so};
  NSRange seasonRange = {pmatch[1].rm_so, pmatch[1].rm_eo-pmatch[1].rm_so};
  NSRange episodeRange = {pmatch[2].rm_so, pmatch[2].rm_eo-pmatch[2].rm_so};
  episodeInfo_ = [[text substringWithRange:comboRange] retain];
  NSString* season = [text substringWithRange:seasonRange];
  NSString* episode = [text substringWithRange:episodeRange];
  season_ = [season intValue];
  episode_ = [episode intValue];
  title_ = [text substringToIndex: pmatch[0].rm_so];

  regfree(&SnumEnum);
}

- (NSURL*)url{ return url_; }
- (NSString*)episodeInfo{ return episodeInfo_; }


#pragma mark BRMediaAsset
- (NSString*)title{ return title_; }
- (NSString*)mediaSummary{ return description_; }
- (NSString*)mediaDescription{ return [self mediaSummary]; }
- (long)duration{ return duration_; }
- (NSString*)mediaURL{ return [url_ description]; }
- (NSString*)thumbnailArtID{ return thumbnailID_; }
- (NSDate*)datePublished{ return airdate_; }
- (NSString*)datePublishedString{ return [airdate_ description]; }
- (BRImage*)coverArt{ return [self thumbnailArt]; }
- (BRImage*)thumbnailArt
{
  return [imageManager_ imageNamed:thumbnailID_];
}
- (BRMediaType*)mediaType{ return [BRMediaType TVShow]; }
- (BOOL)hasVideoContent{ return YES; }
- (BOOL)isDisabled{ return NO; }
- (NSString*)seriesName{ return series_; }
- (NSString*)seriesNameForSorting{ return series_; }
- (NSString*)broadcaster{ return credit_; }
- (NSString*)episodeNumber
{
  return [NSString stringWithFormat:@"%d", episode_, nil];
}
- (unsigned)season{ return season_; }
- (unsigned)episode{ return episode_; }

#pragma mark BRMediaAsset (unused)
- (NSString*)assetID{ return [url_ description]; }
- (BRImage*)coverArtNoDefault{ return [self coverArt]; }

- (BRLayer<BRMenuItemLayer>*)menuItem
{
  if (!menuItem_) {
    BRTextMenuItemLayer* menuItem = [[BRTextMenuItemLayer menuItem] retain];
    [menuItem setTitle:[self seriesName]];
    [menuItem setRightJustifiedText:[self episodeInfo]];
    menuItem_ = menuItem;
  }
  return menuItem_;
}

// If the menu is titled by the series name of this asset, then the menu items
// should use something else for their titles (like the episode title).
- (BRLayer<BRMenuItemLayer>*)menuItemForMenu:(NSString*)menu
{
  if ([menu compare:[self seriesName]] != NSOrderedSame)
    return [self menuItem];

  if (!specificMenuItem_) {
    specificMenuItem_ = [BRTextMenuItemLayer menuItem];
    [specificMenuItem_ setTitle:title_];
    [specificMenuItem_ setRightJustifiedText:[self episodeInfo]];
    [specificMenuItem_ retain];
  }
  return specificMenuItem_;
}

- (BRController*)controller
{
  // if there is a feed discover in progress, see what it has
  if ( feedDiscoverer_ ) {
    if ([feedDiscoverer_ error])
      NSLog(@"discovery error: %@",[feedDiscoverer_ error]);

    [url_ autorelease];
    url_ = [[feedDiscoverer_ finalURL] retain];

    if( [feedDiscoverer_ feed] ){
      if ( [[[feedDiscoverer_ feed] path] hasPrefix:@"/feed/"] ){
        feed_ = [[HuluFeed alloc] initWithTitle:title_
                                         forUrl:[feedDiscoverer_ feed]];
      }
      [feedDiscoverer_ release];
      feedDiscoverer_ = nil;
    }
  }

  // if the URL is for watching a video, provide a video controller
  if ( [[url_ path] hasPrefix:@"/watch/"] )
    return [[[HuluController alloc] initWithAsset:self] autorelease];

  // if we're wrapping a feed, return it's controller
  if ( feed_ ) return [feed_ controller];

  // in all other cases return nil
  return nil;
}

- (float)aspectRatio
{
  // load the global preferences
  RUIPreferences* FRprefs = [RUIPreferences sharedFrontRowPreferences];
  NSDictionary* prefDict = (NSDictionary*) [FRprefs objectForKey:@"understudy"];
  // look for Hulu -> Aspect Ratio -> <series name>
  NSDictionary* hulu = [prefDict objectForKey:@"Hulu"];
  NSDictionary* ratios = [hulu objectForKey:@"AspectRatios"];
  NSNumber* ratio = [ratios objectForKey:[self seriesName]];
  if( ratio )
    return [ratio floatValue];
  else
    return 16.0/9.0;
}

- (BRControl*)preview
{
  if( feed_ ) return [feed_ preview];
  else return [super preview];
}

@end
