//
//  JRFilterTravelSegmentCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterTravelSegmentCell.h"

#import "JRFilterTravelSegmentItem.h"


@implementation JRFilterTravelSegmentCell

- (void)setItem:(JRFilterTravelSegmentItem *)item {
    _item = item;
    
    self.flightDirectionLabel.text = [item title];
    self.deparureDateLabel.text = [item detailsTitle];
}

@end
