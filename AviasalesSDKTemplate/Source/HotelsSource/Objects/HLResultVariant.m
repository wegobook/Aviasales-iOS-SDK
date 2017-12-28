#import <HotellookSDK/HotellookSDK.h>

#import "HLResultVariant.h"
#import "HLVariantsSorter.h"
#import "DateUtil.h"
#import "HLParseUtils.h"
#import "NSDictionary+Parsing.h"
#import "NSArray+Functional.h"

@interface HLResultVariant()
@property (nonatomic, strong, readwrite) NSArray <HDKRoom *> *filteredRooms;
@end

@implementation HLResultVariant

@synthesize roomWithMinPrice = _roomWithMinPrice;

+ (instancetype)createEmptyVariant:(HLSearchInfo *)searchInfo hotel:(HDKHotel *)hotel
{
    HLResultVariant *variant = [self new];
    variant.lastUpdate = [NSDate date];
    variant.searchInfo = searchInfo;
    variant.hotel = hotel;
    
    return variant;
}

+ (HDKHighlightType)highlightTypeByString:(NSString *)highlightString
{
    static NSDictionary* highlightMapDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        highlightMapDictionary = @{
                                   @"mobile" : @(HDKHighlightTypeMobile),
                                   @"private" : @(HDKHighlightTypePrivate),
                                   @"discount" : @(HDKHighlightTypeDiscount)
                                   };
    });
    
    return highlightString ? [highlightMapDictionary[highlightString] integerValue] : HDKHighlightTypeNone;
}

- (id)init
{
	self = [super init];
	if (self) {
        [self outdate];
	}
    
	return self;
}

- (BOOL)isEqual:(id)object
{
    HLResultVariant *otherVariant = (HLResultVariant *)object;
	if (!otherVariant) {
		return NO;
	}
	if (![otherVariant isKindOfClass:[HLResultVariant class]]) {
		return NO;
	}
	if (![self.hotel isEqual:otherVariant.hotel]) {
		return NO;
	}
	if (![self.searchInfo isEqual:otherVariant.searchInfo]) {
		return NO;
	}
    
	return YES;
}

- (NSUInteger)hash
{
    return self.hotel.hash ^ self.searchInfo.hash;
}

- (NSDictionary *)collectedRoomsByType:(NSArray *)plainRoomsArray
{
    NSMutableDictionary *roomsByTypeDict = [NSMutableDictionary new];
    for (HDKRoom *room in plainRoomsArray) {
        NSString *roomType = room.localizedType;
        NSMutableArray *roomsOfSameType = roomsByTypeDict[roomType];
        if (!roomsOfSameType) {
            roomsOfSameType = [NSMutableArray new];
            roomsByTypeDict[roomType] = roomsOfSameType;
        }
        [roomsOfSameType addObject:room];
    }
    return roomsByTypeDict;
}

#pragma mark - Getters and Setters

- (NSArray *)badges
{
    return _popularBadges;
}

- (NSArray *)sortedRooms
{
    return [RoomsSorter sortRoomsByPrice:self.filteredRooms gatesSortOrder:self.gatesSortOrder];
}

- (NSInteger)gatesCount
{
    NSArray *gatesIds = [self.filteredRooms.copy map: ^(HDKRoom *room) {
        return room.gate.gateId;
    }];
    return [NSSet setWithArray:gatesIds].count;
}

- (NSArray *)roomsByType
{
    NSArray *plainRooms = [RoomsSorter sortRoomsByPrice:self.filteredRooms gatesSortOrder:self.gatesSortOrder];
    NSDictionary *groups = [self collectedRoomsByType:plainRooms];
    return [RoomsSorter sortRoomsGroupsByPrice:groups.allValues];
}

- (BOOL)hasDiscount
{
    return self.roomWithMinPrice.hasDiscountHighlight;
}

- (BOOL)hasPrivatePrice
{
    return self.roomWithMinPrice.hasPrivatePriceHighlight;
}

- (HLRoomsAvailability)roomsAvailability
{
    if (self.rooms.count > 0) {
        return HLRoomsAvailabilityHasRooms;
    }

    for (HDKKnownGuestsRoom *guests in self.hotel.knownGuests.rooms) {
        BOOL adultsMatch = guests.adults == self.searchInfo.adultsCount;
        BOOL childrensMatch = guests.children == self.searchInfo.kidsCount;

        if (adultsMatch && childrensMatch) {
            return HLRoomsAvailabilitySold;
        }
    }

    return HLRoomsAvailabilityNoRooms;
}

- (NSArray *)roomsCopy
{
    return [self.rooms copy];
}

- (void)setSearchInfo:(HLSearchInfo *)searchInfo
{
    _searchInfo = searchInfo;
    _duration = [DateUtil hl_daysBetweenDate:searchInfo.checkInDate andOtherDate:searchInfo.checkOutDate];
}

- (void)setRooms:(NSMutableArray *)rooms
{
    _rooms = rooms;
    [self dropRoomsFiltering];
}

- (NSInteger)discount
{
    return self.roomWithMinPrice.discount;
}

