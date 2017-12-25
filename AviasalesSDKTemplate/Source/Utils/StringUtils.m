#import "StringUtils.h"
#import <HotellookSDK/HotellookSDK.h>
#import "DateUtil.h"
#import "NSString+HLCapitalization.h"

NSString * const kAppsFlyerLocationIdKey = @"locationId";
NSString * const kAppsFlyerIataIdKey = @"destination";
NSString * const kAppsFlyerHolelIdKey = @"hotelId";
NSString * const kAppsFlyerHotelKey = @"H";
NSString * const kAppsFlyerIataKey = @"I";
NSString * const kAppsFlyerLocationKey = @"L";
NSString * const kAppsFlyerAdultsKey = @"adults";
NSString * const kAppsFlyerCheckInKey = @"checkIn";
NSString * const kAppsFlyerCheckOutKey = @"checkOut";
NSString * const kHotelWebsiteString = @"hotelWebsite";
NSString * const kNonBreakingSpaceString = @"\u00a0";

@implementation StringUtils

+ (NSString *)destinationStringBySearchInfo:(HLSearchInfo *)searchInfo
{
    NSString *result = nil;
    switch (searchInfo.searchInfoType) {
        case HLSearchInfoTypeUserLocation: {
            result = NSLS(@"HL_LOC_FILTERS_POINT_MY_LOCATION_TEXT");
        } break;
            
        default: {
            result = [StringUtils defaultDestinationStringBySearchInfo:searchInfo];
        } break;
    }
    
    return result;
}

+ (NSString *)searchDestinationDescriptionStringBySearchInfo:(HLSearchInfo *)searchInfo
{
    NSString *result = nil;
    switch (searchInfo.searchInfoType) {
        case HLSearchInfoTypeUserLocation:
        {
            result = NSLS(@"HL_LOC_HOTELS_NEARBY_TEXT");
        }
            break;
            
        default:
        {
            result = [StringUtils defaultDestinationStringBySearchInfo:searchInfo];
        }
            break;
    }
    
    return result;
}

+ (NSString *)defaultDestinationStringBySearchInfo:(HLSearchInfo *)searchInfo
{
    NSString *result = nil;
    switch (searchInfo.searchInfoType) {
        case HLSearchInfoTypeHotel:
        {
            result = searchInfo.hotel.name;
        }
            break;
            
        case HLSearchInfoTypeCity:
        {
            NSString *name = [StringUtils cityName:searchInfo.city];
            if (name.length > 0) {
                result = name;
            } else {
                result = NSLS(@"HL_LOC_CITY_PLACEHOLDER_TEXT");
            }
        }
            break;
            
        case HLSearchInfoTypeCityCenterLocation:
        {
            NSString *name = [StringUtils cityName:searchInfo.locationPoint.city] ?: @"";
            result = [NSString stringWithFormat:NSLS(@"HL_LOC_NEARBY_CITIES_SEARCH_DESTINATION_TEXT"), name];
        }
            break;
            
        case HLSearchInfoTypeCustomLocation:
        {
            result = NSLS(@"HL_LOC_POINT_ON_MAP_TEXT");
        }
            break;
        
        case HLSearchInfoTypeAirport: {
            result = searchInfo.locationPoint.title;
        }
            break;
        
        default:
            break;
    }
    
    return result;
}

+ (NSString *)shortDateDescription:(NSDate *)date localeIdentifier:(NSString *)localeIdentifier
{
    if (!date) {
		return @"…";
	}

    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeIdentifier];
    NSDateFormatter *formatter = [HDKDateUtil standardFormatter];
    [formatter setLocale:locale];

    NSString * dayDesc = nil;
    NSInteger indexToSubString = MIN(2, localeIdentifier.length);
    NSString *lang = [localeIdentifier substringToIndex:indexToSubString];
    BOOL useExtendedDescription = [[HLLocaleInspector sharedInspector] isLanguageRussian:lang] || iPhone47Inch() || iPhone55Inch();
    NSString *template = useExtendedDescription ? @"EEdMMMM" : @"EEdMMM";
    
    template = [NSDateFormatter dateFormatFromTemplate:template options:0 locale:locale];
    formatter.dateFormat = template;
    dayDesc = [formatter stringFromDate:date];

    return dayDesc;
}

