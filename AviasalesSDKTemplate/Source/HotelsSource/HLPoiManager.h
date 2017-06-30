#import <Foundation/Foundation.h>

@class HLLocationManager;
@class HDKLocationPoint;
@class HDKHotel;
@class CLLocation;
@class HDKSeason;
@class Filter;
@class HLResultVariant;
@class HDKCity;

#define HL_POI_ANNOTATION_ZPOSITION -100
#define HL_HOTEL_ANNOTATION_ZPOSITION 100
#define HL_SELECTED_ANNOTATION_ZPOSITION 200

NS_ASSUME_NONNULL_BEGIN

@interface HLPoiManager : NSObject

+ (nullable HDKLocationPoint *)filterPoint:(nullable Filter *)filter variant:(HLResultVariant *)variant;
+ (NSArray <HDKLocationPoint *> *)selectHotelDetailsPoints:(HLResultVariant *)variant filter:(nullable Filter *)filter;
+ (NSArray <HDKLocationPoint *> *)allPoints:(HDKHotel *)hotel filter:(nullable Filter *)filter;
+ (NSArray <HDKLocationPoint *> *)filterPoints:(nullable NSArray <HDKLocationPoint *> *)points
                                  byCategories:(NSArray <NSString *> *)categories;
+ (NSArray <HDKLocationPoint *> *)allUniquePointsForCities:(nullable NSArray <HDKCity *> *)cities;
+ (NSArray <HDKLocationPoint *> *)pointsFrom:(NSArray <HDKLocationPoint *> *)points
                              pointsCategory:(NSString *)pointsCategory
                              seasonCategory:(NSString *)seasonCategory
                                     seasons:(nullable NSArray <HDKSeason *> *)seasons;
+ (BOOL)seasons:(NSArray <HDKSeason *> *)seasons haveCategory:(NSString *)category;

@end

NS_ASSUME_NONNULL_END
