//
//  ASTComplexSearchFormViewModel.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>


@interface ASTComplexSearchFormCellSegmentViewModel : NSObject

@property (nonatomic, assign) BOOL placeholder;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

@end


@interface ASTComplexSearchFormCellViewModel : NSObject

@property (nonatomic, strong) ASTComplexSearchFormCellSegmentViewModel *origin;
@property (nonatomic, strong) ASTComplexSearchFormCellSegmentViewModel *destination;
@property (nonatomic, strong) ASTComplexSearchFormCellSegmentViewModel *departure;

@end


@interface ASTComplexSearchFormFooterViewModel : NSObject

@property (nonatomic, assign) BOOL shouldEnableAdd;
@property (nonatomic, assign) BOOL shouldEnableRemove;

@end


@interface ASTComplexSearchFormPassengersViewModel : NSObject

@property (nonatomic, strong) NSString *adults;
@property (nonatomic, strong) NSString *children;
@property (nonatomic, strong) NSString *infants;
@property (nonatomic, strong) NSString *travelClass;

@end


@interface ASTComplexSearchFormViewModel : NSObject

@property (nonatomic, strong) NSArray <ASTComplexSearchFormCellViewModel *> *cellViewModels;
@property (nonatomic, strong) ASTComplexSearchFormFooterViewModel *footerViewModel;
@property (nonatomic, strong) ASTComplexSearchFormPassengersViewModel *passengersViewModel;

@end