+ (NSString *)ipadShortDateDescription:(NSDate *)date localeIdentifier:(NSString *)localeIdentifier
{
    NSDateFormatter *formatter = [HDKDateUtil standardFormatter];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:localeIdentifier]];
    formatter.dateStyle = NSDateFormatterShortStyle;
    
    return [formatter stringFromDate:date];
}

+ (NSString *)shortDateDescription:(NSDate *)date
{
    NSString *lang = [NSLocale currentLocale].localeIdentifier;
    return [self shortDateDescription:date localeIdentifier:lang];
}

+ (NSString *)datesDescriptionWithCheckIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut localeIdentifier:(NSString *)lang
{
	return [NSString stringWithFormat:@"%@ – %@", [self shortDateDescription:checkIn localeIdentifier:lang], [self shortDateDescription:checkOut localeIdentifier:lang]];
}

+ (NSString *)ipadDatesDescriptionWithCheckIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut localeIdentifier:(NSString *)lang
{
    return [NSString stringWithFormat:@"%@ – %@", [self ipadShortDateDescription:checkIn localeIdentifier:lang], [self ipadShortDateDescription:checkOut localeIdentifier:lang]];
}

+ (NSString *)datesDescriptionWithCheckIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut
{
    NSString *lang = [NSLocale currentLocale].localeIdentifier;
	return [self datesDescriptionWithCheckIn:checkIn checkOut:checkOut localeIdentifier:lang];
}

+ (NSString *)ipadDatesDescriptionWithCheckIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut
{
    NSString *lang = [NSLocale currentLocale].localeIdentifier;
    return [self ipadDatesDescriptionWithCheckIn:checkIn checkOut:checkOut localeIdentifier:lang];
}

+ (NSString *)guestsDescriptionWithGuestsCount:(NSInteger)count
{
	NSString * format = NSLSP(@"HL_LOC_GUEST", count);
	NSString * text = [NSString stringWithFormat:@"%li %@", (long)count, format];
	return text;
}

+ (NSString *)guestsDescriptionWithAdultsCount:(NSInteger)adultsCount kidsCount:(NSInteger)kidsCount
{
    NSString *adultLocString = NSLSP(@"HL_LOC_GUEST_ADULT", adultsCount);
    NSString *adultString = [NSString stringWithFormat:@"%li %@", (long)adultsCount, adultLocString];

    if (kidsCount > 0) {
        NSString *kidsLocString = NSLSP(@"HL_LOC_GUEST_KID", kidsCount);
        NSString *kidsString = [NSString stringWithFormat:@"%li %@", (long)kidsCount, kidsLocString];

        return [NSString stringWithFormat:@"%@, %@", adultString, kidsString];
    }
    else {
        return adultString;
    }
}

+ (NSString *)kidAgeTextWithAge:(NSInteger)age
{
    if (age == 0) {
        return NSLS(@"HL_KIDS_PICKER_LESS_THAN_ONE_YEAR_TITLE");
    }
    
    NSString *format = NSLSP(@"HL_LOC_YEAR", age);
    NSString *text = [NSString stringWithFormat:@"%li %@", (long)age, format];
    
    return text;
}

+ (NSString *)bestPriceStringWithDays:(NSInteger)days
{
        NSString *duration = [StringUtils durationDescriptionWithDays:days];
        return [NSString stringWithFormat:@"%@%@", NSLS(@"HL_HOTEL_DETAIL_CTA_HEADER_TITLE"), duration];
}


+ (NSString *)durationDescriptionWithDays:(NSInteger)days
{
    NSString *nightString = NSLSP(@"HL_LOC_NIGHT", days);
    NSString *result = [NSString stringWithFormat:@"%li %@", (long)days, nightString];

    return result;
}

