#import "HLActionCardsManager.h"
#import "NSArray+Functional.h"

NSInteger const kMaxVariantsToShowNearbyCitiesSearchCard = 25;

@interface HLActionCardsManager()

@property (nonatomic, strong) NSMutableArray *excludedCardClasses;
@property (nonatomic, strong) HLDistanceFilterCardItem *distanceItem;
@property (nonatomic, strong) HLPriceFilterCardItem *priceItem;

@end

@implementation HLActionCardsManager

- (id)init
{
    self = [super init];
    if (self) {
        self.excludedCardClasses = [NSMutableArray new];
    }
    return self;
}

- (void)registerCardNibsForCollectionView:(UICollectionView *)collectionView
{
    [collectionView hl_registerNibWithName:[HLDistanceFilterCardCell hl_reuseIdentifier]];
    [collectionView hl_registerNibWithName:[HLPriceFilterCardCell hl_reuseIdentifier]];
    [collectionView hl_registerNibWithName:[HLRatingCardCell hl_reuseIdentifier]];
    [collectionView hl_registerNibWithName:[HLPlaceholderCell hl_reuseIdentifier]];
    [collectionView hl_registerNibWithName:[HLNearbyCitiesSearchCardCell hl_reuseIdentifier]];
    [collectionView hl_registerNibWithName:[HLSearchTicketsCardCell hl_reuseIdentifier]];
}

- (NSArray <HLCollectionItem *> *)addActionCardsTo:(NSArray <HLCollectionItem *> *)items
                                     configuration:(ActionCardsConfiguration *)configuration
{
    NSArray *result = items;

    result = [self itemsByAddingFilterCard:result configuration:configuration];
    result = [self itemsByAddingSearchTicketsCard:result configuration:configuration];
    result = [self itemsByAddingPlaceholderCard:result configuration:configuration];
    result = [self itemsByAddingNearbyCitiesSearchCard:result configuration:configuration];

    return result;
}

- (NSArray <HLCollectionItem *> *)itemsByAddingFilterCard:(NSArray <HLCollectionItem *> *)items
                                            configuration:(ActionCardsConfiguration *)config
{
    NSArray *result = items;

    if (!iPhone()) {
        return result;
    }

    switch (config.searchInfo.searchInfoType) {
        case HLSearchInfoTypeCityCenterLocation:
        case HLSearchInfoTypeCustomLocation:
        case HLSearchInfoTypeUserLocation:
        case HLSearchInfoTypeAirport: {
            HLDistanceFilterCardItem *distanceItem = [self createDistanceItemWithTopItem:YES configuration:config];
            if ([self shouldAddItem:distanceItem]) {
                result = [HLActionCardsArrayHelper addItem:distanceItem toArray:result atIndex:0 minVariantsCount:0];
            }
        } break;

        case HLSearchInfoTypeCity: {
            switch (config.filter.sortType) {
                case SortTypePrice: {
                    result = [self itemsByAddingRatingFilterItem:items configuration:config];
                } break;

                default: {
                    self.priceItem = [self createPriceItemWithConfiguration:config];
                    if ([self shouldAddPriceItem:self.priceItem filter:config.filter]) {
                        result = [HLActionCardsArrayHelper addItem:self.priceItem toArray:result atIndex:0 minVariantsCount:0];
                    }
                } break;
            }
            HLDistanceFilterCardItem *distanceItem = [self createDistanceItemWithTopItem:NO configuration:config];
            if ([self shouldAddItem:distanceItem]) {
                result = [HLActionCardsArrayHelper addItem:distanceItem toArray:result atIndex:5 minVariantsCount:10];
            }
        } break;

        default:
            break;
    }

    return result;
}

- (BOOL)shouldAddSearchTicketsCardWith:(ActionCardsConfiguration *)config
{
    if (iPad()) {
        return NO;
    }
    
    if (![ConfigManager shared].flightsEnabled) {
        return NO;
    }
    
    HLSearchInfoType type = config.searchInfo.searchInfoType;
    if (type == HLSearchInfoTypeCustomLocation || type == HLSearchInfoTypeUserLocation) {
        return NO;
    }
    
    return YES;
}

- (NSArray <HLCollectionItem *> *)itemsByAddingSearchTicketsCard:(NSArray <HLCollectionItem *> *)items
                                                   configuration:(ActionCardsConfiguration *)config
{
    if (![self shouldAddSearchTicketsCardWith:config]) {
        return items;
    }
    HLSearchTicketsCardItem *item = [[HLSearchTicketsCardItem alloc] initWithTopItem:NO
                                                                 cellReuseIdentifier:[HLSearchTicketsCardCell hl_reuseIdentifier]
                                                                              filter:config.filter
                                                                            delegate:config.delegate];

    if ([self shouldAddItem:item]) {
        return [HLActionCardsArrayHelper addItem:item toArray:items atIndex:1 minVariantsCount:0 canAppend:NO];
    }
    
    return items;
}

