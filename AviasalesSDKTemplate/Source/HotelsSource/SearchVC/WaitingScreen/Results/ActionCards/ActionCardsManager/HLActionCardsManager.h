#import <Foundation/Foundation.h>

@class HLCollectionItem;
@class HLResultsCollectionVC;
@class HLActionCardItem;
@class ActionCardsConfiguration;
@class Filter;
@class HLDistanceFilterCardItem;
@class HLSearchTicketsItem;

@protocol HLActionCellDelegate <NSObject>
- (void)actionCardItemClosed:(HLCollectionItem *)item;
- (void)distanceItemClosed:(HLDistanceFilterCardItem *)item;
- (void)distanceItemApplied:(HLDistanceFilterCardItem *)item;
- (void)nearbyCitiesSearchItemApplied:(HLCollectionItem *)item;
- (void)filterUpdated:(Filter *)filter;
- (void)searchTickets;

@end

@interface HLActionCardsManager : NSObject

- (void)registerCardNibsForCollectionView:(UICollectionView *)UICollectionView;
- (void)excludeItemClass:(HLActionCardItem *)item;
- (BOOL)shouldAddItem:(HLActionCardItem *)item;
- (NSArray <HLCollectionItem *> *)addActionCardsTo:(NSArray <HLCollectionItem *> *)items
                                     configuration:(ActionCardsConfiguration *)configuration;
@end