+ (NSString *)userSettingsDurationWithPrefixWithDays:(NSInteger)days
{
    NSString *nightString = NSLSP(@"HL_LOC_FOR_NIGHT", days);
    NSString *result = [NSString stringWithFormat:nightString, (long)days];

    return result;
}

+ (NSString *)intervalDescriptionWithDate:(NSDate *)start andDate:(NSDate *)finish
{
    NSDateFormatter *formatter = [HDKDateUtil standardFormatter];
    NSString *template = @"dd.MM";
    template = [NSDateFormatter dateFormatFromTemplate:template options:0 locale:[NSLocale currentLocale]];

    formatter.dateFormat = template;
    NSString *checkInDateDescription = [formatter stringFromDate:start];
    NSString *checkOutDateDescription = [formatter stringFromDate:finish];

    return [NSString stringWithFormat:@"%@–%@", checkInDateDescription, checkOutDateDescription];
}

+ (nullable NSString *)searchInfoStringBySearchInfo:(nullable HLSearchInfo *)info
{
    if (info == nil) {
        return nil;
    }

    NSString *datesText = [StringUtils intervalDescriptionWithDate:info.checkInDate andDate:info.checkOutDate];
    NSString *passengersText = [StringUtils guestsDescriptionWithGuestsCount:info.adultsCount + info.kidAgesArray.count];

    return [NSString stringWithFormat:@"%@, %@", datesText, passengersText];
}

#pragma mark - CheckInOut Date formatting

+ (NSString *)shortCheckInOutDateAndTime:(NSDate *)time locale:(NSLocale *)locale timePrefix:(NSString *)timePrefix
{
    NSDateFormatter *dateFormatter = [HDKDateUtil standardFormatter];
    dateFormatter.dateFormat = @"dd MMM";
    dateFormatter.locale = locale;
    NSString *dateString = [dateFormatter stringFromDate:time];

    NSDateFormatter *timeFormatter = [HDKDateUtil standardFormatter];
    timeFormatter.timeStyle = NSDateFormatterShortStyle;
    timeFormatter.dateStyle = NSDateFormatterNoStyle;
    timeFormatter.locale = locale;
    NSString *timeString = [timeFormatter stringFromDate:time];

    return [NSString stringWithFormat:@"%@, %@ %@", dateString, timePrefix, timeString];
}

+ (NSString *)shortCheckInDateAndTime:(NSDate *)time
{
    return [self shortCheckInDateAndTime:time locale:[NSLocale currentLocale]];
}

+ (NSString *)shortCheckInDateAndTime:(NSDate *)time locale:(NSLocale *)locale
{
    return [self shortCheckInOutDateAndTime:time locale:locale timePrefix:NSLS(@"HL_LOC_CHECKIN_AFTER")];
}

+ (NSString *)shortCheckOutDateAndTime:(NSDate *)time
{
    return [self shortCheckOutDateAndTime:time locale:[NSLocale currentLocale]];
}

+ (NSString *)shortCheckOutDateAndTime:(NSDate *)time locale:(NSLocale *)locale
{
    return [self shortCheckInOutDateAndTime:time locale:locale timePrefix:NSLS(@"HL_LOC_CHECKOUT_BEFORE")];
}

+ (NSString *)longCheckInOutDateAndTime:(NSDate *)time locale:(NSLocale *)locale timePrefix:(NSString *)timePrefix
{
    NSString *shortString = [self shortCheckInOutDateAndTime:time locale:locale timePrefix:timePrefix];

    NSDateFormatter *formatter = [HDKDateUtil standardFormatter];
    formatter.dateFormat = @"EEEE";
    [formatter setLocale:locale];
    NSString *dayOfWeek = [formatter stringFromDate:time];

    return [NSString stringWithFormat:@"%@, %@", dayOfWeek, shortString];
}

+ (NSString *)longCheckInDateAndTime:(NSDate *)time
{
    return [self longCheckInDateAndTime:time locale:[NSLocale currentLocale]];
}

