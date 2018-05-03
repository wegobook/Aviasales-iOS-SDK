//
//  JRTicketUtils.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRTicketUtils.h"

@implementation JRTicketUtils

+ (NSString *)formattedTicketMinPriceInUserCurrency:(JRSDKTicket *)ticket {
    JRSDKProposal *const minProposal = [JRSDKModelUtils ticketMinimalPriceProposal:ticket];
    NSNumber *const minPriceValue = [minProposal.price priceInUserCurrency];
    return [AviasalesNumberUtil formatPrice:minPriceValue];
}

@end
