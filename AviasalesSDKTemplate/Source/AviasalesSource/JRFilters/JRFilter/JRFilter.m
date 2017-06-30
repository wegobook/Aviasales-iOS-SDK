//
//  JRFilter.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilter.h"
#import "JRFilterTask.h"
#import "JRFilterBoundsBuilder.h"
#import "JRFilterTravelSegmentBounds.h"

#define kJRFilterLastTaskStartDelay 0.3


@interface JRFilter () <JRFilterTaskDelegate>

@property (nonatomic, strong) NSDate *lastTaskStartDate;

@end


@implementation JRFilter

- (instancetype)initWithTickets:(NSOrderedSet<JRSDKTicket *> *)tickets searchInfo:(JRSDKSearchInfo *)searchInfo {
    self = [super init];
    if (self) {
        _searchInfo = searchInfo;
        _searchResultsTickets = tickets;
        _filteredTickets = _searchResultsTickets;
        _lastTaskStartDate = [NSDate date];
        _travelSegmentsBounds = [NSMutableArray new];
        
        JRFilterBoundsBuilder *boundsBuilder = [[JRFilterBoundsBuilder alloc] initWithSearchResults:self.searchResultsTickets forSearchInfo:self.searchInfo];
        _ticketBounds = boundsBuilder.ticketBounds;
        _travelSegmentsBounds = boundsBuilder.travelSegmentsBounds;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(filterBoundsDidChange:)
                                                     name:kJRFilterBoundsDidChangeNotificationName
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public methds

- (BOOL)isAllBoundsReseted {
    
    if (!self.ticketBounds.isReset) {
        return NO;
    }
    
    for (JRFilterTravelSegmentBounds *bounds in self.travelSegmentsBounds) {
        if (!bounds.isReset) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)isTravelSegmentBoundsResetedForTravelSegment:(JRSDKTravelSegment *)travelSegment {
    JRFilterTravelSegmentBounds *travelSegmentBounds = [self travelSegmentBoundsForTravelSegment:travelSegment];
    
    return travelSegmentBounds.isReset;
}

- (JRFilterTravelSegmentBounds *)travelSegmentBoundsForTravelSegment:(JRSDKTravelSegment *)travelSegment {
    for (JRFilterTravelSegmentBounds *travelSegmentBounds in self.travelSegmentsBounds) {
        if ([travelSegmentBounds.travelSegment isEqual:travelSegment]) {
            return travelSegmentBounds;
        }
    }
    
    return nil;
}

- (JRSDKPrice *)minFilteredPrice {
    return self.filteredTickets.firstObject.proposals.firstObject.price;
}

- (void)resetFilterBoundsForTravelSegment:(JRSDKTravelSegment *)travelSegment {
    JRFilterTravelSegmentBounds *travelSegmentBounds = [self travelSegmentBoundsForTravelSegment:travelSegment];
    
    [travelSegmentBounds resetBounds];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kJRFilterBoundsDidResetNotificationName object:nil];
    });

    [self startNewFilteringTask];
}

- (void)resetAllBounds {
    NSMutableArray *boundsToReset = [self.travelSegmentsBounds mutableCopy];
    [boundsToReset addObject:self.ticketBounds];
    [self resetFilterBounds:boundsToReset];
}

- (void)resetFilterBounds:(NSArray *)boundsToReset {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [boundsToReset makeObjectsPerformSelector:@selector(resetBounds)];
#pragma clang diagnostic pop
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kJRFilterBoundsDidResetNotificationName object:nil];
    });
    
    [self startNewFilteringTask];
}

#pragma mark - Private methds

- (void)filterBoundsDidChange:(NSNotification *)notification {
    if (notification.object == self.ticketBounds || [self.travelSegmentsBounds containsObject:notification.object]) {
        NSTimeInterval timeIntervalSinceLastTaskStartDate = [[NSDate date] timeIntervalSinceDate:self.lastTaskStartDate];
        if (timeIntervalSinceLastTaskStartDate > kJRFilterLastTaskStartDelay) {
            [self startNewFilteringTask];
        } else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startNewFilteringTask) object:nil];
            [self performSelector:@selector(startNewFilteringTask) withObject:nil afterDelay:kJRFilterLastTaskStartDelay];
        }
    }
}

- (void)startNewFilteringTask {
    _lastTaskStartDate = [NSDate date];
    _filteringTask = nil;
    _filteringTask = [JRFilterTask filterTaskForTickets:self.searchResultsTickets
                                           ticketBounds:self.ticketBounds
                                    travelSegmentBounds:self.travelSegmentsBounds
                                           taskDelegate:self];
    
    __weak typeof(self.filteringTask) weakTask = self.filteringTask;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [weakTask performFiltering];
    });
}

#pragma mark - JRFilterTaskDelegate methds

- (void)filterTaskDidFinishWithTickets:(NSOrderedSet<JRSDKTicket *> *)filteredTickets {
    _filteredTickets = filteredTickets;
    
    __weak typeof(self) weakSelf = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kJRFilterMinPriceDidUpdateNotificationName object:self];
        
        [weakSelf.delegate filterDidUpdateFilteredObjects];
    });
}

@end
