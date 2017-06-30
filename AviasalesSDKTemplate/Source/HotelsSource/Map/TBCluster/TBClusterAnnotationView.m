#import "TBClusterAnnotationView.h"

@implementation TBClusterAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (void)initialSetup
{
    self.backgroundColor = [UIColor clearColor];
    [self addBackgroundView];
    [self addPriceLabel];
}

- (void)addBackgroundView
{
}

- (void)addPriceLabel
{
    self.priceLabel = [UILabel new];
    self.priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.priceLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium];
    self.priceLabel.textAlignment = NSTextAlignmentCenter;
    [self.backgroundView addSubview:self.priceLabel];
}

@end
