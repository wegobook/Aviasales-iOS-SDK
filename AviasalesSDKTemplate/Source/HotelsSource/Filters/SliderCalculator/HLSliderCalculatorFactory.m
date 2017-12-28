#import "HLSliderCalculatorFactory.h"
#import "HLResultVariant.h"
#import "HLFilter.h"
#import "NSArray+Functional.h"

static NSInteger const defaultMaxPivotsCount = 10;

@implementation HLSliderCalculatorFactory

+ (HLPriceSliderCalculator *)priceSliderCalculatorWithFilter:(HLFilter *)filter
{
    return [self priceSliderCalculatorWithFilter:filter maxPivotCount:defaultMaxPivotsCount];
}

+ (HLPriceSliderCalculator *)priceSliderCalculatorWithFilter:(HLFilter *)filter maxPivotCount:(NSInteger)maxPivotCount
{
    NSArray *roomPrices = [self pricesFromFilter:filter];

    if ([roomPrices arrayWithoutDuplicates].count < 2) {
        return nil;
    }

    return [[HLPriceSliderCalculator alloc] initWithPrices:roomPrices maxPivotCount:maxPivotCount];
}

+ (NSArray<NSNumber *>*)pricesFromFilter:(HLFilter *)filter
{
    return [filter.searchResult.variants flattenMap:^NSArray *(HLResultVariant *variant) {
        return [variant.rooms map:^NSNumber *(HDKRoom *room) {
            return @(room.price);
        }];
    }];
}

@end
