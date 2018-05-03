//
//  JRFlightsSegmentHeaderView.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFlightsSegmentHeaderView.h"
#import "DateUtil.h"

@interface JRFlightsSegmentHeaderView ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;

@end

@implementation JRFlightsSegmentHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
        
    [self updateContent];
}

#pragma mark Public methods

- (void)setFlightSegment:(JRSDKFlightSegment *)flightSegment {
    _flightSegment = flightSegment;
    
    [self updateContent];
}

#pragma mark Private methods

- (void)updateContent {

    if (self.flightSegment == nil) {
        return;
    }
    
    NSString *originFlightSegment = self.flightSegment.flights.firstObject.originAirport.city;
    NSString *destinationFlightSegment = self.flightSegment.flights.lastObject.destinationAirport.city;
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@ - %@", originFlightSegment, destinationFlightSegment];

    self.durationLabel.text = [DateUtil duration:self.flightSegment.totalDurationInMinutes durationStyle:JRDateUtilDurationShortStyle];
}

@end
