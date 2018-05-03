//
//  JRResultsTicketPriceCell.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@interface JRResultsTicketPriceCell : UITableViewCell

@property (strong, nonatomic) JRSDKPrice *price;
@property (strong, nonatomic) JRSDKAirline *airline;

+ (NSString *)nibFileName;
+ (CGFloat)height;

@end
