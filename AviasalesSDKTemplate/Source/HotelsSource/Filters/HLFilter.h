#import <Foundation/Foundation.h>
#import "HLFilteringOperation.h"
#import "HLVariantsSorter.h"
#import <HotellookSDK/HotellookSDK.h>
#import "HLFilterDelegate.h"

@class HLResultVariant;
@class SearchResult;
@class HDKRoom;
@class HLSearchInfo;
@class HLPriceSliderCalculator;

@interface HLFilter : NSObject <NSCopying, HLFilteringOperationDelegate>

@property (nonatomic, strong) NSOperationQueue *filterQueue;

@property (nonatomic, copy) NSString *keyString;
@property (nonatomic, copy) NSArray<NSString *> *amenities;

@property (nonatomic, strong) SearchResult *searchResult;
@property (nonatomic, strong, readonly) NSArray<HLResultVariant *> *filteredVariants;
@property (nonatomic, strong, readonly) NSArray<HLResultVariant *> *allVariants;
@property (nonatomic, strong, readonly) NSArray<HDKRoom *> *filteredRoomsWithoutPriceFilter;

@property (nonatomic, weak) id<HLFilterDelegate> delegate;

@property (nonatomic, assign) float minPrice;
@property (nonatomic, assign) float maxPrice;
@property (nonatomic, assign) float currentMinPrice;
@property (nonatomic, assign) float currentMaxPrice;
@property (nonatomic, assign) CGFloat graphSliderMinValue;
@property (nonatomic, assign) CGFloat graphSliderMaxValue;
@property (nonatomic, strong) HLPriceSliderCalculator *priceSliderCalculator;

@property (nonatomic, assign) NSInteger minRating;
@property (nonatomic, assign) NSInteger maxRating;
@property (nonatomic, assign) NSInteger currentMinRating;

@property (nonatomic, assign) CGFloat minDistance;
@property (nonatomic, assign) CGFloat maxDistance;
@property (nonatomic, assign) CGFloat currentMaxDistance;

@property (nonatomic, assign) BOOL hideHotelsWithNoRooms;
@property (nonatomic, assign) BOOL hideDormitory;
@property (nonatomic, assign) BOOL hideSharedBathroom;

@property (nonatomic, assign) BOOL canFilterByOptions;

@property (nonatomic, assign) SortType sortType;

@property (nonatomic, strong) NSArray<NSString *> *options;
@property (nonatomic, strong) NSArray<NSString *> *gatesToFilter;
@property (nonatomic, strong) NSArray<NSString *> *districtsToFilter;
@property (nonatomic, strong) HDKLocationPoint *distanceLocationPoint;

@property (nonatomic, readonly) NSArray *roomAmenities;
@property (nonatomic, readonly) NSArray *hotelAmenities;

@property (nonatomic, strong) HLSearchInfo *searchInfo;

- (void)setDefaultLocationPointWith:(HLSearchInfo *)searchInfo;
- (void)refreshPriceBounds;
- (void)calculateBoundsWithVariants:(NSArray *)variants;
- (void)applyFilterParams:(HLFilter *)filter;
- (void)dropFilters;
- (void)dropCommonValues;
- (BOOL)allVariantsHaveSamePrice;
- (BOOL)canDropFilters;
- (BOOL)isRatingFilterActive;
- (NSArray <NSString *> *)allDistrictNames;
- (NSArray *)discountVariants;
- (NSArray *)privatePriceVariants;

@end
