//
//  ASTSimpleSearchFormViewModel.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, ASTSimpleSearchFormCellViewModelType) {
    ASTSimpleSearchFormCellViewModelTypeOrigin,
    ASTSimpleSearchFormCellViewModelTypeDestination,
    ASTSimpleSearchFormCellViewModelTypeDeparture,
    ASTSimpleSearchFormCellViewModelTypeReturn,
};


@interface ASTSimpleSearchFormCellViewModel : NSObject

@property (nonatomic, assign) ASTSimpleSearchFormCellViewModelType type;

@end


@interface ASTSimpleSearchFormAirportCellViewModel : ASTSimpleSearchFormCellViewModel

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *iata;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *hint;
@property (nonatomic, assign) BOOL placeholder;

@end


@interface ASTSimpleSearchFormDateCellViewModel : ASTSimpleSearchFormCellViewModel

@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *hint;
@property (nonatomic, assign) BOOL placeholder;
@property (nonatomic, assign) BOOL shouldHideReturnCheckbox;
@property (nonatomic, assign) BOOL shouldSelectReturnCheckbox;

@end


@interface ASTSimpleSearchFormSectionViewModel : NSObject

@property (nonatomic, strong) NSArray <ASTSimpleSearchFormCellViewModel *> *cellViewModels;

@end


@interface ASTSimpleSearchFormPassengersViewModel : NSObject

@property (nonatomic, strong) NSString *adults;
@property (nonatomic, strong) NSString *children;
@property (nonatomic, strong) NSString *infants;
@property (nonatomic, strong) NSString *travelClass;

@end


@interface ASTSimpleSearchFormViewModel : NSObject

@property (nonatomic, strong) NSArray <ASTSimpleSearchFormSectionViewModel *> *sectionViewModels;
@property (nonatomic, strong) ASTSimpleSearchFormPassengersViewModel *passengersViewModel;

@end
