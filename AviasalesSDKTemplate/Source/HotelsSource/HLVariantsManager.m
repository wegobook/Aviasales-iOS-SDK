#import <HotellookSDK/HotellookSDK.h>
#import <PromiseKit/PromiseKit.h>

#import "HLLocaleInspector.h"
#import "HLVariantsManager.h"
#import "HLHotelsManager.h"
#import "HLResultVariant.h"
#import "HLVariantsSorter.h"
#import "NSArray+HLContentComparison.h"
#import "HLBadgeParser.h"

NSString * const HL_VARIANTS_MANAGER_DID_LOAD_HOTELS = @"hl_variantsManagerDidLoadHotels";
NSString * const HL_VARIANTS_MANAGER_DID_LOAD_PRICES = @"hl_variantsManagerDidLoadPrices";

@interface HLVariantsManager() <HDKSearchLoaderDelegate, HLHotelsManagerDelegate>

@property (nonatomic, strong) HDKRoomsLoader *roomsLoader;
@property (nonatomic, strong) HLCitiesByPointDetector *citiesByPointDetector;
@property (nonatomic, strong) HLHotelsManager *hotelsManager;
@property (nonatomic, strong) SearchResult *searchResult;
@property (nonatomic, strong) NSString *searchId;
@property (nonatomic, strong) NSDictionary *rooms;
@property (nonatomic, strong, readwrite) NSArray *hotels;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSArray *nearbyCities;
@property (nonatomic, assign) BOOL isSearchInProgress;

@property (atomic, assign) UIBackgroundTaskIdentifier __block backgroundTask;

@end


@implementation HLVariantsManager

- (void)dealloc
{
    [self.roomsLoader cancel];
}

#pragma mark - Public

- (void)startCitySearch
{
    if (self.searchInfo) {
        self.hotels = nil;
        self.nearbyCities = nil;
        
        [self prepareForStartSearch];
        [self startHotelsLoader];
        [self startSearchRoomLoader];
        [self startNearbyCitiesSearchForSearchInfo:self.searchInfo];
        
    } else {
        [self collectingVariantsFailedWithError:[NSError errorWithCode:HLNoSearchInfoError]];
    }
}

- (void)startHotelSearch:(HDKHotel *)hotel
{
    if (self.searchInfo) {
        self.hotels = @[hotel];
        self.nearbyCities = @[];
        
        [self prepareForStartSearch];
        [self startHotelRoomLoader:hotel];

    } else {
        [self collectingVariantsFailedWithError:[NSError errorWithCode:HLNoSearchInfoError]];
    }
}

- (void)stopSearch
{
    [self searchEnded];

    if (self.delegate && [self.delegate respondsToSelector:@selector(variantsManagerCancelled)]) {
        [self.delegate variantsManagerCancelled];
    }

    [self.roomsLoader cancel];

    [self stopBackgroundTask];
}

#pragma mark - Private

- (void)searchEnded
{
    [self.hotelsManager stopLoading];
    self.hotelsManager = nil;

    self.isSearchInProgress = NO;
}

- (void)startNearbyCitiesSearchForSearchInfo:(HLSearchInfo *)searchInfo
{
    self.nearbyCities = nil;
    self.citiesByPointDetector = [[HLCitiesByPointDetector alloc] init];
    @weakify(self)
    [self.citiesByPointDetector detectNearbyCitiesForSearchInfo:searchInfo onCompletion:^(NSArray<HDKCity *> *cities) {
        @strongify(self)
        self.nearbyCities = cities;
        [self tryCollectingVariants];
    } onError:^(NSError *error) {
        @strongify(self)
        self.nearbyCities = @[];
        [self tryCollectingVariants];
    }];
}

- (void)prepareForStartSearch
{
    HLVariantsManager __weak * weakSelf = self;
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        HLVariantsManager __strong *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf stopSearch];
        }
    }];

    self.searchResult = [[SearchResult alloc] initWithSearchInfo:self.searchInfo];
    self.rooms = nil;
    self.isSearchInProgress = YES;
    self.startDate = [NSDate date];
}

