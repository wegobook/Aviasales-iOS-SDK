#import "HLMapGroupDetailsCell.h"
#import "HLVariantScrollablePhotoCell.h"
#import "HLResultVariant.h"
#import "AviasalesSDKTemplate-Bridging-Header.h"
#import <PureLayout/PureLayout.h>

@interface HLMapGroupDetailsCell ()

@property (nonatomic, strong) HLVariantScrollablePhotoCell *variantView;

@end

@implementation HLMapGroupDetailsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.variantView = LOAD_VIEW_FROM_NIB_NAMED(@"HLVariantScrollablePhotoCell");
        self.variantView.scrollEnabled = NO;

        @weakify(self)
        self.variantView.selectionHandler = ^(HLResultVariant *variant, NSUInteger index) {
            @strongify(self)
            [self.delegate showFullHotelInfo:variant
                           visiblePhotoIndex:index
                           indexChangedBlock:^(NSInteger index) { self.variantView.visiblePhotoIndex = index; }
                                      peeked:NO];
        };

        [self addSubview:self.variantView];

        [self.variantView autoPinEdgesToSuperviewEdges];
    }
    
    return self;
}

- (void)setVariant:(HLResultVariant *)variant
{
    _variant = variant;
    HLVariantItem *variantItem = [[HLVariantItem alloc] initWithVariant: variant];
    [self.variantView setupWithItem:variantItem];
}

@end
