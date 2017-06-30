#import "HLAutolayoutCell.h"

@interface HLAutolayoutCell()
@property(nonatomic) BOOL didSetupConstraints;
@end

@implementation HLAutolayoutCell

- (void)updateConstraints
{
    [super updateConstraints];

    if (!self.didSetupConstraints) {
        [self setupConstraints];
        self.didSetupConstraints = YES;
    }
}

- (void)setupConstraints
{
    // Implement in subclass
}

@end
