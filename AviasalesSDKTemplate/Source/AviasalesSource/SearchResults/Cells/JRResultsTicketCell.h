//
//  JRResultsTicketCell.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@class JRSearchResultsFlightSegmentCellLayoutParameters;

@interface JRResultsTicketCell : UITableViewCell

@property (strong, nonatomic) JRSDKTicket *ticket;
@property (strong, nonatomic) JRSearchResultsFlightSegmentCellLayoutParameters *flightSegmentsLayoutParameters;

+ (NSString *)nibFileName;
+ (CGFloat)heightWithTicket:(JRSDKTicket *)ticket;

@end
