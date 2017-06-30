#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface HLParseUtils : NSObject

#pragma mark - Options

+ (NSArray <NSDictionary *> *)optionsWithValuesFromOptionsStrings:(NSArray <NSString *> *)optionsStrings;
+ (NSDictionary *)optionWithValueFromOptionString:(NSString *)optionString;


@end
