#import "HLVariantScrollablePhotoCell.h"

@interface HLMapGroupDetailsVC : HLCommonVC <HLShowHotelProtocol>

@property (nonatomic, strong) NSArray *variants;
@property (nonatomic, weak) id <HLShowHotelProtocol> delegate;

@end