+ (NSString *)longCheckInDateAndTime:(NSDate *)time locale:(NSLocale *)locale
{
    return [self longCheckInOutDateAndTime:time locale:locale timePrefix:NSLS(@"HL_LOC_CHECKIN_AFTER")];
}

+ (NSString *)longCheckOutDateAndTime:(NSDate *)time
{
    return [self longCheckOutDateAndTime:time locale:[NSLocale currentLocale]];
}

+ (NSString *)longCheckOutDateAndTime:(NSDate *)time locale:(NSLocale *)locale
{
    return [self longCheckInOutDateAndTime:time locale:locale timePrefix:NSLS(@"HL_LOC_CHECKOUT_BEFORE")];
}

#pragma mark -

+ (NSString *)cityNameWithStateAndCountry:(nullable HDKCity *)city
{
	if ((city.name.length == 0 || city.countryName.length == 0) && city.fullName) {
        return city.fullName;
	}
    NSMutableString *result = [NSMutableString new];
    if (city.name.length > 0) {
        result = [NSMutableString stringWithString:city.name];
        if (city.state.length > 0) {
            [result appendFormat:@", %@", city.state];
        }
        if (city.countryName.length > 0) {
            [result appendFormat:@", %@", city.countryName];
        }
    }
	
	return result;
}

+ (nullable NSString *)cityName:(nullable HDKCity *)city
{
    if (city.name.length > 0) {
        return city.name;
    }
    if (city.fullName.length > 0) {
        return city.fullName;
    }
    return nil;
}

+ (nullable NSString *)cityFullName:(nullable HDKCity *)city
{
    if (city.fullName.length > 0) {
        return city.fullName;
    }
    if (city.name.length > 0) {
        return city.name;
    }
    
    return nil;
}

+ (NSString *)searchInfoDescription:(HLSearchInfo *)searchInfo
{
    NSString * locationDescription = nil;
    switch (searchInfo.searchInfoType) {
        case HLSearchInfoTypeUserLocation:
        case HLSearchInfoTypeCustomLocation:
        case HLSearchInfoTypeAirport:
            locationDescription = searchInfo.locationPoint.title;
            break;
            
        case HLSearchInfoTypeCity:
            locationDescription = [StringUtils cityNameWithStateAndCountry:searchInfo.city];
            break;
            
        case HLSearchInfoTypeCityCenterLocation:
            locationDescription = [StringUtils cityNameWithStateAndCountry:searchInfo.locationPoint.city];
            break;
            
        default:
            break;
    }
	NSString * datesText = [StringUtils intervalDescriptionWithDate:searchInfo.checkInDate andDate:searchInfo.checkOutDate];
	NSString * passengersText = [StringUtils guestsDescriptionWithGuestsCount:searchInfo.adultsCount + searchInfo.kidAgesArray.count];
	NSString * result = [NSString stringWithFormat:@"%@, %@; %@", locationDescription, datesText, passengersText];
	
    return result;
}

+ (NSAttributedString *)attributedRangeValueTextWithPercentFormatForMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue
{
    UIFont *textFont = [UIFont systemFontOfSize:12.0];
    UIFont *numberFont = [UIFont systemFontOfSize:12.0];
    UIColor *textColor = [JRColorScheme lightTextColor];
    UIColor *numberColor = [JRColorScheme darkTextColor];

    NSString *lowerString = [NSString stringWithFormat:@"%.0f%%", floorf(minValue * 100.0)];
    NSAttributedString *lowerAttributedString = [[NSAttributedString alloc] initWithString:lowerString attributes:@{NSFontAttributeName : numberFont}];

    NSString *upperString = [NSString stringWithFormat:@"%.0f%%", ceilf(maxValue * 100.0)];
    NSAttributedString *upperAttributedString = [[NSAttributedString alloc] initWithString:upperString attributes:@{NSFontAttributeName : numberFont}];
    
    NSString *str = [NSString stringWithFormat:NSLS(@"HL_LOC_FILTER_RANGE"), @"lowerValue", @"upperValue"];
    NSMutableAttributedString *range = [[NSMutableAttributedString alloc] initWithString:str];
    [range addAttribute:NSFontAttributeName value:textFont range:NSRangeFromString(str)];
    [range addAttribute:NSForegroundColorAttributeName value:textColor range:NSRangeFromString(str)];
    
    [range replaceCharactersInRange:[range.string rangeOfString:@"lowerValue"] withAttributedString:lowerAttributedString];
    [range replaceCharactersInRange:[range.string rangeOfString:@"upperValue"] withAttributedString:upperAttributedString];
    
    [range addAttribute:NSForegroundColorAttributeName value:numberColor range:[range.string rangeOfString:lowerAttributedString.string]];
    [range addAttribute:NSForegroundColorAttributeName value:numberColor range:[range.string rangeOfString:upperAttributedString.string options:NSBackwardsSearch]];
    
    return range;
}

