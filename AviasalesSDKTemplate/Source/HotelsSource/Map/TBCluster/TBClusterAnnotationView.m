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
    [self.layer addObserver:self forKeyPath:@"zPosition" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];  // MKAnnotationView's zPosition seems to work wrong @ iOS 11
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.layer && [keyPath isEqualToString:@"zPosition"]) {
        CGFloat zPositionOld = [change[NSKeyValueChangeOldKey] floatValue];
        CGFloat zPositionNew = [change[NSKeyValueChangeNewKey] floatValue];

        if (zPositionNew != floorf(zPositionNew) || zPositionNew > 1000) {
            if (zPositionOld == floorf(zPositionOld)) {
                self.layer.zPosition = zPositionOld;
            } else {
                self.layer.zPosition = 100;
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)dealloc
{
    [self.layer removeObserver:self forKeyPath:@"zPosition"];
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
