#import <UIKit/UIKit.h>
#import "HLResultVariant.h"
#import "HLVariantScrollablePhotoCell.h"

@interface HLMapGroupDetailsCell : UICollectionViewCell

@property (nonatomic, strong) HLResultVariant * variant;
@property (nonatomic, weak) id <HLShowHotelProtocol> delegate;
@end