+ (NSString *)formattedNumberStringWithNumber:(NSInteger)number
{
    static NSNumberFormatter *nf = nil;
    if (!nf) {
        nf = [NSNumberFormatter new];
        nf.usesGroupingSeparator = YES;
        nf.groupingSize = 3;
    }
    
    return [nf stringFromNumber:[NSNumber numberWithInteger:number]];
}

+ (NSString *)hotelsCountDescriptionWithHotels:(NSInteger)count
{
	NSString * formattedCount = [StringUtils formattedNumberStringWithNumber:count];
	NSString * hotelWordString = NSLSP(@"HL_LOC_SEARCH_FORM_HOTEL", count);
	return [NSString stringWithFormat:@"%@ %@", formattedCount, hotelWordString];
}

+ (NSString *)filteredHotelsDescriptionWithFiltered:(NSInteger)filtered total:(NSInteger)total
{
    NSString *title = nil;
    if (filtered > 0) {
        NSString *countStr = [StringUtils formattedNumberStringWithNumber:filtered];
        NSString *totalStr = [StringUtils formattedNumberStringWithNumber:total];
        title = NSLSP(@"HL_LOC_FILTER_HOTELS_FOUND", filtered);
        title = [NSString stringWithFormat:title, countStr, totalStr];
    } else {
        title = NSLS(@"HL_FILTER_HOTELS_NOT_FOUND");
    }

    return title;
}

+ (NSString *)roomsAvailableStringWithCount:(NSInteger)count
{
    NSString *title = NSLSP(@"HL_HOTEL_DETAIL_AVAILABLE_ROOMS_COUNT_OPTION_BASED", count);
    title = [NSString stringWithFormat:title, count];
    
    return title;
}

+ (NSString *)photoCounterString:(NSInteger)count totalCount:(NSInteger)totalCount
{
    return [NSString stringWithFormat:@"%ld/%ld", (long)(count + 1), (long)totalCount];
}

+ (NSString *)shortRatingString:(NSInteger)rating
{
    return [self shortRatingString:rating locale:[NSLocale currentLocale]];
}

+ (NSString *)shortRatingString:(NSInteger)rating locale:(NSLocale *)locale
{
    return rating == 100 ? @"10" : [NSString stringWithFormat:@"%.1f", rating / 10.0];
}

#pragma mark - Price Formatting

+ (NSString *)priceStringWithVariant:(HLResultVariant *)variant;
{
    NSString *stringToReturn = nil;
    if (variant.rooms.count == 0) {
        stringToReturn = @"—";
    } else if (variant.searchInfo.currency) {
        stringToReturn = [[variant.searchInfo.currency.formatter stringFromNumber:@(variant.minPrice)] mutableCopy];
        BOOL shouldReplaceSpaceWithNonBreaking = variant.searchInfo.currency.symbol.length == 1;
        if (shouldReplaceSpaceWithNonBreaking) {
            stringToReturn = [stringToReturn stringByReplacingOccurrencesOfString:@" " withString:kNonBreakingSpaceString];
        }
    } else {
        stringToReturn = [self formattedNumberStringWithNumber:variant.minPrice];
    }
    
    return stringToReturn;
}

