//
//  JRFilterCheckBoxItem.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterCheckBoxItem.h"
#import "DateUtil.h"


@implementation JRFilterCheckBoxItem

- (NSString *)title {
    return @"";
}

- (NSAttributedString *)attributedStringValue {
    return [[NSAttributedString alloc] initWithString:@""];
}

@end



@implementation JRFilterStopoverItem {
    NSInteger _stopoverCount;
    CGFloat _minPrice;
}

- (instancetype)initWithStopoverCount:(NSInteger)stopoverCount minPrice:(CGFloat)minPrice {
    self = [super init];
    if (self) {
        _stopoverCount = stopoverCount;
        _minPrice = minPrice;
    }
    
    return self;
}

- (NSString *)title {
    if (_stopoverCount == 0) {
        return NSLS(@"JR_SEARCH_RESULTS_TRANSFERS##{zero}");
    }
    
    NSString *format = NSLSP(@"JR_SEARCH_RESULTS_TRANSFERS", _stopoverCount);
    return [NSString stringWithFormat:format, _stopoverCount];
}

- (NSAttributedString *)attributedStringValue {
    JRSDKPrice *price = [JRSDKPrice priceWithCurrency:USD_CURRENCY value:_minPrice];
    NSString *priceString = [price formattedPriceinUserCurrency];
    NSString *text = [NSString stringWithFormat:@"%@ %@", NSLS(@"JR_FILTER_TOTAL_DURATION_FROM"), priceString];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    
    return attributedText;
}

@end


@implementation JRFilterGateItem {
    JRSDKGate *_gate;
}

- (instancetype)initWithGate:(JRSDKGate *)gate {
    self = [super init];
    if (self) {
        _gate = gate;
    }
    
    return self;
}

- (NSString *)title {
    return _gate.label;
}

@end


@implementation JRFilterPaymentMethodItem {
    JRSDKPaymentMethod *_paymentMethod;
}

- (instancetype)initWithPaymentMethod:(JRSDKPaymentMethod *)paymentMethod {
    self = [super init];
    if (self) {
        _paymentMethod = paymentMethod;
    }
    
    return self;
}

- (NSString *)title {
    return _paymentMethod.localizedName;
}

@end


@implementation JRFilterAirlineItem  {
    JRSDKAirline *_airline;
}

- (instancetype)initWithAirline:(JRSDKAirline *)airline {
    self = [super init];
    if (self) {
        _airline = airline;
    }
    
    return self;
}

- (NSString *)title {
    return _airline.name;
}

@end


@implementation JRFilterAllianceItem {
    JRSDKAlliance *_alliance;
}

- (instancetype)initWithAlliance:(JRSDKAlliance *)alliance {
    self = [super init];
    if (self) {
        _alliance = alliance;
    }
    
    return self;
}

- (NSString *)title {
    return [_alliance.name isEqualToString:JR_OTHER_ALLIANCES] ? NSLS(@"JR_FILTER_OTHER_ALLIANCES") : _alliance.name;
}

@end


@implementation JRFilterAirportItem {
    JRSDKAirport *_airport;
}

- (instancetype)initWithAirport:(JRSDKAirport *)airport {
    self = [super init];
    if (self) {
        _airport = airport;
    }
    
    return self;
}

- (NSString *)title {
    return _airport.airportName;
}

@end
