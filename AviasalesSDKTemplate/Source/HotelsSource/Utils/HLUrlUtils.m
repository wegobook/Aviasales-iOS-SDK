#import "HLUrlUtils.h"
#import <HotellookSDK/HotellookSDK.h>
#import "DateUtil.h"
#import "HLLocaleInspector.h"

NSString * const kHlsUrlParameterKey = @"flags[utm]";
NSString * const kUtmUrlParameterKey = @"flags[utmDetail]";
NSString * const kMarkerUrlParameterKey = @"marker";

@implementation HLUrlUtils

+ (NSString *)cityPhotoBaseURLString
{
    return @"https://photo.hotellook.com/static/cities/";
}

+ (NSString *)baseGateURLString
{
    return @"https://pics.avs.io/hl_gates";
}

+ (NSString *)basePhotoURLString
{
    return @"https://photo.hotellook.com/image_v2/";
}

+ (NSString *)bookingBaseURLString
{
    return @"https://search.hotellook.com";
}

+ (NSString *)searchBaseURLString
{
    return @"https://search.hotellook.com";
}

+ (NSString *)URLShortenerBaseURLString
{
    return @"http://htl.io/yourls-api.php?";
}

+ (NSURL *)gateIconURL:(NSInteger)gateId size:(CGSize)size alignment:(HLUrlUtilsImageAlignment)alignment
{
    CGFloat scale = [self screenScale];
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    NSString *alignString = nil;

    switch (alignment) {
        case HLUrlUtilsImageAlignmentCenter:
            alignString = @"";
            break;

        case HLUrlUtilsImageAlignmentLeft:
            alignString = @"--west";
            break;

        case HLUrlUtilsImageAlignmentRight:
            alignString = @"--east";
            break;
    }

    NSString *urlString = [NSString stringWithFormat:@"%@/%.0f/%.0f/%li%@.png", HLUrlUtils.baseGateURLString, width, height, (long)gateId, alignString];
    
    return [NSURL URLWithString:urlString];
}

+ (NSArray *)photoUrlsByHotel:(HDKHotel *)hotel withSizeInPoints:(CGSize)size
{
    NSMutableArray *urls = [NSMutableArray array];
    if (size.height > 0 && size.width > 0 && hotel.photosIds.count) {
        for (NSString *photoId in hotel.photosIds) {
            [urls addObject:[HLUrlUtils photoURLForPhotoId:photoId
                                                      size:size]];
        }
    }

    return urls;
}

+ (NSURL *)firstHotelPhotoURLByHotel:(HDKHotel *)hotel withSizeInPoints:(CGSize)size
{
    return [self photoURLForPhotoId:hotel.photosIds.firstObject size:size];
}

+ (NSURL *)firstHotelPhotoURLByHotel:(HDKHotel *)hotel
{
    CGSize size = [HLPhotoManager defaultHotelPhotoSize];

    return [self photoURLForPhotoId:hotel.photosIds.firstObject size:size];
}

+ (NSURL *)photoURLForPhotoId:(NSString *)photoId size:(CGSize)size
{
    if (photoId == nil) {
        photoId = @"NULL_PHOTO_ID";
    }

    CGFloat scale = [self screenScale];
    NSString * urlString = [NSString stringWithFormat:@"%@crop/%@/%.0f/%.0f.jpg", HLUrlUtils.basePhotoURLString, photoId, size.width * scale, size.height * scale];

    return [NSURL URLWithString:urlString];
}

+ (NSURL *)photoURLByHotel:(HDKHotel *)hotel size:(CGSize)size index:(NSInteger)index
{
    if (index < 0 || index >= hotel.photosIds.count) {
        return [self photoURLForPhotoId:@"BAD_PHOTO_INDEX" size:size];
    }

    NSString *photoId = hotel.photosIds[index];
    return [self photoURLForPhotoId:photoId size:size];
}

+ (CGFloat)screenScale
{
	return (int)[UIScreen mainScreen].scale;
}