+ (NSString *)priceStringWithPrice:(float)price currency:(HDKCurrency *)currency
{
    return currency != nil
        ? [currency.formatter stringFromNumber:@(price)]
        : [self formattedNumberStringWithNumber:price];
}

+ (NSAttributedString *)attributedPriceStringWithVariant:(HLResultVariant *)variant currency:(HDKCurrency *)currency font:(UIFont *)font
{
    return [self attributedPriceStringWithVariant:variant currency:currency font:font noPriceColor:nil];
}

+ (NSAttributedString *)attributedPriceStringWithVariant:(HLResultVariant *)variant currency:(HDKCurrency *)currency font:(UIFont *)font noPriceColor:(UIColor * _Nullable)color
{
    if (variant.rooms.count > 0) {
        return [self attributedPriceStringWithPrice:variant.minPrice currency:currency font:font];
    } else {
        NSString *string = @"—";
        NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:string];
        [result addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
        if (color != nil) {
            [result addAttribute:NSForegroundColorAttributeName value:color range:(NSMakeRange(0, string.length))];
        }

        return result;
    }
}

+ (NSAttributedString *)attributedPriceStringWithPrice:(float)price currency:(HDKCurrency *)currency font:(UIFont *)font
{
    NSString *priceString = [self priceStringWithPrice:price currency:currency];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:priceString];
    [result addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, priceString.length)];
    
    return result;
}

+ (NSAttributedString *)strikethroughAttributedString:(NSAttributedString *)attributedString
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    [attributeString addAttribute:NSStrikethroughStyleAttributeName
                            value:@1
                            range:NSMakeRange(0, [attributeString length])];
    
    return attributeString;
}

+ (NSString *)discountStringForDiscount:(NSInteger)discount
{
    return [NSString stringWithFormat:@"%li%% %@", labs(discount), NSLS(@"HL_DISCOUNT")];
}

#pragma mark - URL handling

+ (NSDictionary *)paramsFromUrlAbsoluteString:(NSString *)urlString
{
    NSArray * params = [urlString componentsSeparatedByString:@"?"];
    urlString = [params lastObject];
    params = [urlString componentsSeparatedByString:@"://"];
    urlString = [params lastObject];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *pairs = [urlString componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if(elements.count > 1){
            NSString *key = [[elements objectAtIndex:0] stringByRemovingPercentEncoding];
            NSString *val = [[elements objectAtIndex:1] stringByRemovingPercentEncoding];
            
            [dict setObject:val forKey:key];
        }
    }
    
    return dict;
}

+ (NSDictionary *)paramsFromAppsFlyerString:(NSString *)appsFlyerString
{
    NSArray *paramsArray = [appsFlyerString componentsSeparatedByString:@"-"];
    if (paramsArray.count < 5) {
        
        return @{};
    }
    
    NSDictionary *mapDict = @{kAppsFlyerHotelKey    : kAppsFlyerHolelIdKey,
                              kAppsFlyerLocationKey : kAppsFlyerLocationIdKey,
                              kAppsFlyerIataKey     : kAppsFlyerIataIdKey};

    NSString *type               = paramsArray[0];
    NSString *identifier         = paramsArray[1];
    NSString *checkInDateString  = paramsArray[2];
    NSString *checkOutDateString = paramsArray[3];
    NSString *adultsCount        = paramsArray[4];
    
    NSString *identifierName = mapDict[type];
    if (!identifierName) {
        return @{};
    }

    NSMutableDictionary *params = [NSMutableDictionary new];

    params[identifierName]          = identifier;
    params[kAppsFlyerCheckInKey]    = [self dateStringFromAppsFlyerString:checkInDateString];
    params[kAppsFlyerCheckOutKey]   = [self dateStringFromAppsFlyerString:checkOutDateString];
    params[kAppsFlyerAdultsKey]     = adultsCount;
    
    return [params copy];
}

