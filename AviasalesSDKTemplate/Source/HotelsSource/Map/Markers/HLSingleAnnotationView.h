#import "TBClusterAnnotationView.h"
#import "HLVariantScrollablePhotoCell.h"

@interface HLSingleAnnotationView : TBClusterAnnotationView

+ (CGFloat)calloutHeight;

- (void)expandAnimated:(BOOL)animated;
- (void)collapseAnimated:(BOOL)animated;
- (void)updateContentAndCollapseIfExpanded;
- (CGRect)photoRect;

@property (nonatomic, weak) id<HLShowHotelProtocol> delegate;

@end
