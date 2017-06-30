#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HLSliderCalculatorRoundingRule) {
    HLSliderCalculatorRoundingRuleNone = 0,
    HLSliderCalculatorRoundingRuleFloor = 1,
    HLSliderCalculatorRoundingRuleCeil = 2
};


@interface HLSliderCalculator : NSObject

+ (double)calculateExpValueWithSliderValue:(double)value minValue:(double)minValue maxValue:(double)maxValue;
+ (double)calculateExpValueWithSliderValue:(double)value minValue:(double)minValue maxValue:(double)maxValue roundingRule:(HLSliderCalculatorRoundingRule)roundingRule;
+ (double)calculateSliderLogValueWithValue:(double)value minValue:(double)minValue maxValue:(double)maxValue;
+ (double)roundValue:(double)value roundingRule:(HLSliderCalculatorRoundingRule)roundingRule;

@end
