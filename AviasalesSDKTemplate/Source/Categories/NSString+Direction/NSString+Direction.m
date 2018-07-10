//
//  NSString+Direction.m
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 24/10/2016.
//  Copyright © 2016 aviasales. All rights reserved.
//

#import "NSString+Direction.h"

@implementation NSString (Direction)

- (NSString *)rtlStringIfNeeded {
    if (isRTLDirectionByLocale()) {
        return [self forcedRTLString];
    } else {
        return [self forcedLTRString];
    }
}

- (NSString *)forcedLTRString {
    return [@"\u200e" stringByAppendingString:self];
}

- (NSString *)forcedRTLString {
    return [@"\u200f" stringByAppendingString:self];
}

- (NSString *)formatAccordingToTextDirection {
    if (!isRTLDirectionByLocale()) {
        return self;
    }
    
    NSMutableString *result = [self mutableCopy];
    
    NSMutableArray *startsOfArguments = [NSMutableArray array];
    
    NSRange searchRange = NSMakeRange(0, self.length);
    while (true) {
        NSRange range = [self rangeOfString:@"%[^%]+" options:NSRegularExpressionSearch range:searchRange];
        
        if (range.location == NSNotFound) {
            break;
        }
        
        [startsOfArguments addObject:@(range.location)];
        
        NSInteger startPosition = range.location + range.length - 1;
        searchRange = NSMakeRange(startPosition, self.length - startPosition);
    }
    
    NSInteger newIndex = 1;
    for (NSInteger i = startsOfArguments.count - 1; i >= 0; i--) {
        NSInteger index = [startsOfArguments[i] integerValue];
        
        [result insertString:[NSString stringWithFormat:@"%ld$", (long)newIndex] atIndex:index + 1];
        
        newIndex++;
    }
    
    return [result copy];
}

@end

