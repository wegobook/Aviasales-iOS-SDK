#import <HotellookSDK/HotellookSDK.h>

#import "HLFilter.h"
#import "HLResultVariant.h"
#import "HLVariantsSorter.h"
#import "HLDistanceCalculator.h"
#import "HLSliderCalculatorFactory.h"
#import "NSDictionary+Parsing.h"
#import "NSArray+Functional.h"

#define UNKNOWN_MAX_PRICE (-1)

@interface HLFilter ()

@property (nonatomic, strong, readwrite) NSArray <HLResultVariant *> *filteredVariants;
@property (nonatomic, strong, readwrite) NSArray<HDKRoom *> *filteredRoomsWithoutPriceFilter;

@end

@implementation HLFilter

- (instancetype)init
{
	self = [super init];
	if (self) {
        [self dropCommonValues];

        self.minPrice = 0;
        self.maxPrice = DBL_MAX;
        self.minDistance = MAXFLOAT;
        self.maxDistance = .0f;
        self.currentMaxDistance = .0f;
        self.minRating = 0;
        self.maxRating = 100;
        self.filterQueue = [NSOperationQueue new];
        self.filterQueue.maxConcurrentOperationCount = 1;
	}
    
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    HLFilter *copy = [[self class] new];
    
    if (copy) {
        copy.amenities = [self.amenities copy];
        
        copy.keyString = self.keyString;
        
        copy.options = [self.options copy];
        
        copy.minPrice = self.minPrice;
        copy.maxPrice = self.maxPrice;
        copy.currentMinPrice = self.currentMinPrice;
        copy.currentMaxPrice = self.currentMaxPrice;

        copy.priceSliderCalculator = self.priceSliderCalculator;
        copy.graphSliderMinValue = self.graphSliderMinValue;
        copy.graphSliderMaxValue = self.graphSliderMaxValue;

        copy.minDistance = self.minDistance;
        copy.maxDistance = self.maxDistance;
        copy.currentMaxDistance = self.currentMaxDistance;
        copy.distanceLocationPoint = self.distanceLocationPoint;
        
        copy.minRating = self.minRating;
        copy.maxRating = self.maxRating;
        copy.currentMinRating = self.currentMinRating;
        copy.hideHotelsWithNoRooms = self.hideHotelsWithNoRooms;
        copy.hideDormitory = self.hideDormitory;
    }
    
    return copy;
}

-(BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[HLFilter class]]) {
        return NO;
    }
    HLFilter* filterObject = (HLFilter*)object;
    BOOL filterAreEqual = self.amenities == filterObject.amenities &&
                          self.keyString == filterObject.keyString &&
                          self.options == filterObject.options &&
                          self.minPrice == filterObject.minPrice &&
                          self.maxPrice == filterObject.maxPrice &&
                          self.currentMinPrice == filterObject.currentMinPrice &&
                          self.currentMaxPrice == filterObject.currentMaxPrice &&
                          self.minDistance == filterObject.minDistance &&
                          self.maxDistance == filterObject.maxDistance &&
                          self.currentMaxDistance == filterObject.currentMaxDistance &&
                          self.minRating == filterObject.minRating &&
                          self.maxRating == filterObject.maxRating &&
                          self.currentMinRating == filterObject.currentMinRating &&
                          self.hideHotelsWithNoRooms == filterObject.hideHotelsWithNoRooms &&
                          self.hideDormitory == filterObject.hideDormitory;

    return filterAreEqual;
}

- (NSUInteger)hash
{
    return self.keyString.hash ^
           (NSInteger)self.minPrice ^
           (NSInteger)self.maxPrice ^
           (NSInteger)self.currentMaxPrice ^
           (NSInteger)self.currentMinPrice ^
           self.maxRating ^
           self.minRating ^
           self.options.count;
}

- (NSArray <HLResultVariant *> *)allVariants
{
    return self.searchResult.variants ?: @[];
}

- (void)setDistanceLocationPoint:(HDKLocationPoint *)distanceLocationPoint
{
    if (![_distanceLocationPoint isEqual:distanceLocationPoint]) {
        _distanceLocationPoint = distanceLocationPoint;
        [self calculateDistanceBounds:self.searchResult.variants locationPoint:self.distanceLocationPoint];
    }
}

- (void)refreshPriceBounds
{
    self.graphSliderMinValue = _graphSliderMinValue;
    self.graphSliderMaxValue = _graphSliderMaxValue;
}

- (void)calculateBoundsWithVariants:(NSArray *)variants
{
    [self calculateDistanceBounds:self.searchResult.variants locationPoint:self.distanceLocationPoint];
	[self calculatePriceAndOptionsBounds:variants];
    self.priceSliderCalculator = [HLSliderCalculatorFactory priceSliderCalculatorWithFilter:self];
}

#pragma mark - Private

