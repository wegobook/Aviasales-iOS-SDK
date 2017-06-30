//
//  JRSDKAirport+LocalizedName.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
///

#import "JRSDKAirport+LocalizedName.h"

@implementation JRSDKAirport (LocalizedName)

- (NSString *)localizedName {
    if (self.isCity) {
        return NSLS(@"JR_ANY_AIRPORT");
    } else {
        return self.airportName;
    }
}

@end
