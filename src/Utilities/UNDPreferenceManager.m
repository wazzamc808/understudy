//
//  Copyright 2009-2011 Kirk Kelsey.
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

#import "Utilities/UNDPreferenceManager.h"

#import <BRHeaders/BRMenuSavedState-Private.h>
#import <BRHeaders/RUIPreferences.h>

#import <PubSub/PubSub.h>

#import "Base/UNDExternalAppAssetProvider.h"


#define DEFAULTS_DOMAIN @"com.apple.frontrow.appliance.understudy"

@interface BRMenuSavedState (PrivateExpose)
- (NSMutableDictionary*) cachedMenuState;
@end

@implementation UNDPreferenceManager
@synthesize huluFSAlerted = huluFSAlerted_;
@synthesize alertsDisabled = alertsDisabled_;
@synthesize debugMode = debugMode_;

static NSString* kPrefsVersion   = @"prefs-version";
static int       kCurrentVersion = 1;

- (id)init
{
  [super init];
  subscribers_ = [[NSMutableSet alloc] init];
  self.huluFSAlerted = false;
  [self load];
  return self;
}

- (void)dealloc
{
  [assets_ release];
  [subscribers_ release];
  [super dealloc];
}

static UNDPreferenceManager *sharedInstance_;
+ (UNDPreferenceManager*)sharedInstance
{
  if(!sharedInstance_)
    sharedInstance_ = [[UNDPreferenceManager alloc] init];
  return sharedInstance_;
}

- (NSMutableArray*)assetDescriptions
{
  return assets_;
}

// preferred display for front row (if any) or main screen
+ (NSScreen*)screen
{
  RUIPreferences* prefs = [RUIPreferences sharedFrontRowPreferences];
  int prefdisplay  = [prefs integerForKey:@"FrontRowUsePreferredDisplayID"];
  if( prefdisplay ){
    for( NSScreen* screen in [NSScreen screens] ){
      NSDictionary* desc = [[[screen deviceDescription] retain] autorelease];
      if( [desc objectForKey:NSDeviceIsScreen] ){
        NSNumber* screenNum = [desc objectForKey:@"NSScreenNumber"];
        if( [screenNum intValue] == prefdisplay ) return screen;
      }
    }
  }
  return [NSScreen mainScreen];
}

+ (NSString*)accountForService:(NSString*)service
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary* prefDict = [defaults persistentDomainForName:DEFAULTS_DOMAIN];
  NSDictionary* accounts = [prefDict objectForKey:@"accounts"];
  return [accounts objectForKey:service];
}

+ (BOOL)alertsAreDisabled
{
  return  [[UNDPreferenceManager sharedInstance] alertsDisabled];
}

- (void)clearMenuState
{
  [menuState_ release];
  menuState_ = nil;
  [self save];
}

- (void)saveMenuState
{
  [menuState_ release];
  BRMenuSavedState* menuSavedState = [BRMenuSavedState sharedInstance];
  menuState_ = [[menuSavedState cachedMenuState] retain];
  [self save];
}

- (NSDictionary*)savedMenuState
{
  return menuState_;
}

// Older versions assumed everything was a feed with a title and figured out
// the provides on the fly.
- (NSMutableArray*)newAssetsFromFeeds:(NSArray*)feeds andTitles:(NSArray*)titles
{
  NSMutableArray* assets = [[NSMutableArray alloc] init];

  unsigned count = [feeds count];
  if (count > [titles count]) count = [titles count];

  PSClient* psClient = [PSClient applicationClient];
  for (unsigned i = 0; i < count; ++i) {
    NSURL* url = [NSURL URLWithString:[feeds objectAtIndex:i]];

    [psClient addFeedWithURL:url];

    NSString* host = [[url host] lowercaseString];
    NSString *provider = nil, *title = [titles objectAtIndex:i];

    if ([host rangeOfString:@"hulu"].location != NSNotFound)
      provider = @"hulu";
    else if( [host rangeOfString:@"netflix"].location != NSNotFound )
      provider = @"netflix";
    else if( [host rangeOfString:@"youtube"].location != NSNotFound )
      provider = @"youtube";
    else if( [host rangeOfString:@"bbc.co.uk"].location != NSNotFound )
      provider = @"bbciplayer";

    if (provider) {
      NSDictionary* asset =[NSDictionary dictionaryWithObjectsAndKeys:title,
                                          @"title", [url absoluteString],
                                          @"URL", provider, @"provider", nil];
      [assets addObject:asset];
    }
  }
  return assets;
}

#define HDAPP @"/Applications/Hulu Desktop.app"
- (void)addDefaultsToAssets:(NSMutableArray*)assets
{
  if ([[NSFileManager defaultManager] fileExistsAtPath:HDAPP]) {
    NSDictionary* asset =
      [NSDictionary dictionaryWithObjectsAndKeys:@"Hulu Desktop", @"appname",
                    @"externalapp", @"provider", nil];
    [assets addObject:asset];
  }
}

- (void)load
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary* prefDict;

  prefDict = [defaults persistentDomainForName:DEFAULTS_DOMAIN];

  assets_ = [[prefDict objectForKey:@"assets"] mutableCopy];

  // If there are no assets, look for feeds/titles from older versions.
  if (!assets_) {
    NSArray* feeds = [prefDict objectForKey:@"feeds"];
    NSArray* titles = [prefDict objectForKey:@"titles"];

    if (feeds && titles)
      assets_ = [self newAssetsFromFeeds:feeds andTitles:titles];
  }

  if (!assets_) assets_ = [[NSMutableArray alloc] init];

  if (![prefDict objectForKey:kPrefsVersion])
    [self addDefaultsToAssets:assets_];

  // A nil menu state indicates that nothing should be restored.
  menuState_ = [[prefDict objectForKey:@"menustate"] retain];

  alertsDisabled_ = ([prefDict objectForKey:@"disableAlerts"] != nil);
  debugMode_ = ([prefDict objectForKey:@"debugMode"] != nil);
}

- (void)save
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary* prefDict = [defaults persistentDomainForName:DEFAULTS_DOMAIN];
  NSMutableDictionary* prefs;
  if (prefDict)
    prefs = [[prefDict mutableCopy] autorelease];
  else
    prefs = [NSMutableDictionary dictionary];

  [prefs setObject:[NSNumber numberWithInt:kCurrentVersion]
            forKey:kPrefsVersion];
  [prefs setObject:assets_ forKey:@"assets"];
  if (menuState_) [prefs setObject:menuState_ forKey:@"menustate"];
  else [prefs removeObjectForKey:@"menustate"];
  [defaults setPersistentDomain:prefs forName:DEFAULTS_DOMAIN];
}

/// The value of provider should be the [id<UNDAssetProvider> providerId].
- (NSDictionary*)prefsForProvider:(NSString*)provider
{
  return [[[NSUserDefaults standardUserDefaults]
            persistentDomainForName:DEFAULTS_DOMAIN]
           objectForKey:provider];
}

@end