- (void)calculateDistanceBounds:(NSArray *)variants locationPoint:(HDKLocationPoint *)point
{
    if (variants.count == 0) {
        return;
    }
    
    self.minDistance = CGFLOAT_MAX;
    self.maxDistance = -1;

    for (HLResultVariant *variant in variants) {
        CGFloat distance = CGFLOAT_MAX;
        distance = [HLDistanceCalculator getDistanceFromLocationPoint:self.distanceLocationPoint toHotel:variant.hotel];
        if (distance != CGFLOAT_MAX) {
            variant.distanceToCurrentLocationPoint = distance;
            self.maxDistance = MAX(self.maxDistance, distance);
            self.minDistance = MIN(self.minDistance, distance);
        }
    }
    
    self.minDistance += 0.01;
    self.maxDistance += 0.01;

    self.currentMaxDistance = self.maxDistance;
}


- (void)calculatePriceAndOptionsBounds:(NSArray *)variants
{
    self.maxPrice = UNKNOWN_MAX_PRICE;
    self.minPrice = UNKNOWN_MIN_PRICE;
    self.canFilterByOptions = NO;

    BOOL shouldCheckOptions = YES;

    for (HLResultVariant *variant in variants) {
        for (HDKRoom * room in variant.rooms) {
            self.maxPrice = MAX(self.maxPrice, [room price]);
            self.minPrice = MIN(self.minPrice, [room price]);
        }

        if (shouldCheckOptions) {
            for (HDKRoom * room in variant.rooms) {
                if (room.hasBreakfast || room.refundable) {
                    self.canFilterByOptions = YES;
                    shouldCheckOptions = NO;
                }
            }
        }
    }

    if (self.maxPrice == UNKNOWN_MAX_PRICE){
        self.maxPrice = UNKNOWN_MIN_PRICE;
    }
}

#pragma mark - Public

-(void)setCurrentMinPrice:(float)currentMinPrice
{
    _currentMinPrice = currentMinPrice;
    _graphSliderMinValue = [self.priceSliderCalculator sliderValue:currentMinPrice];
}

-(void)setCurrentMaxPrice:(float)currentMaxPrice
{
    _currentMaxPrice = currentMaxPrice;
    _graphSliderMaxValue = [self.priceSliderCalculator sliderValue:currentMaxPrice];
}

-(void)setGraphSliderMinValue:(CGFloat)graphSliderMinValue
{
    _currentMinPrice = self.priceSliderCalculator ? [self.priceSliderCalculator priceValue:graphSliderMinValue roundingRule:HLSliderCalculatorRoundingRuleFloor] : self.minPrice;
    _graphSliderMinValue = graphSliderMinValue;
}

-(void)setGraphSliderMaxValue:(CGFloat)graphSliderMaxValue
{
    _currentMaxPrice = self.priceSliderCalculator ? [self.priceSliderCalculator priceValue:graphSliderMaxValue roundingRule:HLSliderCalculatorRoundingRuleCeil] : self.maxPrice;
    _graphSliderMaxValue = graphSliderMaxValue;
}

- (void)setDefaultLocationPointWith:(HLSearchInfo *)searchInfo
{
    switch (searchInfo.searchInfoType) {
        case HLSearchInfoTypeCity:
            self.distanceLocationPoint = [[HLCityLocationPoint alloc] initWithCity:searchInfo.city];
            break;

        case HLSearchInfoTypeCustomLocation:
        case HLSearchInfoTypeUserLocation: {
            self.distanceLocationPoint = [[HDKLocationPoint alloc] initWithName:NSLS(@"HL_LOC_SEARCH_POINT_TEXT") location:searchInfo.locationPoint.location];
        }
            break;
        case HLSearchInfoTypeAirport:
            self.distanceLocationPoint = [[HDKLocationPoint alloc] initWithName:searchInfo.locationPoint.title location:searchInfo.locationPoint.location];
            break;

        case HLSearchInfoTypeCityCenterLocation:
            self.distanceLocationPoint = [[HLCityLocationPoint alloc] initWithCity:searchInfo.locationPoint.city];
            break;
        default:
            break;
    }
}

- (void)setSearchResult:(SearchResult *)searchResult
{
    HLResultVariant *oldVariant = self.searchResult.variants.lastObject;

    _searchResult = searchResult;
    self.filteredVariants = [self.searchResult.variants mutableCopy];
    self.filteredRoomsWithoutPriceFilter = [self.filteredVariants flattenMap:^NSArray<HDKRoom *>*(HLResultVariant *variant) {
        return variant.rooms;
    }];

    if (searchResult.variants.count > 0) {
        [self calculateBoundsWithVariants:searchResult.variants];

        self.graphSliderMinValue = 0;
        self.graphSliderMaxValue = 1;
    }

    HLResultVariant *newVariant = self.searchResult.variants.lastObject;
    if (![oldVariant.hotel.city isEqual:newVariant.hotel.city]){
        self.currentMaxDistance = self.maxDistance;
    }
}

