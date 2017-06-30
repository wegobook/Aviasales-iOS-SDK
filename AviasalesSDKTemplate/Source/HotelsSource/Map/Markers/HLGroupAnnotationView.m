#import "HLGroupAnnotationView.h"
#import "HLResultVariant.h"
#import "StringUtils.h"
#import "PureLayout.h"

@interface HLGroupAnnotationView()
@property (nonatomic, strong) UIImageView *backgroundImage;
@end

@implementation HLGroupAnnotationView

#pragma mark - Override

- (void)addPriceLabel
{
    [super addPriceLabel];

    self.priceLabel.textColor = [UIColor whiteColor];
    [self.priceLabel autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self.priceLabel.superview withOffset:-1.0];
    [self.priceLabel autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.priceLabel.superview];
}

#pragma mark - Private

- (void)addBackgroundView
{
    self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"groupPin1"]];
    [self addSubview:self.backgroundImage];
    self.backgroundView = self.backgroundImage;
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundImage autoCenterInSuperview];
}

- (void)setVariants:(NSArray *)variants
{
    NSInteger hotelsWithRoomsCount = [self countVariantsWithRooms:variants];
    self.priceLabel.text = hotelsWithRoomsCount ? [StringUtils formattedNumberStringWithNumber:hotelsWithRoomsCount] : @"";

    if (hotelsWithRoomsCount > 1000) {
        self.backgroundImage.image = [UIImage imageNamed:@"groupPin4"];
    } else if (hotelsWithRoomsCount > 100) {
        self.backgroundImage.image = [UIImage imageNamed:@"groupPin3"];
    } else if (hotelsWithRoomsCount > 10) {
        self.backgroundImage.image = [UIImage imageNamed:@"groupPin2"];
    } else if (hotelsWithRoomsCount > 0) {
        self.backgroundImage.image = [UIImage imageNamed:@"groupPin1"];
    } else {
        self.backgroundImage.image = [UIImage imageNamed:@"groupPin0"];
    }

    CGRect frame = self.frame;
    frame.size = self.backgroundImage.image.size;
    self.frame = frame;
}

- (NSInteger)countVariantsWithRooms:(NSArray *)variants
{
    NSInteger result = 0;
    for (HLResultVariant *variant in variants) {
        if (variant.minPrice > 0 && variant.minPrice != UNKNOWN_MIN_PRICE) {
            result ++;
        }
    }
    
    return result;
}

@end
