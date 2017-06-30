#import <Foundation/Foundation.h>
#import "HLResultVariant.h"

@interface HLBadgeParser : NSObject

- (void)fillBadgesFor:(NSArray<HLResultVariant *> *)variants
     badgesDictionary:(NSDictionary<NSString *, HDKBadge *> *)badges
         hotelsBadges:(NSDictionary<NSString *, NSArray<NSString *> *> *)hotelsBadges
           hotelsRank:(NSDictionary<NSString *, NSNumber *> *)hotelsRank;

@end
