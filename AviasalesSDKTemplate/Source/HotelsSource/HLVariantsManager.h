#import <Foundation/Foundation.h>

@class HLSearchInfo;
@class HDKHotel;
@class HLResultVariant;
@class SearchResult;
@class HDKGate;

extern NSString * const HL_VARIANTS_MANAGER_DID_LOAD_HOTELS;

@protocol HLVariantsManagerDelegate <NSObject>

- (void)variantsManagerFinished:(SearchResult *)searchResult;
- (void)variantsManagerFailedWithError:(NSError *)error;
- (void)variantsManagerCancelled;

@optional
- (void)variantsManagerSearchRoomsStartedWithGates:(NSArray <HDKGate *> *)gates;
- (void)variantsManagerSearchRoomsDidReceiveDataFromGatesIds:(NSArray <NSString *> *)gateIds;

@end


@interface HLVariantsManager : NSObject

@property (nonatomic, strong) HLSearchInfo *searchInfo;
@property (nonatomic, weak) id<HLVariantsManagerDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isSearchInProgress;
@property (nonatomic, strong, readonly) NSArray *hotels;

- (void)startCitySearch;
- (void)startHotelSearch:(HDKHotel *)hotel;
- (void)stopSearch;

@end
