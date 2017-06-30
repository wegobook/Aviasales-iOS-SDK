//
//  JRAirportPickerVC.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRViewController.h"
#import "JRAirportPickerEnums.h"

@interface JRAirportPickerVC : JRViewController

- (instancetype)initWithMode:(JRAirportPickerMode)mode selectionBlock:(void (^)(JRSDKAirport *))selectionBlock;

@end