+ (NSString *)dateStringFromAppsFlyerString:(NSString *)appsFlyerString
{
    NSString *result = nil;
    if (appsFlyerString.length == 8) {

        NSString *day = [appsFlyerString substringWithRange:NSMakeRange(0, 2)];
        NSString *month = [appsFlyerString substringWithRange:NSMakeRange(2, 2)];
        NSString *year = [appsFlyerString substringWithRange:NSMakeRange(4, 4)];
        
        result = [NSString stringWithFormat:@"%@-%@-%@", year, month, day];
    }
    
    return result;
}

#pragma mark - Distance formatting

+ (NSAttributedString *)attributedDistanceString:(CGFloat)meters
{
    return [self attributedDistanceString:meters
                                textColor:[JRColorScheme lightTextColor]
                              numberColor:[JRColorScheme darkTextColor]];
}

+ (NSAttributedString *)attributedDistanceString:(CGFloat)meters
                                       textColor:(UIColor *)textColor
                                     numberColor:(UIColor *)numberColor
{
    UIFont * textFont = [UIFont systemFontOfSize:12.0];
    UIFont * numberFont = [UIFont systemFontOfSize:12.0];
    
    NSString * valueString = [StringUtils roundedDistanceWithMeters:meters];
    NSAttributedString * attrValueString = [[NSAttributedString alloc] initWithString:valueString];
    NSString *str = [NSString stringWithFormat:@"%@ %@", NSLS(@"HL_LOC_FILTER_TO_STRING"), @"lowerValue"];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:str];
    [result addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, str.length)];
    [result addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
    
    [result replaceCharactersInRange:[result.string rangeOfString:@"lowerValue"] withAttributedString:attrValueString];
    
    [result addAttribute:NSForegroundColorAttributeName value:numberColor range:[result.string rangeOfString:attrValueString.string]];
    [result addAttribute:NSFontAttributeName value:numberFont range:[result.string rangeOfString:attrValueString.string]];
    
    return result;
}

+ (NSString *)distanceUnitAbbreviation
{
    return [HLLocaleInspector shouldUseMetricSystem] ? NSLS(@"HL_LOC_KILOMETERS_ABBREVIATION") : NSLS(@"HL_LOC_MILES_ABBREVIATION");
}

+ (NSString *)shortDistanceStringWithKilometers:(CGFloat)distance
{
    NSString * unitAbbreviation = [self distanceUnitAbbreviation];
    if(![HLLocaleInspector shouldUseMetricSystem]){
        distance = [HLDistanceCalculator convertKilometersToMiles:distance];
    }
    NSString * result = [NSString stringWithFormat:@"%.1f %@", distance, unitAbbreviation];
    
    return result;
}

+ (NSString *)roundedDistanceWithMeters:(CGFloat)meters
{
    NSString * result = nil;
    if (![HLLocaleInspector shouldUseMetricSystem] || meters >= 1000) {
        result = [self shortDistanceStringWithKilometers:meters / 1000.0];
    } else {
        meters = 10 * round(meters / 10.0);
        result = [NSString stringWithFormat:@"%.f %@", meters, NSLS(@"HL_LOC_METERS_ABBREVIATION")];
    }
    return result;
}

#pragma mark - Points Name formatting

+ (NSString *)locationPointName:(nullable HDKLocationPoint *)point;
{
    if ([point isKindOfClass:[HLCityLocationPoint class]]) {
        NSString *cityCenterString = point.name;
        if (cityCenterString.length > 0) {
            cityCenterString = [cityCenterString hl_firstLetterCapitalizedString];
        }

        return [NSString stringWithFormat:@"%@ (%@)", cityCenterString, [(HLCityLocationPoint *)point cityName]];
    }

    return [self capitalizedFirstLetterString:point.name];
}

+ (NSString *)capitalizedFirstLetterString:(NSString *)string
{
    if (string.length == 0) {
        return string;
    }
    return [NSString stringWithFormat:@"%@%@",[[string substringToIndex:1] uppercaseString],[string substringFromIndex:1]];
}

#pragma mark - Hotels