- (void)collectingVariantsFailedWithError:(NSError *)error
{
    [self searchEnded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(variantsManagerFailedWithError:)]) {
        [self.delegate variantsManagerFailedWithError:error];
    }

    [self stopBackgroundTask];
}

- (void)collectingVariantsCancelled
{
    if ([self.delegate respondsToSelector:@selector(variantsManagerCancelled)]) {
        [self.delegate variantsManagerCancelled];
    }

    [self stopBackgroundTask];
}

- (NSString *)langParam
{
    return [HLLocaleInspector.sharedInspector localeString];
}

- (NSString *)marker
{
    return [ConfigManager shared].partnerMarker;
}

- (void)startHotelRoomLoader:(HDKHotel *)hotel
{
    self.roomsLoader = [ServiceLocator.shared.sdkFacade roomsLoader];
    self.roomsLoader.delegate = self;
    [self.roomsLoader startSearchForHotelWith:self.searchInfo marker:self.marker marketing:nil hotelId:hotel.hotelId];
}

- (void)startSearchRoomLoader
{
    self.roomsLoader = [ServiceLocator.shared.sdkFacade roomsLoader];
    self.roomsLoader.delegate = self;
    [self.roomsLoader startSearchForCityWith:self.searchInfo marker:self.marker marketing:nil];
}

- (void)startHotelsLoader
{
    self.hotelsManager = [HLHotelsManager new];
    self.hotelsManager.delegate = self;
    NSArray *cities;
    
    if (self.searchInfo.city) {
        cities = @[self.searchInfo.city];
    } else if (self.searchInfo.locationPoint.nearbyCities) {
        cities = self.searchInfo.locationPoint.nearbyCities;
    }
    [self.hotelsManager loadHotelsContentForCities:cities];
}

- (void)tryCollectingVariants
{
    if (!self.rooms || !self.hotels || self.nearbyCities == nil) {
        return;
    }

    [self saveResultsTTL];
    
    @weakify(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self)
        if (!self) {
            return;
        }

        NSDictionary *variantsDict = [self createEmptyVariantsByHotels:self.hotels gatesSortOrder:self.roomsLoader.gatesSortOrder];
        [self updateRooms:self.rooms withRoomTypes:self.roomsLoader.roomTypes];
        [self fillVariants:variantsDict withRooms:self.rooms];
        NSArray *variantsArray = [variantsDict allValues];

        HLBadgeParser *badgeParser = [HLBadgeParser new];
        [badgeParser fillBadgesFor:variantsArray
                  badgesDictionary:self.roomsLoader.badges
                      hotelsBadges:self.roomsLoader.hotelsBadges
                        hotelsRank:self.roomsLoader.hotelsRank];

        variantsArray = [VariantsSorter sortVariantsByPopularity:variantsArray searchInfo:self.searchInfo];

        self.searchResult = [[SearchResult alloc] initWithSearchInfo:self.searchInfo variants:variantsArray nearbyCities:self.nearbyCities];
        self.searchResult.searchId = self.searchId;

        [self searchEnded];

        @weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self notifyDelegateSearchFinished];
        });
    });
}

- (void)saveResultsTTL
{
    [ServiceLocator.shared.searchConfigStore saveResultsTTL:self.roomsLoader.resultsTTLByGate ttlDefault:self.roomsLoader.resultsTTL];
}

- (void)updateRooms:(NSDictionary *)rooms withRoomTypes:(NSDictionary<NSString *, HDKRoomType *> *)roomTypes
{
    for (NSString *hotelId in rooms) {
        NSArray *hotelRooms = rooms[hotelId];
        for (HDKRoom *room in hotelRooms) {
            NSString *internalTypeString = room.internalTypeId;
            NSString *roomTypeName = roomTypes[internalTypeString].name;
            if (!roomTypeName) {
                roomTypeName = NSLS(@"HL_LOC_DEFAULT_ROOM_TYPE");
            }
            room.localizedType = roomTypeName;
        }
    }
}

- (void)fillVariants:(NSDictionary *)variants withRooms:(NSDictionary *)rooms
{
    for (NSString *hotelId in rooms) {
        NSArray *hotelRooms = rooms[hotelId];
        if (hotelRooms && hotelRooms.count) {
            HLResultVariant *variant = variants[hotelId];
            if (variant) {
                [variant addRooms:hotelRooms];
            }
        }
    }
}

