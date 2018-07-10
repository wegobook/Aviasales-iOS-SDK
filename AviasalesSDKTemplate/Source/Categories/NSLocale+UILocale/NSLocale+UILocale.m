//
//  NSLocale+UILocale.m
//  AviasalesSDKTemplate
//
//  Created by Dim on 28.06.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

#import "NSLocale+UILocale.h"

@implementation NSLocale (UILocale)

+ (NSLocale *)applicationUILocale {
    return [NSLocale localeWithLocaleIdentifier:AVIASALES__(@"LANGUAGE", [NSLocale currentLocale].localeIdentifier)];
}

@end