- (float)oldMinPrice
{
    return self.roomWithMinPrice.oldPrice;
}

- (float)minPrice
{
    return self.roomWithMinPrice.price;
}

- (HDKHighlightType)highlightType
{
    return self.roomWithMinPrice.highlightType;
}

- (HDKRoom *)roomWithMinPrice
{
    [self calculateRoomWithMinPriceIfNeeded];
    return _roomWithMinPrice;
}

#pragma mark - Public

- (void)outdate
{
    _lastUpdate = nil;
    _popularBadges = [NSMutableArray new];
    _rooms = [NSMutableArray new];
    self.filteredRooms = [NSArray new];
    _distanceToCurrentLocationPoint = 0.0f;
    _roomWithMinPrice = nil;
    _duration = 1;
}

- (BOOL)atLeastOnePriceOutdated
{
    if (!self.lastUpdate) {
        return YES;
    }

    NSTimeInterval intervalSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:self.lastUpdate];

    NSInteger resultsTTL = [ServiceLocator.shared.resultsTTLManager minResultsTTL];
    return intervalSinceLastUpdate >= resultsTTL;
}

- (BOOL)isGateOutdated:(HDKGate *)gate
{
    if (!self.lastUpdate) {
        return YES;
    }

    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.lastUpdate];
    NSInteger gateTTL = [ServiceLocator.shared.resultsTTLManager resultsTTLForGate:gate.gateId];
    return interval >= gateTTL;
}

- (void)dropRoomsFiltering
{
    self.filteredRooms = [self.rooms copy];
}

- (void)addRooms:(NSArray *)newRooms
{
    if (!self.rooms) {
        _rooms = [NSMutableArray new];
    }
    [self.rooms addObjectsFromArray:newRooms];
    [self dropRoomsFiltering];
}

- (BOOL)hasRoomsWithOption:(NSString *)option
{
    NSDictionary *optionAndValue = [HLParseUtils optionWithValueFromOptionString:option];
    NSString *expectedOption = optionAndValue.allKeys.firstObject;
    BOOL expectedValue = [optionAndValue[expectedOption] boolValue];
    NSArray *filteredByOption = [self filteredRooms:self.rooms withOption:expectedOption expectedValue:expectedValue];

    return filteredByOption.count > 0;
}

- (void)filterRoomsWithOptions:(NSArray <NSString *> *)options
{
    NSArray <NSDictionary *> *optionsAndValues = [HLParseUtils optionsWithValuesFromOptionsStrings:options];

    for (NSDictionary *optionAndValue in optionsAndValues) {
        NSString *optionKey = optionAndValue.allKeys.firstObject;
        BOOL expectedOptionValue = [optionAndValue[optionKey] boolValue];
        self.filteredRooms = [self filteredRooms:self.filteredRooms withOption:optionKey expectedValue:expectedOptionValue];
    }
}

- (NSArray *)filteredRooms:(NSArray *)rooms withOption:(NSString *)option expectedValue:(BOOL)expectedValue
{
    if ([option isEqualToString:RoomOptionConsts.kRoomWifiOptionKey]) {
        return [FilterLogic filterRoomsByWifi:self];
    }
    if ([option isEqualToString:RoomOptionConsts.kRoomDormitoryOptionKey]) {
        return [FilterLogic filterRoomsByDormitory:self];
    }
    if ([option isEqualToString:RoomOptionConsts.kBreakfastOptionKey]) {
        return [FilterLogic filterRoomsByBreakfast:self];
    }

    NSMutableArray *result = [rooms mutableCopy];
    NSIndexSet *indexesToBeRemoved = [result indexesOfObjectsPassingTest:^BOOL(HDKRoom *room, NSUInteger idx, BOOL *stop) {
        return ![room hasOption:option withValue:expectedValue];
    }];
    [result removeObjectsAtIndexes:indexesToBeRemoved];

    return result;
}

- (void)filterRoomsWithMinPrice:(float)minPrice maxPrice:(float)maxPrice
{
    NSIndexSet *indexesToBeRemoved = [self.filteredRooms indexesOfObjectsPassingTest:^BOOL(HDKRoom * room, NSUInteger idx, BOOL *stop) {
        float price = [room price];
        return (price < minPrice || price > maxPrice);
    }];

    NSMutableArray *mutableFilteredRooms = [self.filteredRooms mutableCopy];
    [mutableFilteredRooms removeObjectsAtIndexes:indexesToBeRemoved];
    self.filteredRooms = [mutableFilteredRooms copy];
}

- (void)filterRoomsByGates:(NSArray <NSString *> *)gateNames hotelWebsiteString:(NSString *)hotelWebsiteString
{
    self.filteredRooms = [[FilterLogic filterVariantRoomsByGates:self.filteredRooms gates:gateNames hotelWebsiteString:hotelWebsiteString] mutableCopy];
}

- (void)filterRoomsWithAirConditioning
{
    self.filteredRooms = [[FilterLogic filterRoomsByAirConditioning:self] mutableCopy];
}