+ (NSString *)paramsStringWithSearchInfo:(HLSearchInfo *)searchInfo source:(NSString *)source
{
	NSString * checkIn = [HLUrlUtils dateParamToString:searchInfo.checkInDate];
	NSString * checkOut = [HLUrlUtils dateParamToString:searchInfo.checkOutDate];
	NSString * currency = searchInfo.currency.code;
    NSString * language = [HLLocaleInspector.sharedInspector localeString];
    NSString * utmMedium = platformName();

	NSString * paramString = @"mobileToken=%@&checkIn=%@&checkOut=%@&currency=%@&hls=%@&language=%@&adults=%i&utm_source=mobile&utm_medium=%@&utm_campaign=%@";
    NSMutableString * result = [[NSString stringWithFormat:paramString, searchInfo.token, checkIn, checkOut, currency, source, language, searchInfo.adultsCount, utmMedium, source] mutableCopy];

    if (searchInfo.kidAgesArray.count > 0) {
        [result appendFormat:@"&children="];
        for (int i = 0; i < searchInfo.kidAgesArray.count; i++) {
            [result appendFormat:@"%i", [searchInfo.kidAgesArray[i] intValue]];
            if (i < searchInfo.kidAgesArray.count - 1) {
                [result appendString:@","];
            }
        }
    }
	
	return result;
}

+ (NSString *) bookingUrlStringWithVariant:(HLResultVariant *) variant source:(NSString *)source
{
	NSString * searchUrlString = @"%@/?hotelId=%@&";
	
	NSString * baseUrlString = HLUrlUtils.bookingBaseURLString;
	NSString * hotelId = variant.hotel.hotelId;
	
	searchUrlString = [NSString stringWithFormat:searchUrlString, baseUrlString, hotelId];
	
	NSMutableString * result = [searchUrlString mutableCopy];
	NSString * params = [self paramsStringWithSearchInfo:variant.searchInfo source:source];
	[result appendString:params];
	return result;
}

+ (NSString *) handoffBookingUrlStringWithVariant:(HLResultVariant *) variant
{
	return [self bookingUrlStringWithVariant:variant source:@"handoff"];
}

+ (NSString *) sharingBookingUrlStringWithVariant:(HLResultVariant *) variant
{
	return [self bookingUrlStringWithVariant:variant source:@"mobilesharing"];
}

+ (NSString *)searchUrlStringWithSearchInfo:(HLSearchInfo *)searchInfo
{
    NSString *searchUrlString = @"%@/?%@";
	NSString *baseUrlString = HLUrlUtils.searchBaseURLString;
    
    NSString *destinationString = nil;
    if (searchInfo.isSearchByLocation) {
        CLLocationCoordinate2D coordinate = searchInfo.locationPoint.location.coordinate;
        destinationString = [NSString stringWithFormat:@"geo[lat]=%.6f&geo[lon]=%.6f&", coordinate.latitude, coordinate.longitude];
    } else if (searchInfo.hotel) {
        NSString *hotelId = searchInfo.hotel.hotelId;
        destinationString = [NSString stringWithFormat:@"hotelId=%@&", hotelId];
    } else {
        NSString *locationId = searchInfo.city.cityId;
        destinationString = [NSString stringWithFormat:@"locationId=%@&", locationId];
    }

	searchUrlString = [NSString stringWithFormat:searchUrlString, baseUrlString, destinationString];
	NSMutableString * result = [searchUrlString mutableCopy];
	NSString * params = [self paramsStringWithSearchInfo:searchInfo source:@"handoff"];
	[result appendString:params];
    
	return result;
}
	
+ (NSString *)dateParamToString:(NSDate *)date
{
	NSDateFormatter *formatter = [HDKDateUtil sharedServerDateFormatter];
	return [formatter stringFromDate:date];
}

+ (NSString *) urlencodeString:(NSString *)string
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' ') {
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