- (NSArray <HLCollectionItem *> *)itemsByAddingRatingFilterItem:(NSArray <HLCollectionItem *> *)items
                                                  configuration:(ActionCardsConfiguration *)config
{
    NSArray *result = items;
    HLRatingFilterCardItem *ratingItem = [[HLRatingFilterCardItem alloc] initWithTopItem:YES
                                                                     cellReuseIdentifier:[HLRatingCardCell hl_reuseIdentifier]
                                                                                  filter:config.filter
                                                                                delegate:config.delegate];
    if ([self shouldAddItem:ratingItem]) {
        result = [HLActionCardsArrayHelper addItem:ratingItem toArray:result atIndex:0 minVariantsCount:0];
    }

    return result;
}

- (NSArray <HLCollectionItem *> *)itemsByAddingPlaceholderCard:(NSArray <HLCollectionItem *> *)items
                                                 configuration:(ActionCardsConfiguration *)config
{
    if (!iPhone() || items.count > 0) {
        return items;
    }
    HLPlaceholderCardItem *placeholderItem = [[HLPlaceholderCardItem alloc] initWithTopItem:NO
                                                                        cellReuseIdentifier:[HLPlaceholderCell hl_reuseIdentifier]
                                                                                     filter:config.filter
                                                                                   delegate:config.delegate];
    return [HLActionCardsArrayHelper addItem:placeholderItem toArray:items atIndex:0 minVariantsCount:0];
}

- (NSArray <HLCollectionItem *> *)itemsByAddingNearbyCitiesSearchCard:(NSArray <HLCollectionItem *> *)items
                                                        configuration:(ActionCardsConfiguration *)config
{
    NSInteger indexToInsertNearbyCitiesSearchItem = [self indexToInsertNearbyCitiesSearchItemToArray:items configuration:config];
    if (indexToInsertNearbyCitiesSearchItem != NSNotFound) {
        HLNearbyCitiesSearchCardItem *item = [[HLNearbyCitiesSearchCardItem alloc] initWithTopItem:NO
                                                                               cellReuseIdentifier:[HLNearbyCitiesSearchCardCell hl_reuseIdentifier]
                                                                                            filter:config.filter
                                                                                          delegate:config.delegate];
        NSMutableArray *mutableResult = items.mutableCopy;
        [mutableResult insertObject:item atIndex:indexToInsertNearbyCitiesSearchItem];

        return mutableResult.copy;
    } else {
        return items;
    }
}

#pragma mark - Private

- (void)excludeItemClass:(HLActionCardItem *)item;
{
    [self.excludedCardClasses addObject:item.class];
}

- (NSInteger)indexToInsertNearbyCitiesSearchItemToArray:(NSArray <HLCollectionItem *> *)items
                                          configuration:(ActionCardsConfiguration *)config
{
    NSIndexSet *originalRoomsWithPrices = [config.filter.searchResult.variants indexesOfObjectsPassingTest:^BOOL(HLResultVariant * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.rooms atLeastOneConfirms:^BOOL(HDKRoom *room) {
            return room.price > 0;
        }];
    }];

    if (config.searchInfo.searchInfoType != HLSearchInfoTypeCity ||
        originalRoomsWithPrices.count > kMaxVariantsToShowNearbyCitiesSearchCard ||
        config.filter.searchResult.nearbyCities.count <= 1) {

        return NSNotFound;
    }

    NSInteger lastPriceVariantOrTopCardIndex = [items lastIndexOfObjectPassingTest:^BOOL(id item, NSInteger index) {
        if ([item isKindOfClass:[HLActionCardItem class]]) {
            return ((HLActionCardItem *)item).topItem;
        }

        HDKRoom *roomWithPrice = ((HLVariantItem *)item).variant.roomWithMinPrice;
        return roomWithPrice != nil;
    }];

    return lastPriceVariantOrTopCardIndex != NSNotFound ? (lastPriceVariantOrTopCardIndex + 1) : 0;
}

- (HLDistanceFilterCardItem *)createDistanceItemWithTopItem:(BOOL)topItem
                                              configuration:(ActionCardsConfiguration *)config
{
    if (!self.distanceItem) {
        self.distanceItem = [[HLDistanceFilterCardItem alloc] initWithTopItem:topItem
                                                          cellReuseIdentifier:[HLDistanceFilterCardCell hl_reuseIdentifier]
                                                                       filter:config.filter
                                                                     delegate:config.delegate
                                                                   searchInfo:config.searchInfo];
    } else {
        [self.distanceItem update:config.filter];
    }

    return self.distanceItem;
}

- (HLPriceFilterCardItem *)createPriceItemWithConfiguration:(ActionCardsConfiguration *)config
{
    if (!self.priceItem) {
        self.priceItem = [[HLPriceFilterCardItem alloc] initWithTopItem:YES
                                                    cellReuseIdentifier:[HLPriceFilterCardCell hl_reuseIdentifier]
                                                                 filter:config.filter
                                                               delegate:config.delegate
                                                               currency:config.searchInfo.currency];
    }

    return self.priceItem;
}

- (BOOL)shouldAddPriceItem:(HLPriceFilterCardItem *)item filter:(Filter *)filter
{
    return [self shouldAddItem:item] && ![filter allVariantsHaveSamePrice] && filter.searchResult.variants.count >= 3;
}

- (BOOL)shouldAddItem:(HLActionCardItem *)item
{
    return ![self.excludedCardClasses containsObject:item.class];
}

@end