- (void)filterRoomsBySharedBathroom
{
    self.filteredRooms = [[FilterLogic filterRoomsBySharedBathroom:self] mutableCopy];
}

- (void)filterRoomsByAmenity:(NSString *)amenity
{
    if ([self.hotel.amenitiesShort[amenity].slug isEqual:RoomOptionConsts.kHotelAirConditioningOptionKey]) {
        [self filterRoomsWithAirConditioning];
    }
}

- (BOOL)shouldIncludeToFilteredResultsByAmenity:(NSString *)amenity
{
    if ([self.hotel.amenitiesShort[amenity].slug isEqual:RoomOptionConsts.kHotelAirConditioningOptionKey]) {
        return self.filteredRooms.count > 0;
    }

    for (NSString *amenityPiece in [amenity componentsSeparatedByString:@"|"]) {
        if ([[self.hotel.amenitiesShort allKeys] containsObject:amenityPiece]) {
            return YES;
        }
    }

    return NO;
}

- (void)setFilteredRooms:(NSArray<HDKRoom *> *)filteredRooms
{
    _filteredRooms = filteredRooms;
    _roomWithMinPrice = nil;
}

- (void)calculateRoomWithMinPriceIfNeeded
{
    if (_roomWithMinPrice == nil && self.filteredRooms.count > 0) {
        [self calculateRoomWithMinPrice];
    }
}

- (void)calculateRoomWithMinPrice
{
    @synchronized(self.filteredRooms) {
        for (NSInteger i = 0; i < self.filteredRooms.count; i++) {
            HDKRoom *room = self.filteredRooms[i];

            NSUInteger currentRoomOrder = [self.gatesSortOrder indexOfObject:room.gate.gateId];
            NSUInteger minPriceRoomOrder = [self.gatesSortOrder indexOfObject:_roomWithMinPrice.gate.gateId];

            BOOL firstRoom = i == 0;
            BOOL lowerPrice = room.price < _roomWithMinPrice.price;
            BOOL samePrice = room.price == _roomWithMinPrice.price;
            BOOL highGateOrder = currentRoomOrder < minPriceRoomOrder;

            if (firstRoom || lowerPrice || (samePrice && highGateOrder)) {
                _roomWithMinPrice = room;
            }
        }
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.lastUpdate forKey:@"lastUpdate"];
    [aCoder encodeObject:self.searchInfo forKey:@"searchInfo"];
    [aCoder encodeObject:self.rooms forKey:@"rooms"];
    [aCoder encodeObject:self.hotel forKey:@"hotel"];
    [aCoder encodeObject:self.searchId forKey:@"searchId"];
    [aCoder encodeObject:self.gatesSortOrder forKey:@"gatesSortOrder"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.lastUpdate = [aDecoder decodeObjectForKey:@"lastUpdate"];
        self.searchInfo = [aDecoder decodeObjectForKey:@"searchInfo"];
        self.rooms = [aDecoder decodeObjectForKey:@"rooms"];
        self.hotel = [aDecoder decodeObjectForKey:@"hotel"];
        self.searchId = [aDecoder decodeObjectForKey:@"searchId"];
        self.gatesSortOrder = [aDecoder decodeObjectForKey:@"gatesSortOrder"];
    }

    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    HLResultVariant * variantCopy = [HLResultVariant new];
    variantCopy.rooms = self.rooms;
    variantCopy.popularBadges = _popularBadges;
    variantCopy.lastUpdate = self.lastUpdate;
    variantCopy.hotel = self.hotel;
    variantCopy.searchInfo = [self.searchInfo copy];
    variantCopy.searchId = [self.searchId copy];
    variantCopy.gatesSortOrder = [self.gatesSortOrder copy];
    [variantCopy dropRoomsFiltering];
    
    return variantCopy;
}

@end


@implementation HLResultVariant (Utils)

+ (NSArray *)selectFav:(NSArray *)favVariants fromAll:(NSArray *)allVariants
{
    NSMutableArray *favIds = [NSMutableArray new];
    for (HLResultVariant *variant in favVariants) {
        if (variant.hotel.hotelId) {
            [favIds addObject:variant.hotel.hotelId];
        }
    }
    
    NSMutableArray *selected = [NSMutableArray new];
    for (HLResultVariant *variant in allVariants) {
        @autoreleasepool {
            NSString *favFound = nil;
            for (NSString *favId in favIds) {
                if ([favId isEqualToString:variant.hotel.hotelId]) {
                    [selected addObject:[variant copy]];
                    favFound = favId;
                }
            }
            
            if (favFound) {
                [favIds removeObject:favFound];
            }
        }
    }

    return selected;
}

+ (BOOL)hasDiscounts:(NSArray *)variants
{
    for (HLResultVariant *variant in variants) {
        if ([variant hasDiscount]) {
            return YES;
        }
    }
    return NO;
}

+ (NSInteger)highlightedCount:(NSArray *)variants
{
    NSInteger result = 0;
    for (HLResultVariant *variant in variants) {
        if ([variant highlightType] != HDKHighlightTypeNone) {
            result += 1;
        }
    }
    return result;
}

@end
