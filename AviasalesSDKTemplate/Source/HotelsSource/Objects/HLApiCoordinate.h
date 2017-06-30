#import <Foundation/Foundation.h>

@interface HLApiCoordinate : NSObject <NSCoding>

+ (instancetype)coordinateWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude;

- (HLApiCoordinate *)initWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude;

@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSNumber * longitude;

@end
