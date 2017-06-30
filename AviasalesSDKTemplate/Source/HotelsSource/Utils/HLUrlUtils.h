#import <Foundation/Foundation.h>
#import "HLResultVariant.h"

#define HL_HOST_PARAMETER_KEY @"host"

@class HDKHotel;

typedef NS_ENUM(NSInteger, HLUrlUtilsImageAlignment) {
    HLUrlUtilsImageAlignmentCenter,
    HLUrlUtilsImageAlignmentRight,
    HLUrlUtilsImageAlignmentLeft,
};

NS_ASSUME_NONNULL_BEGIN

@interface HLUrlUtils : NSObject

+ (NSString *)cityPhotoBaseURLString;
+ (NSString *)baseGateURLString;
+ (NSString *)URLShortenerBaseURLString;

+ (NSURL *)firstHotelPhotoURLByHotel:(HDKHotel *)hotel;
+ (NSURL *)firstHotelPhotoURLByHotel:(HDKHotel *)hotel withSizeInPoints:(CGSize)size;
+ (NSArray *)photoUrlsByHotel:(HDKHotel *)hotel withSizeInPoints:(CGSize)size;
+ (NSURL *)photoURLForPhotoId:(NSString *)photoId size:(CGSize)size;
+ (NSURL *)photoURLByHotel:(HDKHotel *)hotel size:(CGSize)size index:(NSInteger)index;

+ (NSURL *)gateIconURL:(NSInteger)gateId size:(CGSize)size alignment:(HLUrlUtilsImageAlignment)alignment;

+ (NSString *)handoffBookingUrlStringWithVariant:(HLResultVariant *)variant;
+ (NSString *)sharingBookingUrlStringWithVariant:(HLResultVariant *)variant;
+ (NSString *)searchUrlStringWithSearchInfo:(HLSearchInfo *)searchInfo;

+ (NSString *)dateParamToString:(NSDate *)date;

+ (NSString *)urlencodeString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
