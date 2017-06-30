//
//  JRFilterTicketBounds.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>

@interface JRFilterTicketBounds : NSObject

@property (assign, nonatomic) BOOL mobileWebOnly;
@property (assign, nonatomic) BOOL filterMobileWebOnly;

@property (assign, nonatomic) CGFloat minPrice;    // In USD
@property (assign, nonatomic) CGFloat maxPrice;    // In USD
@property (assign, nonatomic) CGFloat filterPrice; // In USD

@property (strong, nonatomic) NSOrderedSet<JRSDKGate *> *gates;
@property (strong, nonatomic) NSOrderedSet<JRSDKGate *> *filterGates;

@property (strong, nonatomic) NSOrderedSet<JRSDKPaymentMethod *> *paymentMethods;
@property (strong, nonatomic) NSOrderedSet<JRSDKPaymentMethod *> *filterPaymentMethods;

@property (nonatomic, assign, readonly) BOOL isReset;

- (void)resetBounds;

@end
