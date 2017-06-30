#import <UIKit/UIKit.h>
#import "HLVariantCollectionViewCell.h"

@protocol HLShowHotelProtocol <NSObject>
- (void)showFullHotelInfo:(HLResultVariant *)variant visiblePhotoIndex:(NSInteger)visiblePhotoIndex indexChangedBlock:(void (^)(NSInteger index))block peeked:(BOOL)peeked;
@end

@interface HLVariantScrollablePhotoCell : HLVariantCollectionViewCell

@property (nonatomic, assign) NSInteger visiblePhotoIndex;
@property (nonatomic, assign) BOOL scrollEnabled;

@end
