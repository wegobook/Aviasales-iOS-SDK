#import <MapKit/MapKit.h>

@interface TBClusterAnnotationView : MKAnnotationView

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UILabel *priceLabel;
@property (nonatomic, strong) NSArray *variants;

- (void)initialSetup;
- (void)addBackgroundView;
- (void)addPriceLabel;

@end
