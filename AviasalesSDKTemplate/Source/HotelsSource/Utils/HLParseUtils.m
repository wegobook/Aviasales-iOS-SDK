#import "HLParseUtils.h"
#import <HotellookSDK/HotellookSDK.h>

NSString * const kNegationPrefix = @"!";

@implementation HLParseUtils

#pragma mark - Options

+ (NSArray <NSDictionary *> *)optionsWithValuesFromOptionsStrings:(NSArray <NSString *> *)optionsStrings
{
    NSMutableArray *optionsAndValues = [NSMutableArray new];
    for (NSString *option in optionsStrings) {
        BOOL shouldAddOption = YES;
        if ([option hasPrefix:kNegationPrefix]) {
            NSString *optionStringWithoutPrefix = [option substringFromIndex:[kNegationPrefix length]];
            shouldAddOption = ![optionsStrings containsObject:optionStringWithoutPrefix];
        } else {
            shouldAddOption = ![optionsStrings containsObject:[kNegationPrefix stringByAppendingString:option]];
        }
        
        if (shouldAddOption) {
            [optionsAndValues addObject:[self optionWithValueFromOptionString:option]];
        }
    }
    
    return optionsAndValues.copy;
}

+ (NSDictionary *)optionWithValueFromOptionString:(NSString *)optionString
{
    NSDictionary *dictionaryToReturn;

    if ([optionString hasPrefix:kNegationPrefix]) {
        NSString *optionStringWithoutPrefix = [optionString substringFromIndex:[kNegationPrefix length]];
         dictionaryToReturn = @{optionStringWithoutPrefix : @NO};
    } else {
        dictionaryToReturn = @{optionString : @YES};
    }

    return dictionaryToReturn;
}

@end
