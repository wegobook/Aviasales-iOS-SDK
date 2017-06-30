#import <HotellookSDK/HotellookSDK.h>

@class HDKLocationPoint;
@class HDKCity;

NS_ASSUME_NONNULL_BEGIN

@interface HDKDefaultsSaver (HL)

+ (NSArray * _Nullable)getRecentSearchDestinations;
+ (void)addRecentSearchDestination:(id)object;

+ (NSArray * _Nullable)getRecentFilterPointsForCity:(HDKCity *)city;
+ (void)addRecentFilterPoint:(HDKLocationPoint *)point forCity:(HDKCity *)city;

+ (NSArray * _Nullable)getRecentSelectedNameFilter;
+ (void)addRecentSelectedNameFilter:(id)object;

@end

NS_ASSUME_NONNULL_END
