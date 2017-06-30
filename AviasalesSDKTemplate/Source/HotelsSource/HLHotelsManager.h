#import <Foundation/Foundation.h>

@class HLSearchInfo;
@class HDKHotel;
@class HDKCity;

@protocol HLHotelsManagerDelegate <NSObject>

@optional
- (void)hotelsManagerDidLoadHotelsContent:(NSArray *)hotels cities:(NSArray <HDKCity *> *)cities;
- (void)hotelsManagerDidLoadHotelDetails:(HDKHotel *)hotel;
- (void)hotelsManagerFailedWithError:(NSError *)error;
- (void)hotelsManagerCancelled;

@end


@interface HLHotelsManager : NSObject

@property (nonatomic, weak) id<HLHotelsManagerDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL isLoading;

- (void)stopLoading;
- (void)loadHotelsContentForCities:(NSArray <HDKCity *> *)cities;
- (void)loadHotelDetailsForHotel:(HDKHotel *)hotel;

@end
