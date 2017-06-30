//
//  JRPriceUtils.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRPriceUtils.h"

@implementation JRPriceUtils

+ (NSString *)formattedPriceInUserCurrency:(JRSDKPrice *)price {
    NSNumber *const minPriceValue = [price priceInUserCurrency];
    return [AviasalesNumberUtil formatPrice:minPriceValue];
}

@end
