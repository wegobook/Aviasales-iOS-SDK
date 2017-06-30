//
//  NSError+HLCustomErrors.h
//  HotelLook
//
//  Created by Anton Chebotov on 06/02/14.
//  Copyright (c) 2014 Anton Chebotov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HLErrorCode) {
	HLServerUnavailableError = 10000,
    HLNoSearchInfoError,
    HLNoNearbyCitiesError,
    HLSearchMaxDurationExceed,
	HLManagedCityDetectionFailed,
	HLHotelsContentLoadingWithEmptyParamsError,
    HLHotelDetailsLoadingEmptyHotelIdError,
    HLHotelDetailsLoadingEmptyCityIdError,
    HLHotelsContentLoadinNoContentError,
    HLRoomsLoaderNoContentError,
    HLNoContentInCitiesAutocompletionError,
    HLWrongResponseJSONFormatError,
	HLWrongDeeplinkResponseFormateError,
    HLWrongHotelDetailsResponseFormateError,
    HLEmptyAutocompleteNonCriticalError,
    HLDatePickerLimitNonCriticalError,
    HLEmptyResultsNonCriticalError,
    HLOutdatedResultsNonCriticalError,
    HLToughFiltersNonCriticalError,
    HLNoMinPriceNonCriticalError,
    HLInvalidArgument,
    HLMigrationError
};

@interface NSError (HLCustomErrors)

+ (NSError *)errorWithCode:(HLErrorCode)code;
+ (NSError *)errorServerWithCode:(HLErrorCode)code;
+ (NSError *)errorURLResponseWithCode:(HLErrorCode)code;
+ (NSError *)errorNonCriticalWithCode:(HLErrorCode)code;
+ (NSError *)errorMigrationWithCode:(HLErrorCode)code description:(NSString *)description;

+ (NSString *)hlErrorDomain;
+ (NSString *)hlServerErrorDomain;
+ (NSString *)hlNetworkErrorDomain;
+ (NSString *)hlMigrationErrorDomain;
+ (NSString *)hlURLResponseErrorDomain;
+ (NSString *)hlNonCriticalErrorDomain;

@end