- (NSDictionary *)createEmptyVariantsByHotels:(NSArray *)hotels gatesSortOrder:(NSArray<NSString *> *)gatesSortOrder
{
    NSMutableDictionary *emptyVariants = [NSMutableDictionary dictionary];
    HLSearchInfo *copySearchInfo = [self.searchInfo copy];
    for (HDKHotel *hotel in hotels) {
        @autoreleasepool {
            HLResultVariant *variant = [HLResultVariant createEmptyVariant:copySearchInfo hotel:hotel];
            variant.searchId = self.searchId;
            variant.gatesSortOrder = gatesSortOrder;
            [emptyVariants setObject:variant forKey:variant.hotel.hotelId];
        }
    }
    
    return emptyVariants;
}

- (void)notifyDelegateSearchFinished
{
    [self stopBackgroundTask];
	
    if ([self.delegate respondsToSelector:@selector(variantsManagerFinished:)]) {
        [self.delegate variantsManagerFinished:self.searchResult];
    }
    [[InteractionManager shared] hotelsSearchFinished:self.searchInfo];
}

- (NSTimeInterval)currentSearchDuration
{
    return [[NSDate date] timeIntervalSinceDate:self.startDate];
}

- (void)stopBackgroundTask
{
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

#pragma mark - HLHotelsManagerDelegate

- (void)hotelsManagerDidLoadHotelsContent:(NSArray *)hotels cities:(NSArray <HDKCity *> *)cities
{
    BOOL citiesIdsAreCorrect = NO;
    switch (self.searchInfo.searchInfoType) {
        case HLSearchInfoTypeCity: {
            HDKCity *loadedCity = cities.firstObject;
            citiesIdsAreCorrect = [self.searchInfo.city.cityId isEqualToString:loadedCity.cityId];
            if (citiesIdsAreCorrect) {
                self.searchInfo.city = loadedCity;
            }
            self.hotels = hotels;
            [self tryCollectingVariants];
        } break;
        case HLSearchInfoTypeUserLocation:
        case HLSearchInfoTypeCustomLocation:
        case HLSearchInfoTypeCityCenterLocation:
        case HLSearchInfoTypeAirport: {
            citiesIdsAreCorrect = [[HDKCity citiesIdsFromCities:cities] hl_isContentEqualToArray:[HDKCity citiesIdsFromCities:self.searchInfo.locationPoint.nearbyCities]];
            if (citiesIdsAreCorrect) {
                self.searchInfo.locationPoint.nearbyCities = cities;
                self.hotels = hotels;
                [self tryCollectingVariants];
            }
        } break;
        default:
            break;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:HL_VARIANTS_MANAGER_DID_LOAD_HOTELS object:nil];
}

- (void)hotelsManagerFailedWithError:(NSError *)error
{
    [self collectingVariantsFailedWithError:error];
}

- (void)hotelsManagerCancelled
{
    [self stopSearch];
}

#pragma mark - HLSearchLoaderDelegate

- (void)searchStartedWithGates:(NSArray<HDKGate *> *)gates searchId:(NSString *)searchId
{
    self.searchId = searchId;
    if ([self.delegate respondsToSelector:@selector(variantsManagerSearchRoomsStartedWithGates:)]) {
        [self.delegate variantsManagerSearchRoomsStartedWithGates:gates];
    }
}

- (void)searchLoaderDidReceiveDataFromGateIds:(NSArray *)gateIds
{
    if ([self.delegate respondsToSelector:@selector(variantsManagerSearchRoomsDidReceiveDataFromGatesIds:)]) {
        [self.delegate variantsManagerSearchRoomsDidReceiveDataFromGatesIds:gateIds];
    }
}

- (void)searchLoaderFinishedWithRooms:(NSDictionary *)rooms searchId:(NSString *)searchId
{
    self.rooms = rooms;
    self.searchId = searchId;
    [self tryCollectingVariants];
}

- (void)searchLoaderFailedWithError:(NSError *)error
{
    [self collectingVariantsFailedWithError:error];
}

- (void)searchLoaderCancelled
{
    [self collectingVariantsCancelled];
}

@end
