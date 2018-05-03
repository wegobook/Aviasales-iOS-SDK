//
//  ASTSimpleSearchFormPresenter.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "JRDatePickerEnums.h"

@class ASTSimpleSearchFormCellViewModel;

@protocol ASTSimpleSearchFormViewControllerProtocol;

@interface ASTSimpleSearchFormPresenter : NSObject

- (instancetype)initWithViewController:(id <ASTSimpleSearchFormViewControllerProtocol>)viewController;
- (void)updateSearchInfoWithDestination:(JRSDKAirport *)destination checkIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut passengers:(ASTPassengersInfo *)passengers;

- (void)handleViewReady;
- (void)handleSelectCellViewModel:(ASTSimpleSearchFormCellViewModel *)cellViewModel;
- (void)handlePickPassengers;
- (void)handleSelectAirport:(JRSDKAirport *)selectedAirport withType:(ASAirportPickerType)type;
- (void)handleSelectDate:(NSDate *)selectedDate withMode:(JRDatePickerMode)mode;
- (void)handleSelectPassengersInfo:(ASTPassengersInfo *)selectedPassengersInfo;
- (void)handleSwapAirports;
- (void)handleSwitchReturnCheckbox;
- (void)handleSearch;

@end
