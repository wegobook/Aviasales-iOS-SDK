#import "HLFilteringOperation.h"
#import "HLResultVariant.h"
#import <HotellookSDK/HotellookSDK.h>
#import "NSArray+Functional.h"

@implementation HLFilteringOperation

- (void)main
{
    @autoreleasepool {
        NSArray *amenities = [NSArray arrayWithArray:self.filter.amenities];
        NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:self.variants];
        for (HLResultVariant *variant in resultArray) {
            [variant dropRoomsFiltering];
        }

        @weakify(self);
        NSIndexSet *indexesToBeRemoved = [resultArray indexesOfObjectsPassingTest:^BOOL(HLResultVariant *variant, NSUInteger idx, BOOL *stop) {
            @strongify(self);

            if (!self || self.isCancelled) {
                *stop = YES;
                
                return NO;
            }

            if (![FilterLogic doesVariantConformPropertyType:variant filter:self.filter]) {
                return YES;
            }

            if(self.filter.hideHotelsWithNoRooms && variant.rooms.count == 0){
                return YES;
            }

            if (![FilterLogic doesVariantConformNameFilter:variant filterString:self.filter.keyString]) {
                return YES;
            }
                        
            if (self.filter.currentMaxDistance != self.filter.maxDistance) {
                if (variant.distanceToCurrentLocationPoint > self.filter.currentMaxDistance) {
                    return YES;
                }
            }
            
            NSInteger rating = variant.hotel.rating;
            if (rating < self.filter.currentMinRating) {
                return YES;
            }

            if (![FilterLogic doesVariantConformStarsFilter:variant filter:self.filter]) {
                return YES;
            }

            for (NSString *amenity in amenities) {
                [variant filterRoomsByAmenity:amenity];
                if (![variant shouldIncludeToFilteredResultsByAmenity:amenity]) {
                    return YES;
                }
            }

            if (self.filter.districtsToFilter.count > 0) {
                if (![self.filter.districtsToFilter containsObject:variant.hotel.firstDistrictName]) {
                    return YES;
                }
            }

            if (self.filter.gatesToFilter.count > 0) {
                [variant filterRoomsByGates:self.filter.gatesToFilter hotelWebsiteString:[FilterLogic hotelWebsiteAgencyName]];
                if (variant.filteredRooms.count == 0) {
                    return YES;
                }
            }

            if (self.filter.options.count > 0) {
                [variant filterRoomsWithOptions:self.filter.options];
                if (variant.filteredRooms.count == 0) {
                    return YES;
                }
            }

            if (self.filter.hideDormitory) {
                [variant filterRoomsWithOptions:@[RoomOptionConsts.kRoomDormitoryOptionKey]];
                if (variant.filteredRooms.count == 0) {
                    return YES;
                }
            }

            if (self.filter.hideSharedBathroom) {
                [variant filterRoomsBySharedBathroom];
                if (variant.filteredRooms.count == 0) {
                    return YES;
                }
            }

            return NO;
        }];
        
        if (!self.isCancelled) {
            [resultArray removeObjectsAtIndexes:indexesToBeRemoved];

            NSArray<HDKRoom *>*filteredRoomsWithoutPriceFilter = [resultArray flattenMap:^NSArray<HDKRoom *>*(HLResultVariant *variant) {
                return variant.filteredRooms;
            }];

            @weakify(self);
            NSIndexSet *indexesToBeRemoved = [resultArray indexesOfObjectsPassingTest:^BOOL(HLResultVariant *variant, NSUInteger idx, BOOL *stop) {
                @strongify(self);

                if (!self || self.isCancelled) {
                    *stop = YES;

                    return NO;
                }

                if ((self.filter.maxPrice > self.filter.currentMaxPrice) || (self.filter.minPrice < self.filter.currentMinPrice)) {

                    [variant filterRoomsWithMinPrice:self.filter.currentMinPrice maxPrice:self.filter.currentMaxPrice];
                    if (variant.filteredRooms.count == 0) {
                        return YES;
                    }
                }
                return NO;
            }];
            
            if (!self.isCancelled) {
                [resultArray removeObjectsAtIndexes:indexesToBeRemoved];

                for (HLResultVariant *variant in resultArray) {
                    [variant calculateRoomWithMinPriceIfNeeded];
                }
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(variantsFiltered:withoutPriceFilter:)]) {
                    [self.delegate variantsFiltered:[resultArray copy] withoutPriceFilter:filteredRoomsWithoutPriceFilter];
                }
            }
        }
    }
}

- (BOOL)isConcurrent
{
    return YES;
}

@end
