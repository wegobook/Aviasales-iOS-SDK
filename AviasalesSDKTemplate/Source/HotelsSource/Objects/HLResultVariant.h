#import <Foundation/Foundation.h>
#import <HotellookSDK/HotellookSDK.h>

@class HLSearchInfo;
@class HLPopularHotelBadge;

#define UNKNOWN_MIN_PRICE MAXFLOAT

typedef enum
{
    HLVariantLoadingState = 0,
    HLVariantRefreshState,
    HLVariantNoContentState,
    HLVariantNormalState,
	HLVariantOutdatedState,
} HLVariantState;


typedef NS_ENUM(NSInteger, HLRoomsAvailability) {
    HLRoomsAvailabilityHasRooms = 0,
    HLRoomsAvailabilityNoRooms,
    HLRoomsAvailabilitySold,
};

NS_ASSUME_NONNULL_BEGIN

@interface HLResultVariant : NSObject <NSCoding, NSCopying>

@property (nullable, nonatomic, strong) NSMutableArray <HDKRoom *> *rooms;
@property (nonatomic, strong, readonly) NSArray *badges;
@property (nullable, nonatomic, strong) NSArray <HLPopularHotelBadge *> *popularBadges;

@property (nullable, nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, strong) HDKHotel *hotel;
@property (nonatomic, strong) HLSearchInfo *searchInfo;
@property (nonatomic, strong) NSString *searchId;
@property (nonatomic, copy) NSArray <NSString *> *gatesSortOrder;

@property (nonatomic, assign, readonly) NSInteger gatesCount;
@property (nonatomic, strong, readonly) NSArray <NSArray <HDKRoom *>*>*roomsByType;
@property (nonatomic, strong, readonly) NSArray <HDKRoom *> *sortedRooms;
@property (nonatomic, strong, readonly) NSArray <HDKRoom *> *filteredRooms;
@property (nullable, nonatomic, strong, readonly) HDKRoom *roomWithMinPrice;

@property (nonatomic, assign) CGFloat distanceToCurrentLocationPoint;

@property (nonatomic, assign, readonly) float minPrice;
@property (nonatomic, assign, readonly) NSInteger duration;
@property (nonatomic, assign, readonly) NSInteger discount;
@property (nonatomic, assign, readonly) float oldMinPrice;
@property (nonatomic, assign, readonly) HDKHighlightType highlightType;
@property (nonatomic, assign, readonly) BOOL hasDiscount;
@property (nonatomic, assign, readonly) BOOL hasPrivatePrice;

+ (instancetype)createEmptyVariant:(HLSearchInfo *)searchInfo hotel:(HDKHotel *)hotel;

- (void)outdate;
- (BOOL)atLeastOnePriceOutdated;
- (BOOL)isGateOutdated:(HDKGate *)gate;
- (void)addRooms:(NSArray *)rooms;
- (void)dropRoomsFiltering;
- (void)filterRoomsWithOptions:(NSArray *)options;
- (void)filterRoomsWithMinPrice:(float)minPrice maxPrice:(float)maxPrice;
- (void)filterRoomsByGates:(NSArray <NSString *> *)gateNames hotelWebsiteString:(NSString *)hotelWebsiteString;
- (void)filterRoomsByAmenity:(NSString *)amenity;
- (void)filterRoomsBySharedBathroom;
- (BOOL)shouldIncludeToFilteredResultsByAmenity:(NSString *)amenity;

- (void)calculateRoomWithMinPriceIfNeeded;
- (BOOL)hasRoomsWithOption:(NSString *)option;
- (HLRoomsAvailability)roomsAvailability;

- (NSArray<HDKRoom *> * _Nullable)roomsCopy;

@end


@interface HLResultVariant (Utils)

+ (NSArray *)selectFav:(NSArray *)favVariants fromAll:(NSArray *)allVariants;
+ (BOOL)hasDiscounts:(NSArray *)variants;
+ (NSInteger)highlightedCount:(NSArray *)variants;

@end

NS_ASSUME_NONNULL_END

