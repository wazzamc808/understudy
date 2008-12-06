//
//  UnderstudyAppliance.m
//  Understudy FR Appliance
//
//  Created by Kirk Kelsey.
//  Copyright 2008. All rights reserved.

#import "UnderstudyAppliance.h"

@implementation UnderstudyAppliance

- (BRController*)applianceController
{
  return [MainMenuController sharedInstance];
}

+ (NSString *)className 
{
  return [NSString stringWithString:@"RUIDVDAppliance"];
}

- (NSString*)version
{
  return kFrontRowCurrentApplianceProtocolVersion;
}

@end
