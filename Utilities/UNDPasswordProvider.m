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
+ (NSString*)passwordForService:(NSString*)service account:(NSString*)account
{
  OSStatus res;
  UInt32 pwdLen;
  void *pwd;
  NSString* password = nil;

  const char* acnt;
  if( !account ) acnt = nil;
  else acnt = [account cStringUsingEncoding:NSUTF8StringEncoding];
  const char* serv = [service cStringUsingEncoding:NSUTF8StringEncoding];
  int acntLen = [account length];
  int servLen = [service length];
  
  // attempt to get the password without user interaction (dialog boxes)
  res = SecKeychainSetUserInteractionAllowed(NO);
  
  res = SecKeychainFindInternetPassword (NULL,servLen,serv,0,NULL,acntLen,acnt,
                                         0,NULL,0,kSecProtocolTypeHTTP,
                                         kSecAuthenticationTypeDefault,
                                         &pwdLen,&pwd,NULL);
  
  // if we don't find a default type password, look for a webform one
  if( res == errSecItemNotFound )
  {
    res = SecKeychainFindInternetPassword (NULL,servLen,serv,0,NULL,acntLen,acnt,
                                           0,NULL,0,kSecProtocolTypeHTTP,
                                           kSecAuthenticationTypeHTMLForm,
                                           &pwdLen,&pwd,NULL);
  }
  
  // if we fail to get the information because authorization failed or
  // interaction is required, try again with user interaction
  if( res == errSecAuthFailed || res == errSecInteractionRequired )
  {
    res = SecKeychainSetUserInteractionAllowed(YES);
    // make sure the keychain dialog is visible:
    // 1) order out the scene (i.e. stop showing Front Row)
    // 2) hide any windows (if we're in an external viewew)
    BRSentinel* sentinel = [BRSentinel sharedInstance];
    id<BRRendererProvider> provider = [sentinel rendererProvider];
    BRRenderer* renderer = [provider renderer];
    [renderer orderOut];
    for( NSWindow* window in [NSApp windows] ){
      [window orderOut:self];
    }
    res = SecKeychainFindInternetPassword (NULL,servLen,serv,0,NULL,acntLen,
                                           acnt,0,NULL,0,kSecProtocolTypeHTTP,
                                           kSecAuthenticationTypeDefault,
                                           &pwdLen,&pwd,NULL);
    // if the item isn't found as a, look for a form item too
    if( res == errSecItemNotFound )
    {
      res = SecKeychainFindInternetPassword (NULL,servLen,serv,0,NULL,acntLen,
                                             acnt,0,NULL,0,kSecProtocolTypeHTTP,
                                             kSecAuthenticationTypeHTMLForm,
                                             &pwdLen,&pwd,NULL);
    }

    if( [[NSApp windows] count] ){
      for( NSWindow* window in [NSApp windows] ) [window orderFrontRegardless];
    }else{
      [renderer orderIn];
    }
  }

  if( res == 0 && pwd != NULL && pwdLen > 0 )
  {
    password = [NSString stringWithCharacters:pwd length:pwdLen];
    password = [NSString stringWithCString:pwd 
                                  encoding:NSASCIIStringEncoding];
    SecKeychainItemFreeContent (NULL,pwd);
    password = [password substringToIndex:pwdLen];
  }
  
  return password;
}

@end
