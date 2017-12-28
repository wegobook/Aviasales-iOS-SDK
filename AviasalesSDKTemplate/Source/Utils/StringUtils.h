#import <Foundation/Foundation.h>

@class HDKCity;
@class HDKCurrency;
@class HLResultVariant;
@class HLReview;
@class HLSearchInfo;
@class HDKLocationPoint;
@class HDKSearchLocationPoint;
@class HDKHotel;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kHotelWebsiteString;

@interface StringUtils : NSObject

+ (NSString *)destinationStringBySearchInfo:(HLSearchInfo *)searchInfo;
+ (NSString *)searchDestinationDescriptionStringBySearchInfo:(HLSearchInfo *)searchInfo;

+ (NSString *)datesDescriptionWithCheckIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut;
+ (NSString *)ipadDatesDescriptionWithCheckIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut;
+ (NSString *)intervalDescriptionWithDate:(NSDate *)start andDate:(NSDate *)finish;

+ (NSString *)shortCheckInDateAndTime:(NSDate *)time;
+ (NSString *)shortCheckInDateAndTime:(NSDate *)time locale:(NSLocale *)locale;

+ (NSString *)shortCheckOutDateAndTime:(NSDate *)time;
+ (NSString *)shortCheckOutDateAndTime:(NSDate *)time locale:(NSLocale *)locale;

+ (NSString *)longCheckInDateAndTime:(NSDate *)time;
+ (NSString *)longCheckInDateAndTime:(NSDate *)time locale:(NSLocale *)locale;

+ (NSString *)longCheckOutDateAndTime:(NSDate *)time;
+ (NSString *)longCheckOutDateAndTime:(NSDate *)time locale:(NSLocale *)locale;

+ (NSString *)guestsDescriptionWithAdultsCount:(NSInteger)adultsCount kidsCount:(NSInteger)kidsCount;

+ (NSString *)kidAgeTextWithAge:(NSInteger)age;

+ (NSString *)durationDescriptionWithDays:(NSInteger)days;
+ (NSString *)userSettingsDurationWithPrefixWithDays:(NSInteger)days;
+ (nullable NSString *)searchInfoStringBySearchInfo:(nullable HLSearchInfo *)searchInfo;

+ (nullable NSString *)cityFullName:(nullable HDKCity *)city;
+ (nullable NSString *)cityName:(nullable HDKCity *)city;
+ (NSString *)cityNameWithStateAndCountry:(nullable HDKCity *)city;

+ (NSString *)searchInfoDescription:(HLSearchInfo *)searchInfo;

+ (NSAttributedString *)attributedRangeValueTextWithPercentFormatForMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue;

+ (NSAttributedString *)strikethroughAttributedString:(NSAttributedString *)attributedString;

+ (NSString *)discountStringForDiscount:(NSInteger)discount;

+ (NSString *)roomsAvailableStringWithCount:(NSInteger)count;

+ (NSString *)hotelsCountDescriptionWithHotels:(NSInteger)count;
+ (NSString *)filteredHotelsDescriptionWithFiltered:(NSInteger)filtered total:(NSInteger)total;

+ (NSString *)photoCounterString:(NSInteger)count totalCount:(NSInteger)totalCount;

+ (NSString *)shortRatingString:(NSInteger)rating;
+ (NSString *)shortRatingString:(NSInteger)rating locale:(NSLocale *)locale;

#pragma mark - Price Formatting
+ (NSString *)priceStringWithVariant:(HLResultVariant *)variant;
+ (NSString *)priceStringWithPrice:(float)price currency:(HDKCurrency *)currency;
+ (NSString *)formattedNumberStringWithNumber:(NSInteger)number;
+ (NSAttributedString *)attributedPriceStringWithVariant:(HLResultVariant *)variant currency:(HDKCurrency *)currency font:(UIFont *)font;
+ (NSAttributedString *)attributedPriceStringWithVariant:(HLResultVariant *)variant currency:(HDKCurrency *)currency font:(UIFont *)font noPriceColor:(UIColor * _Nullable)color;
+ (NSAttributedString *)attributedPriceStringWithPrice:(float)price currency:(HDKCurrency *)currency font:(UIFont *)font;

#pragma mark - URL handling
+ (NSDictionary *)paramsFromUrlAbsoluteString:(NSString *)urlString;
+ (NSDictionary *)paramsFromAppsFlyerString:(NSString *)appsFlyerString;

#pragma mark - Distance formatting
+ (NSAttributedString *)attributedDistanceString:(CGFloat)meters;
+ (NSAttributedString *)attributedDistanceString:(CGFloat)meters
                                       textColor:(UIColor *)textColor
                                     numberColor:(UIColor *)numberColor;
+ (NSString *)roundedDistanceWithMeters:(CGFloat)meters;

#pragma mark - Points Name formatting
+ (NSString *)locationPointName:(nullable HDKLocationPoint *)point;

+ (NSString *)guestsDescriptionWithGuestsCount:(NSInteger)count;
+ (NSString *)adultGuestsDescriptionWithCount:(NSInteger)adultsCount;
+ (NSString *)childGuestsDescriptionWithCount:(NSInteger)kidsCount;

NS_ASSUME_NONNULL_END

#pragma mark - Hotels

+ (nonnull NSString *)hotelAddressForHotel:(nullable HDKHotel *)hotel;
+ (nullable NSString *)hotelAddressDetails:(nullable HDKHotel *)hotel;

+ (nonnull NSString *)checkInTimeFromDate:(nonnull NSDate *)date;
+ (nonnull NSString *)checkOutTimeFromDate:(nonnull NSDate *)date;

+ (nonnull NSString *)accommodationSummaryCheckInStringForDate:(nonnull NSDate *)date shortMonth:(BOOL)shortMonth;
+ (nonnull NSString *)accommodationSummaryCheckOutStringForDate:(nonnull NSDate *)date shortMonth:(BOOL)shortMonth;

@end
