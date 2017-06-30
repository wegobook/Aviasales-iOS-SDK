#import "HLSliderCalculator.h"

@implementation HLSliderCalculator

+ (double)calculateExpValueWithSliderValue:(double)value minValue:(double)minValue maxValue:(double)maxValue
{
    CGFloat calcValue = exp(powf(value, 3) * log(2)) - 1;
    calcValue = minValue + (maxValue - minValue) * calcValue;

    return calcValue;
}

+ (double)calculateExpValueWithSliderValue:(double)value minValue:(double)minValue maxValue:(double)maxValue roundingRule:(HLSliderCalculatorRoundingRule)roundingRule
{
    double calcValue = [self calculateExpValueWithSliderValue:value minValue:minValue maxValue:maxValue];
    
    if (roundingRule != HLSliderCalculatorRoundingRuleNone && calcValue > 100.0) {
        double roundedValue = [self roundValue:calcValue roundingRule:roundingRule];
        calcValue = MIN(MAX(roundedValue, minValue), maxValue);
    }
    
    return calcValue;
}

+ (double)roundValue:(double)value roundingRule:(HLSliderCalculatorRoundingRule)roundingRule
{
    NSInteger multiplier = 1;
    for (; value > 100.0; multiplier *= 10) {
        value /= 10;
    }
    switch (roundingRule) {
        case HLSliderCalculatorRoundingRuleCeil:
            value = ceilf(value);
            break;
            
        case HLSliderCalculatorRoundingRuleFloor:
            value = floorf(value);
            break;
            
        default:
            break;
    }
    value *= multiplier;
    
    return value;
}


+ (double)calculateSliderLogValueWithValue:(double)value minValue:(double)minValue maxValue:(double)maxValue
{
	double normValue = (value - minValue) / (maxValue - minValue);
	
	double calcValue = (log(normValue + 1)) / log(2);
	calcValue = powf(calcValue, 1.0/3);
    
    return calcValue;
}

@end
