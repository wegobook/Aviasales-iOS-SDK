//
//  JRFilter.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterTask.h"

#define kJRFilterBoundsDidChangeNotificationName    @"kJRFilterBoundsDidChangeNotificationName"
#define kJRFilterBoundsDidResetNotificationName     @"kJRFilterBoundsDidResetNotificationName"
#define kJRFilterMinPriceDidUpdateNotificationName  @"kJRFilterMinPriceDidUpdateNotificationName"


@class JRFilterTravelSegmentBounds;
@class JRFilterTicketBounds;

@protocol JRFilterDelegate<NSObject>

@required
- (void)filterDidUpdateFilteredObjects;

@end


@interface JRFilter : NSObject

@property (nonatomic, strong, readonly) JRFilterTicketBounds *ticketBounds;
@property (nonatomic, strong, readonly) NSArray<JRFilterTravelSegmentBounds *> *travelSegmentsBounds;

@property (nonatomic, strong, readonly) NSOrderedSet<JRSDKTicket *> *searchResultsTickets;
@property (nonatomic, strong, readonly) NSOrderedSet<JRSDKTicket *> *filteredTickets;

@property (nonatomic, strong, readonly) JRSDKPrice *minFilteredPrice;
@property (nonatomic, strong, readonly) JRSDKSearchInfo *searchInfo;
@property (nonatomic, strong, readonly) JRFilterTask *filteringTask;

@property (nonatomic, assign, readonly) BOOL isAllBoundsReseted;

@property (nonatomic, weak) id <JRFilterDelegate> delegate;

- (instancetype)initWithTickets:(NSOrderedSet<JRSDKTicket *> *)tickets searchInfo:(JRSDKSearchInfo *)searchInfo;

- (void)resetAllBounds;
- (void)resetFilterBoundsForTravelSegment:(JRSDKTravelSegment *)travelSegment;
- (JRFilterTravelSegmentBounds *)travelSegmentBoundsForTravelSegment:(JRSDKTravelSegment *)travelSegment;
- (BOOL)isTravelSegmentBoundsResetedForTravelSegment:(JRSDKTravelSegment *)travelSegment;

@end
