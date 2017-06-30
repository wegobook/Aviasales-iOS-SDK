#import "HLAutolayoutView.h"

@interface HLAutolayoutView ()
@property(nonatomic) BOOL didSetupConstraints;
@end

@implementation HLAutolayoutView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];
    [self updateConstraintsIfNeeded];
}

- (void)updateConstraints
{
    [super updateConstraints];

    if (!self.didSetupConstraints) {
        [self setupConstraints];
        self.didSetupConstraints = YES;
    }
}

- (void)initialize
{
    // Implement in subclass
}

- (void)setupConstraints
{
    // Implement in subclass
}

@end
