//
//  JRFilterTask.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterTask.h"
#import "JRFilterTicketBounds.h"
#import "JRFilterTravelSegmentBounds.h"
#import "DateUtil.h"


@interface JRFilterTask ()

@property (weak, nonatomic) JRFilterTicketBounds *ticketBounds;
@property (weak, nonatomic) NSArray *travelSegmentBounds;
@property (weak, nonatomic) id<JRFilterTaskDelegate> delegate;
@property (weak, nonatomic) NSOrderedSet<JRSDKTicket *> *ticketsToFilter;

@end

@interface NSOrderedSet (JRSDKGate)

- (BOOL)hasMainGate:(JRSDKGate *)gate;

@end


@implementation JRFilterTask

+ (instancetype)filterTaskForTickets:(NSOrderedSet<JRSDKTicket *> *)ticketsToFilter
                        ticketBounds:(JRFilterTicketBounds *)ticketBounds
                 travelSegmentBounds:(NSArray *)travelSegmentBounds
                        taskDelegate:(id<JRFilterTaskDelegate>)delegate {
    return [[JRFilterTask alloc] initFilterTaskForTickets:ticketsToFilter
                                             ticketBounds:ticketBounds
                                      travelSegmentBounds:travelSegmentBounds
                                             taskDelegate:delegate];
}

- (instancetype)initFilterTaskForTickets:(NSOrderedSet<JRSDKTicket *> *)ticketsToFilter
                            ticketBounds:(JRFilterTicketBounds *)ticketBounds
                     travelSegmentBounds:(NSArray *)travelSegmentBounds
                            taskDelegate:(id<JRFilterTaskDelegate>)delegate {
    self = [super init];
    if (self) {
        _ticketBounds = ticketBounds;
        _ticketsToFilter = ticketsToFilter;
        _travelSegmentBounds = travelSegmentBounds;
        _delegate = delegate;
    }
    return self;
}

- (void)performFiltering {
    NSMutableOrderedSet<JRSDKTicket *> *filteredTickets = [NSMutableOrderedSet orderedSet];
    
    for (JRSDKTicket *ticket in self.ticketsToFilter) {
        NSMutableOrderedSet<JRSDKProposal *> *filteredProposals = [ticket.proposals mutableCopy];
        JRSDKTicket *filteredTicket = [ticket copy];
        
        for (JRSDKProposal *proposal in ticket.proposals) {
            CGFloat priceValue = [proposal.price priceInUSD].floatValue;
            
            if (priceValue > self.ticketBounds.filterPrice) {
                [filteredProposals removeObject:proposal];
            } else if (![self.ticketBounds.filterGates hasMainGate:proposal.gate]) {
                [filteredProposals removeObject:proposal];
            } else if (![proposal.gate.paymentMethods intersectsSet:self.ticketBounds.filterPaymentMethods.set]) {
                [filteredProposals removeObject:proposal];
            }
        }
        
        if (filteredProposals.count > 0) {
            if (![self needRemoveTicketAfterTravelSegmentBoundsWereApplied:ticket]) {
                filteredTicket.proposals = filteredProposals;
                [filteredTickets addObject:filteredTicket];
            }
        }
    }
    
    [self.delegate filterTaskDidFinishWithTickets:filteredTickets];
}

- (BOOL)needRemoveTicketAfterTravelSegmentBoundsWereApplied:(JRSDKTicket *)ticket {
    BOOL needRemove = NO;
    
    for (JRFilterTravelSegmentBounds *travelSegmentBounds in self.travelSegmentBounds) {
        NSInteger indexOfTravelSegment = [self.travelSegmentBounds indexOfObject:travelSegmentBounds];
        JRSDKFlightSegment *flightSegment = [ticket.flightSegments objectAtIndex:indexOfTravelSegment];
        
        if (travelSegmentBounds.filterTotalDuration < flightSegment.totalDurationInMinutes) {
            needRemove = YES;
            break;
        }
        
        if (travelSegmentBounds.minFilterDelaysDuration > flightSegment.delayDurationInMinutes || travelSegmentBounds.maxFilterDelaysDuration < flightSegment.delayDurationInMinutes) {
            needRemove = YES;
            break;
        }
        
        if (travelSegmentBounds.minFilterDepartureTime > flightSegment.departureDateTimestamp.doubleValue || travelSegmentBounds.maxFilterDepartureTime < flightSegment.departureDateTimestamp.doubleValue) {
            needRemove = YES;
            break;
        }
        
        if (travelSegmentBounds.minFilterArrivalTime > flightSegment.arrivalDateTimestamp.doubleValue || travelSegmentBounds.maxFilterArrivalTime < flightSegment.arrivalDateTimestamp.doubleValue) {
            needRemove = YES;
            break;
        }
        
        if (flightSegment.flights.count > 0) {
            if (![travelSegmentBounds.filterTransfersCounts containsObject:@(flightSegment.flights.count - 1)]) {
                needRemove = YES;
                break;
            }
        }
        
        NSSet<JRSDKAirline *> *flightSegmentAirlines = [flightSegment.flights valueForKeyPath:@"airline"];
        if (![flightSegmentAirlines isSubsetOfSet:travelSegmentBounds.filterAirlines.set]) {
            needRemove = YES;
            break;
        }
        
        NSSet<JRSDKAlliance *> *flightSegmentAlliances = [flightSegment.flights valueForKeyPath:@"airline.alliance"];
        if (![flightSegmentAlliances isSubsetOfSet:travelSegmentBounds.filterAlliances.set]) {
            needRemove = YES;
            break;
        }
        
        JRSDKAirport *originAirport = flightSegment.flights.firstObject.originAirport;
        if (![travelSegmentBounds.filterOriginAirports containsObject:originAirport]) {
            needRemove = YES;
            break;
        }
        
        JRSDKAirport *destinationAirport = flightSegment.flights.lastObject.destinationAirport;
        if (![travelSegmentBounds.filterDestinationAirports containsObject:destinationAirport]) {
            needRemove = YES;
            break;
        }
        
        if (flightSegment.flights.count > 1) {
            NSMutableSet<JRSDKAirport *> *stopoverAirports = [NSMutableSet set];
            for (JRSDKFlight *flight in flightSegment.flights) {
                for (JRSDKAirport *airport in @[flight.originAirport, flight.destinationAirport]) {
                    if (![airport isEqual:originAirport] && ![airport isEqual:destinationAirport]) {
                        [stopoverAirports addObject:airport];
                    }
                }
            }
            
            if (![stopoverAirports isSubsetOfSet:travelSegmentBounds.filterStopoverAirports.set]) {
                needRemove = YES;
                break;
            }
        }
    }
    
    return needRemove;
}

@end

@implementation NSOrderedSet (JRSDKGate)

- (BOOL)hasMainGate:(JRSDKGate *)gate {
    return [self indexOfObjectPassingTest:^BOOL(JRSDKGate * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.mainGateID isEqualToString:gate.mainGateID];
    }] != NSNotFound;
}

@end
