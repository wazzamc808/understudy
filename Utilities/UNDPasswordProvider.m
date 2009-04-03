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


#import "UNDPasswordProvider.h"
#import "UNDPreferenceManager.h"

#import <BRSentinel.h>
#import <BRRenderer.h>

@protocol BRRendererProvider
- (BRRenderer*)renderer;
@end

@implementation UNDPasswordProvider

// service will be a domain such as www.hulu.com
+ (NSString*)passwordForService:(NSString*)service
{
  OSStatus res;
  UInt32 pwdLen;
  void *pwd;
  
  // get the account name for this service
  NSString* account = [UNDPreferenceManager accountForService:service];
  [[account retain] autorelease];
  if( !account ) return nil;

  const char* acnt = [account cStringUsingEncoding:NSUTF8StringEncoding];
  const char* serv = [service cStringUsingEncoding:NSUTF8StringEncoding];
  int acntLen = [account length];
  int servLen = [service length];
  
  // attempt to get the password without user interaction (dialog boxes)
  res = SecKeychainSetUserInteractionAllowed(NO);
  
  res = SecKeychainFindInternetPassword (NULL,servLen,serv,0,NULL,acntLen,acnt,
                                         0,NULL,0,kSecProtocolTypeHTTP,
                                         kSecAuthenticationTypeDefault,
                                         &pwdLen,&pwd,NULL);
  
  // if we fail to get the information, try again but allow user interaction
  if( res ){
    res = SecKeychainSetUserInteractionAllowed(YES);
    // order out the scene (i.e. stop showing Front Row)
    BRSentinel* sentinel = [BRSentinel sharedInstance];
    id<BRRendererProvider> provider = [sentinel rendererProvider];
    BRRenderer* renderer = [provider renderer];
    [renderer orderOut];
 
    res = SecKeychainFindInternetPassword (NULL,servLen,serv,0,NULL,acntLen,acnt,
                                           0,NULL,0,kSecProtocolTypeHTTP,
                                           kSecAuthenticationTypeDefault,
                                           &pwdLen,&pwd,NULL);
    [renderer orderIn];
  }
  
  if( res ) return nil;
  else return [NSString stringWithCString:pwd];
}

@end
