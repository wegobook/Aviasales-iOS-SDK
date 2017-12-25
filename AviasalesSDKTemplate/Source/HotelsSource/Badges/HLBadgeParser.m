#import <HotellookSDK/HotellookSDK.h>
#import "HLBadgeParser.h"
#import "HLResultVariant.h"
#import "NSDictionary+Parsing.h"
#import "NSArray+Functional.h"
#import "UIColor+Hex.h"
#import "NSMutableArray+SafeAdd.h"

@implementation HLBadgeParser

- (void)fillBadgesFor:(NSArray<HLResultVariant *> *)variants
     badgesDictionary:(NSDictionary<NSString *, HDKBadge *> *)badges
         hotelsBadges:(NSDictionary<NSString *, NSArray<NSString *> *> *)hotelsBadges
           hotelsRank:(NSDictionary<NSString *, NSNumber *> *)hotelsRank;
{
    for (HLResultVariant *variant in variants) {
        NSString *hotelId = variant.hotel.hotelId;
        NSAssert(hotelId != nil, @"hotelId != nil");

        [self updateHotelPopularityIfServerKnowsIt:variant withHotelsRank:hotelsRank];
        NSMutableArray *variantBadges = [NSMutableArray new];
        [variantBadges addIfNotNil:[self ratingBadgeForVariant:variant hotelBadges:hotelsBadges]];
        [variantBadges addObjectsFromArray:[self serverBadgesForVariant:variant badgesDictionary:badges hotelsBadges:hotelsBadges]];
        [variantBadges addIfNotNil:[self discountBadgeForVarinant:variant]];
        [variantBadges addIfNotNil:[self distanceBadgeForVariant:variant]];
        variant.popularBadges = variantBadges;
    }
}
- (HLRatingBadge *)ratingBadgeForVariant:(HLResultVariant *)variant hotelBadges:(NSDictionary *)hotelsBadges
{
    BOOL onlyRatingBadge = [[hotelsBadges arrayForKey:variant.hotel.hotelId] count] == 0 && !variant.searchInfo.isSearchByLocation && !variant.hasDiscount;
    return variant.hotel.rating > 0 ? [[HLRatingBadge alloc] initWithRating:variant.hotel.rating isFull:onlyRatingBadge] : nil;
}

- (NSArray *)serverBadgesForVariant:(HLResultVariant *)variant
                   badgesDictionary:(NSDictionary<NSString *, HDKBadge *> *)badges
                       hotelsBadges:(NSDictionary<NSString *, NSArray<NSString *> *> *)hotelsBadges
{
    NSArray *hotelBadgeNames = [hotelsBadges arrayForKey:variant.hotel.hotelId];
    NSArray *badgesDomainObjects = [hotelBadgeNames map:^HLPopularHotelBadge *(NSString *name) {
        return [self badgeByName:name badgesDictionary:badges];
    }];

    return badgesDomainObjects;
}

- (HLDiscountHotelBadge *)discountBadgeForVarinant:(HLResultVariant *)variant
{
    return variant.hasDiscount ? [[HLDiscountHotelBadge alloc] initWithDiscount: variant.discount] : nil;
}

- (HLDistanceBadge *)distanceBadgeForVariant:(HLResultVariant *)variant
{
    if (variant.searchInfo.isSearchByLocation) {
        BOOL userLocationSearch = [variant.searchInfo.locationPoint isKindOfClass:[HLSearchUserLocationPoint class]];
        DistancePointType pointType = userLocationSearch ? DistancePointTypeUserLocation : DistancePointTypeCustomLocation;
        CLLocation *searchLocationPoint = variant.searchInfo.locationPoint.location;
        CLLocation *hotelLocation = [[CLLocation alloc] initWithLatitude:variant.hotel.latitude longitude:variant.hotel.longitude];
        double distance = [searchLocationPoint distanceFromLocation:hotelLocation];
        return [[HLDistanceBadge alloc] initWithDistance:distance pointType:pointType];
    } else {
        return nil;
    }
}

- (void)updateHotelPopularityIfServerKnowsIt:(HLResultVariant *)variant withHotelsRank:(NSDictionary<NSString *, NSNumber *> *)hotelsRank
{
    // If hotelsRank is empty this means server data consistency fails.
    // As fallback we will use `popularity` field from CityHotelsDump which already set in hotel.
    if (hotelsRank.count > 0) {
        NSInteger rank = [hotelsRank integerForKey:variant.hotel.hotelId defaultValue:hotelsRank.count+1];
        variant.hotel.popularity = hotelsRank.count - rank;
        variant.hotel.rank = [hotelsRank integerForKey:variant.hotel.hotelId defaultValue:-1];
    }
}

- (HLPopularHotelBadge *)badgeByName:(NSString *)systemName badgesDictionary:(NSDictionary<NSString *, HDKBadge *> *)badges
{
    HDKBadge *badgeInfo = badges[systemName];
    if (badgeInfo == nil) {
        return nil;
    }

    NSString *localizedTitle = badgeInfo.text;
    UIColor *color = [UIColor colorWithCSS:badgeInfo.color];

    return [[HLTextBadge alloc] initWithName:localizedTitle systemName:systemName color:color];
}

@end