+ (nonnull NSString *)hotelAddressForHotel:(nullable HDKHotel *)hotel
{
    NSString *addressString = hotel.address ?: @"";
    NSString *detailsString = [self hotelAddressDetails:hotel] ?: @"";
    NSMutableString *result = [[NSMutableString alloc] initWithString:addressString];
    if (result.length > 0 && detailsString.length > 0) {
        [result appendString:[NSString stringWithFormat:@", %@", detailsString]];
    } else {
        [result appendString:detailsString];
    }

    return [result copy];
}

+ (nullable NSString *)hotelAddressDetails:(nullable HDKHotel *)hotel
{
    NSString *districtName = hotel.firstDistrictName;
    if (districtName.length == 0) {
        return nil;
    }

    NSString *cityName = [self cityName:hotel.city];

    return cityName.length > 0
    ? [NSString stringWithFormat:@"%@, %@", districtName, cityName]
    : districtName;
}

+ (NSString *)adultGuestsDescriptionWithCount:(NSInteger)adultsCount
{
    if (adultsCount > 0) {
        NSString *adultLocString = NSLSP(@"HL_LOC_GUEST_ADULT", adultsCount);
        return [NSString stringWithFormat:@"%li %@", (long)adultsCount, adultLocString];
    } else {
        return @"";
    }
}

+ (NSString *)childGuestsDescriptionWithCount:(NSInteger)kidsCount
{
    if (kidsCount > 0) {
        NSString *kidsLocString = NSLSP(@"HL_LOC_GUEST_KID", kidsCount);
        return [NSString stringWithFormat:@"%li %@", (long)kidsCount, kidsLocString];
    } else {
        return @"";
    }
}

+ (NSString *)checkInTimeFromDate:(NSDate *)date
{
    return [NSString stringWithFormat:@"%@ %@", NSLS(@"HL_LOC_CHECKIN_AFTER"), [self timeStringFromDate:date]];
}

+ (NSString *)checkOutTimeFromDate:(NSDate *)date
{
    return [NSString stringWithFormat:@"%@ %@", NSLS(@"HL_LOC_CHECKOUT_BEFORE"), [self timeStringFromDate:date]];
}

+ (NSString *)timeStringFromDate:(NSDate *)date
{
    return [self timeStringFromDate:date locale:[NSLocale currentLocale]];
}

+ (NSString *)timeStringFromDate:(NSDate *)date locale:(NSLocale *)locale
{
    NSDateFormatter *timeFormatter = [HDKDateUtil standardFormatter];
    timeFormatter.timeStyle = NSDateFormatterShortStyle;
    timeFormatter.dateStyle = NSDateFormatterNoStyle;
    timeFormatter.locale = locale;
    return [timeFormatter stringFromDate:date];
}

+ (NSString *)accommodationSummaryCheckInStringForDate:(NSDate *)date shortMonth:(BOOL)shortMonth
{
    NSString *dateString = [self accommodationSummaryDateStringForDate:date shortMonth:shortMonth locale:[NSLocale currentLocale]];
    return [NSString stringWithFormat:@"%@ %@", NSLS(@"HL_HOTEL_DETAIL_INFORMATION_CHECKIN"), dateString];
}

+ (NSString *)accommodationSummaryCheckOutStringForDate:(NSDate *)date shortMonth:(BOOL)shortMonth
{
    NSString *dateString = [self accommodationSummaryDateStringForDate:date shortMonth:shortMonth locale:[NSLocale currentLocale]];
    return [NSString stringWithFormat:@"%@ %@", NSLS(@"HL_HOTEL_DETAIL_INFORMATION_CHECKOUT"), dateString];
}

+ (NSString *)accommodationSummaryDateStringForDate:(NSDate *)date shortMonth:(BOOL)shortMonth locale:(NSLocale *)locale
{
    NSDateFormatter *dateFormatter = [HDKDateUtil standardFormatter];
    dateFormatter.dateFormat = [NSString stringWithFormat:@"d %@, EE", shortMonth ? @"MMM" : @"MMMM"];
    dateFormatter.locale = locale;
    return [dateFormatter stringFromDate:date];
}

@end
