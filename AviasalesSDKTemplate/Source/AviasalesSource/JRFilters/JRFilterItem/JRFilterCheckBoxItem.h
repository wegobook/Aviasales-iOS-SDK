//
//  JRFilterCheckBoxItem.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterItemProtocol.h"


@interface JRFilterCheckBoxItem : NSObject <JRFilterItemProtocol>

@property (nonatomic, copy) void (^filterAction)();

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign, readonly) BOOL showAverageRate;
@property (nonatomic, assign, readonly) NSInteger rating;

@end


@interface JRFilterStopoverItem : JRFilterCheckBoxItem

- (instancetype)initWithStopoverCount:(NSInteger)stopoverCount minPrice:(CGFloat)minPrice;

@end


@interface JRFilterGateItem : JRFilterCheckBoxItem

- (instancetype)initWithGate:(JRSDKGate *)gate;

@end


@interface JRFilterPaymentMethodItem : JRFilterCheckBoxItem

- (instancetype)initWithPaymentMethod:(JRSDKPaymentMethod *)paymentMethod;

@end


@interface JRFilterAirlineItem : JRFilterCheckBoxItem

- (instancetype)initWithAirline:(JRSDKAirline *)airline;

@end


@interface JRFilterAllianceItem : JRFilterCheckBoxItem

- (instancetype)initWithAlliance:(JRSDKAlliance *)alliance;

@end


@interface JRFilterAirportItem : JRFilterCheckBoxItem

- (instancetype)initWithAirport:(JRSDKAirport *)airport;

@end



