//
//  ASTComplexSearchFormPresenter.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "JRDatePickerEnums.h"

typedef NS_ENUM(NSInteger, ASTComplexSearchFormCellSegmentType) {
    ASTComplexSearchFormCellSegmentTypeOrigin,
    ASTComplexSearchFormCellSegmentTypeDestination,
    ASTComplexSearchFormCellSegmentTypeDeparture
};

@protocol ASTComplexSearchFormViewControllerProtocol;

@interface ASTComplexSearchFormPresenter : NSObject

- (instancetype)initWithViewController:(id <ASTComplexSearchFormViewControllerProtocol>)viewController;

- (void)handleViewDidLoad;
- (void)handleSelectCellSegmentWithType:(ASTComplexSearchFormCellSegmentType)type atIndex:(NSInteger)index;
- (void)handleAddTravelSegment;
- (void)handleRemoveTravelSegment;
- (void)handlePickPassengers;
- (void)handleSelectAirport:(JRSDKAirport *)selectedAirport withType:(ASAirportPickerType)type atIndex:(NSInteger)index;
- (void)handleSelectDate:(NSDate *)selectedDate atIndex:(NSInteger)index;
- (void)handleSelectPassengersInfo:(ASTPassengersInfo *)selectedPassengersInfo;
- (void)handleSearch;

@end
