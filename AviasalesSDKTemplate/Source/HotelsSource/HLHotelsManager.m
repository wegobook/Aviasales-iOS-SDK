#import "HLHotelsManager.h"
#import "HDKCity+Hotellook.h"
#import <HotellookSDK/HotellookSDK.h>
#import <PromiseKit/PromiseKit.h>
#import "NSArray+Functional.h"
#import "HLLocaleInspector.h"

typedef NSDictionary<NSString *, NSArray <HDKSeason *> *>            HLSeasonsMapByCityId;
typedef NSDictionary<NSString *, NSArray <HDKLocationPoint *> *>     HLPointsMapByCityId;


@interface HLHotelsManager () <HLCityInfoLoadingProtocol>

@property (nonatomic, strong) id<Cancellable> loadHotelDetailsTask;
@property (nonatomic, strong) id<Cancellable> loadHotelsTask;

@end



@interface HLHotelsManager (HotelContentUtils)

- (void)notifyDelegateWithError:(NSError *)error;
- (void)notifyDelegateWithHotels:(NSArray <HDKHotel *> *)hotels cities:(NSArray <HDKCity *> *)cities;

@end


@implementation HLHotelsManager

- (BOOL)isLoading
{
    return (self.loadHotelsTask != nil || self.loadHotelDetailsTask != nil);
}

- (void)stopLoading
{
    [self.loadHotelsTask cancel];
    self.loadHotelsTask = nil;

    [self.loadHotelDetailsTask cancel];
    self.loadHotelDetailsTask = nil;
}

#pragma mark - HotelContent methods

- (void)loadHotelsContentForCities:(NSArray <HDKCity *> *)cities
{
    NSMutableArray <HDKHotel *> *loadedHotels = [NSMutableArray new];
    NSMutableArray <HDKCity *> *loadedCities = [NSMutableArray new];

    @weakify(self);
    hl_dispatch_main_sync_safe(^{
        @strongify(self);

        @weakify(self);
        void (^completionBlock)(HDKLocationListResponse *, NSError *) = ^(HDKLocationListResponse *hotelsDump, NSError *error) {
            @strongify(self);
            self.loadHotelsTask = nil;

            if (error) {
                [self notifyDelegateWithError:error];
                return;
            }

            for (HDKLocationInfoResponse *dump in hotelsDump.cities.allValues) {
                [loadedCities addObject: dump.city];
                for (HDKHotel *hotel in dump.hotels) {
                    hotel.city = dump.city;
                    [loadedHotels addObject:hotel];
                }
            }
            if (loadedCities.count > 0) {
                [self notifyDelegateWithHotels:loadedHotels cities:loadedCities];
            } else {
                [self notifyDelegateWithError:[NSError errorWithCode:HLEmptyResultsNonCriticalError]];
            }
        };

        BOOL priceless = (cities.count == 1) && (cities.firstObject.hotelsCount < 100);
        NSArray <NSString *> *citiesIds = [cities map:^NSString *(HDKCity *city) {
            return city.cityId;
        }];

        self.loadHotelsTask = [ServiceLocator.shared.sdkFacade loadHotelsWithCitiesIds:citiesIds
                                                                              priceless:priceless
                                                                             apartments:NO
                                                                             completion:completionBlock];
    });
}

- (void)updateCityForHotel:(HDKHotel *)hotel withCity:(HDKCity *)city
{
    if ([hotel.city.cityId isEqualToString:city.cityId]) {
        hotel.city = city;
    } else {
        NSLog(@"bad city id for hotel");
    }
}

#pragma mark - HLHotelDetailsLoaderDelegate Methods

- (void)hotelDetailsDidLoad:(HDKHotel *)hotel
{
    hl_dispatch_main_sync_safe(^{
        if ([self.delegate respondsToSelector:@selector(hotelsManagerDidLoadHotelDetails:)]) {
            [self.delegate hotelsManagerDidLoadHotelDetails:hotel];
        }
    });
}

- (void)hotelDetailsLoadingFailed:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(hotelsManagerFailedWithError:)]) {
        [self.delegate hotelsManagerFailedWithError:error];
    }
}

- (void)hotelDetailsLoadingCancelled
{
    if ([self.delegate respondsToSelector:@selector(hotelsManagerCancelled)]) {
        [self.delegate hotelsManagerCancelled];
    }
}

#pragma mark - HotelDetails methods

- (void)loadHotelDetailsForHotel:(HDKHotel *)hotel
{
    if (hotel.hotelId == nil) {
        [self hotelDetailsLoadingFailed:[NSError errorWithCode:HLHotelDetailsLoadingEmptyHotelIdError]];
        return;
    }

    [self.loadHotelDetailsTask cancel];
    self.loadHotelDetailsTask = nil;

    hl_dispatch_main_sync_safe(^{
        self.loadHotelDetailsTask = [ServiceLocator.shared.sdkFacade loadHotelDetailsWithHotelId:hotel.hotelId
                                                                                       completion:^(HDKHotel *newHotel, NSError *error) {
                                                                                           self.loadHotelDetailsTask = nil;
                                                                                           if (error) {
                                                                                               if (error.isCancelled) {
                                                                                                   [self hotelDetailsLoadingCancelled];
                                                                                               } else {
                                                                                                   [self hotelDetailsLoadingFailed:error];
                                                                                               }
                                                                                               return;
                                                                                           }
                                                                                           [hotel updateByHotelDetailsHotel:newHotel];
                                                                                           [self hotelDetailsDidLoad:hotel];
                                                                                       }];
    });
}

@end


@implementation HLHotelsManager (HotelContentUtils)

- (void)notifyDelegateWithError:(NSError *)error
{
    if (error.code == NSURLErrorCancelled) {
        if ([self.delegate respondsToSelector:@selector(hotelsManagerCancelled)]) {
            [self.delegate hotelsManagerCancelled];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(hotelsManagerFailedWithError:)]) {
            [self.delegate hotelsManagerFailedWithError:error];
        }
    }
}

- (void)notifyDelegateWithHotels:(NSArray <HDKHotel *> *)hotels cities:(NSArray <HDKCity *> *)cities
{
    hl_dispatch_main_sync_safe(^{
        if ([self.delegate respondsToSelector:@selector(hotelsManagerDidLoadHotelsContent:cities:)]) {
            [self.delegate hotelsManagerDidLoadHotelsContent:hotels cities:cities];
        }
    });
}

@end