- (void)applyFilterParams:(HLFilter *)filter
{
    self.amenities = [filter.amenities copy];
    self.keyString = filter.keyString;
    self.options = [filter.options copy];
    
    self.minPrice = filter.minPrice;
    self.maxPrice = filter.maxPrice;

    self.priceSliderCalculator = filter.priceSliderCalculator;
    self.graphSliderMinValue = filter.graphSliderMinValue;
    self.graphSliderMaxValue = filter.graphSliderMaxValue;

    self.minDistance = filter.minDistance;
    self.maxDistance = filter.maxDistance;
    self.currentMaxDistance = filter.currentMaxDistance;
    
    self.minRating = filter.minRating;
    self.maxRating = filter.maxRating;
    self.currentMinRating = filter.currentMinRating;
    
    self.hideHotelsWithNoRooms = filter.hideHotelsWithNoRooms;
    self.hideDormitory = filter.hideDormitory;
}

- (BOOL)canDropFilters
{
    if (self.hideHotelsWithNoRooms) {
        return YES;
    }
    if (self.hideDormitory) {
        return YES;
    }
    if (self.hideSharedBathroom) {
        return YES;
    }
	if (self.currentMaxPrice != self.maxPrice) {
		return YES;
	}
	if (self.currentMinPrice != self.minPrice) {
		return YES;
	}
	if (self.currentMaxDistance != self.maxDistance) {
		return YES;
	}
	if ([self isRatingFilterActive]) {
		return YES;
	}
	if ([self.keyString length] > 0) {
		return YES;
	}
	if (self.options.count > 0) {
		return YES;
	}
	if ([self.amenities count] > 0) {
		return YES;
	}
    if (self.gatesToFilter.count > 0) {
        return YES;
    }
    if (self.districtsToFilter.count > 0) {
        return YES;
    }
    
	return NO;
}

- (void)dropFilters
{
    [self dropCommonValues];

    self.hideSharedBathroom = NO;
    self.hideDormitory = NO;
    self.hideHotelsWithNoRooms = NO;

    _currentMinPrice = _minPrice;
    _currentMaxPrice = _maxPrice;
    self.graphSliderMinValue = 0;
    self.graphSliderMaxValue = 1;
    self.currentMaxDistance = self.maxDistance;
    self.currentMinRating = self.minRating;

    self.filteredVariants = [self.searchResult.variants mutableCopy];
    self.filteredRoomsWithoutPriceFilter = [self.filteredVariants flattenMap:^NSArray<HDKRoom *>*(HLResultVariant *variant) {
        return variant.rooms;
    }];

    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self)

        for (HLResultVariant *variant in self.filteredVariants) {
            [variant dropRoomsFiltering];
        }
        self.filteredVariants = [self sortVariants:self.filteredVariants];
        
        @weakify(self);
        hl_dispatch_main_async_safe(^{
            @strongify(self)
            [self.delegate didFilterVariants];
        });
    });
}

- (void)dropCommonValues
{
    self.amenities = [NSArray array];
    self.options = [NSArray array];
    self.gatesToFilter = [NSArray array];
    self.districtsToFilter = [NSArray array];

    self.keyString = nil;
}

- (BOOL)isRatingFilterActive
{
    return self.currentMinRating != self.minRating;
}

- (NSArray *)sortVariants:(NSArray *)variants
{
    return [VariantsSorter sortVariants:variants withType:self.sortType searchInfo:self.searchInfo];
}

- (BOOL)allVariantsHaveSamePrice
{
    return self.minPrice == self.maxPrice;
}

- (NSArray <NSString *> *)allDistrictNames
{
    return [self.searchResult.counters.hotelsCountAccordingToGates allKeys];
}

- (NSArray *)discountVariants
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(HLResultVariant *variant, NSDictionary *bindings) {
        return [variant hasDiscount];
    }];

    return [self.searchResult.variants filteredArrayUsingPredicate:predicate];
}

- (NSArray *)privatePriceVariants
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(HLResultVariant *variant, NSDictionary *bindings) {
        return [variant hasPrivatePrice];
    }];

    return [self.searchResult.variants filteredArrayUsingPredicate:predicate];
}

-(NSArray *)roomAmenities
{
    NSArray *allRoomAmenities = @[@"4", @"6", @"13", @"14"];
    return [self.amenities filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *  _Nonnull amenity, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [allRoomAmenities containsObject:amenity];
    }]];
}

-(NSArray *)hotelAmenities
{
    NSArray *allHotelAmenities = @[@"0", @"1", @"3", @"5", @"7", @"8", @"9"];
    return [self.amenities filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *  _Nonnull amenity, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [allHotelAmenities containsObject:amenity];
    }]];
}

#pragma mark - HLFilteringOperation delegate

- (void)variantsFiltered:(NSArray<HLResultVariant *>*)filteredVariants withoutPriceFilter:(NSArray<HDKRoom *>*)filteredRoomsWithoutPriceFilter;
{
    self.filteredVariants = [self sortVariants:filteredVariants];
    self.filteredRoomsWithoutPriceFilter = filteredRoomsWithoutPriceFilter;

    HLFilter __weak *weakSelf = self;
    hl_dispatch_main_async_safe(^{
        [weakSelf.delegate didFilterVariants];
    });
}

@end
